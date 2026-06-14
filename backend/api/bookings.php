<?php
// backend/api/bookings.php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

setCors();
$db     = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$id     = (int)($_GET['id'] ?? 0);

if ($id) {
    match ($method) {
        'GET' => getOne($db, $id),
        'PUT' => updateStatus($db, $id),
        default => error('Method not allowed', 405),
    };
} else {
    match ($method) {
        'GET'  => getAll($db),
        'POST' => create($db),
        default => error('Method not allowed', 405),
    };
}

function getAll(PDO $db): void {
    $auth = getAuthUser();
    if ($auth['role'] === 'user') {
        $stmt = $db->prepare(
            "SELECT b.*, s.name AS service_name, s.address AS service_address
             FROM bookings b
             JOIN services s ON s.id = b.service_id
             WHERE b.user_id = ?
             ORDER BY b.created_at DESC"
        );
        $stmt->execute([$auth['id']]);
    } elseif ($auth['role'] === 'owner') {
        $stmt = $db->prepare(
            "SELECT b.*, u.name AS user_name, u.phone AS user_phone,
                    s.name AS service_name
             FROM bookings b
             JOIN services s ON s.id = b.service_id AND s.owner_id = ?
             JOIN users u ON u.id = b.user_id
             ORDER BY b.created_at DESC"
        );
        $stmt->execute([$auth['id']]);
    } else {
        $stmt = $db->query(
            "SELECT b.*, u.name AS user_name, s.name AS service_name
             FROM bookings b
             JOIN users u ON u.id = b.user_id
             JOIN services s ON s.id = b.service_id
             ORDER BY b.created_at DESC LIMIT 100"
        );
    }
    success($stmt->fetchAll());
}

function getOne(PDO $db, int $id): void {
    $auth = getAuthUser();
    $stmt = $db->prepare(
        "SELECT b.*, s.name AS service_name, s.address AS service_address,
                u.name AS user_name, u.phone AS user_phone
         FROM bookings b
         JOIN services s ON s.id = b.service_id
         JOIN users u ON u.id = b.user_id
         WHERE b.id = ?"
    );
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) error('Buyurtma topilmadi', 404);
    success($row);
}

function create(PDO $db): void {
    $auth = getAuthUser();
    $body = getBody();
    $required = ['service_id', 'car_model', 'description'];
    foreach ($required as $f) {
        if (empty($body[$f])) error("$f kerak");
    }
    $stmt = $db->prepare(
        "INSERT INTO bookings (user_id, service_id, car_model, description, status, date, created_at)
         VALUES (?, ?, ?, ?, 'pending', NOW(), NOW())"
    );
    $stmt->execute([
        $auth['id'],
        $body['service_id'],
        $body['car_model'],
        $body['description'],
    ]);
    success(['id' => (int)$db->lastInsertId()], 'Buyurtma yuborildi', 201);
}

function updateStatus(PDO $db, int $id): void {
    $auth     = requireRole('owner', 'admin');
    $body     = getBody();
    $statuses = ['pending', 'accepted', 'in_progress', 'completed', 'cancelled'];
    $status   = $body['status'] ?? '';
    if (!in_array($status, $statuses)) error('Noto\'g\'ri status');

    $db->prepare("UPDATE bookings SET status = ? WHERE id = ?")->execute([$status, $id]);
    success(null, 'Status yangilandi');
}
