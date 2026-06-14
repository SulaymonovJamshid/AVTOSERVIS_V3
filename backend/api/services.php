<?php
// backend/api/services.php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

setCors();

$db     = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$id     = (int)($_GET['id'] ?? 0);

if ($id) {
    match ($method) {
        'GET'    => getOne($db, $id),
        'PUT'    => updateService($db, $id),
        'DELETE' => deleteService($db, $id),
        default  => error('Method not allowed', 405),
    };
} else {
    match ($method) {
        'GET'  => getAll($db),
        'POST' => createService($db),
        default => error('Method not allowed', 405),
    };
}

// ─── GET all services ────────────────────────────────────────────────────────
function getAll(PDO $db): void {
    $lat      = (float)($_GET['lat']      ?? 0);
    $lng      = (float)($_GET['lng']      ?? 0);
    $category = $_GET['category']         ?? '';
    $q        = trim($_GET['q']           ?? '');
    $limit    = min((int)($_GET['limit']  ?? 20), 100);
    $offset   = (int)($_GET['offset']     ?? 0);

    $where  = ['s.is_active = 1'];
    $params = [];

    if ($q) {
        $where[]  = '(s.name LIKE ? OR s.address LIKE ?)';
        $params[] = "%$q%";
        $params[] = "%$q%";
    }
    if ($category && $category !== 'all') {
        $where[]  = 'JSON_CONTAINS(s.categories, ?)';
        $params[] = json_encode($category);
    }

    $whereStr = implode(' AND ', $where);
    $sql = "SELECT s.*,
                   COALESCE(AVG(r.rating), 0)   AS rating,
                   COUNT(r.id)                   AS review_count
            FROM services s
            LEFT JOIN reviews r ON r.service_id = s.id
            WHERE $whereStr
            GROUP BY s.id
            ORDER BY s.is_verified DESC, rating DESC
            LIMIT ? OFFSET ?";

    $params[] = $limit;
    $params[] = $offset;

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    // Add distance if coords given
    foreach ($rows as &$row) {
        $row['images']     = json_decode($row['images']     ?? '[]', true);
        $row['categories'] = json_decode($row['categories'] ?? '[]', true);
        $row['rating']     = round((float)$row['rating'], 1);
        $row['review_count'] = (int)$row['review_count'];
        $row['is_open']    = (bool)$row['is_open'];
        $row['is_verified'] = (bool)$row['is_verified'];
        if ($lat && $lng) {
            $row['distance'] = haversine($lat, $lng, (float)$row['lat'], (float)$row['lng']);
        } else {
            $row['distance'] = 0;
        }
    }

    if ($lat && $lng) {
        usort($rows, fn($a, $b) => $a['distance'] <=> $b['distance']);
    }

    success($rows);
}

// ─── GET one ──────────────────────────────────────────────────────────────────
function getOne(PDO $db, int $id): void {
    $stmt = $db->prepare(
        "SELECT s.*,
                COALESCE(AVG(r.rating), 0) AS rating,
                COUNT(r.id)                AS review_count
         FROM services s
         LEFT JOIN reviews r ON r.service_id = s.id
         WHERE s.id = ?
         GROUP BY s.id"
    );
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) error('Servis topilmadi', 404);

    $row['images']       = json_decode($row['images']     ?? '[]', true);
    $row['categories']   = json_decode($row['categories'] ?? '[]', true);
    $row['rating']       = round((float)$row['rating'], 1);
    $row['review_count'] = (int)$row['review_count'];
    $row['is_open']      = (bool)$row['is_open'];
    $row['is_verified']  = (bool)$row['is_verified'];

    // Reviews
    $rev = $db->prepare(
        "SELECT r.*, u.name AS user_name, u.avatar AS user_avatar
         FROM reviews r
         JOIN users u ON u.id = r.user_id
         WHERE r.service_id = ?
         ORDER BY r.created_at DESC
         LIMIT 20"
    );
    $rev->execute([$id]);
    $row['reviews'] = $rev->fetchAll();

    success($row);
}

// ─── POST create ──────────────────────────────────────────────────────────────
function createService(PDO $db): void {
    $auth = getAuthUser();
    $body = getBody();

    $required = ['name', 'address', 'city', 'lat', 'lng', 'phone'];
    foreach ($required as $f) {
        if (empty($body[$f])) error("$f maydoni kerak");
    }

    $stmt = $db->prepare(
        "INSERT INTO services
            (owner_id, name, description, address, city, district, lat, lng, phone,
             working_hours, categories, images, is_active, is_verified, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '[]', 1, 0, NOW())"
    );
    $stmt->execute([
        $auth['id'],
        $body['name'],
        $body['description'] ?? '',
        $body['address'],
        $body['city'],
        $body['district'] ?? '',
        $body['lat'],
        $body['lng'],
        $body['phone'],
        $body['working_hours'] ?? '09:00 - 18:00',
        json_encode($body['categories'] ?? []),
    ]);

    success(['id' => (int)$db->lastInsertId()], 'Servis yaratildi', 201);
}

// ─── PUT update ──────────────────────────────────────────────────────────────
function updateService(PDO $db, int $id): void {
    $auth = requireRole('owner', 'admin');
    $body = getBody();

    // Owner only can edit own service
    if ($auth['role'] === 'owner') {
        $chk = $db->prepare("SELECT id FROM services WHERE id = ? AND owner_id = ?");
        $chk->execute([$id, $auth['id']]);
        if (!$chk->fetch()) error('Ruxsat yo\'q', 403);
    }

    $fields = [];
    $params = [];
    $allowed = ['name', 'description', 'address', 'city', 'phone', 'working_hours', 'is_open'];
    foreach ($allowed as $f) {
        if (isset($body[$f])) {
            $fields[] = "$f = ?";
            $params[] = $body[$f];
        }
    }
    if (isset($body['categories'])) {
        $fields[] = "categories = ?";
        $params[] = json_encode($body['categories']);
    }
    if ($auth['role'] === 'admin' && isset($body['is_verified'])) {
        $fields[] = "is_verified = ?";
        $params[] = (int)$body['is_verified'];
    }
    if (!$fields) error('O\'zgartiriladigan maydon yo\'q');

    $params[] = $id;
    $db->prepare("UPDATE services SET " . implode(', ', $fields) . " WHERE id = ?")->execute($params);

    success(null, 'Yangilandi');
}

// ─── DELETE ──────────────────────────────────────────────────────────────────
function deleteService(PDO $db, int $id): void {
    requireRole('admin');
    $db->prepare("DELETE FROM services WHERE id = ?")->execute([$id]);
    success(null, 'O\'chirildi');
}
