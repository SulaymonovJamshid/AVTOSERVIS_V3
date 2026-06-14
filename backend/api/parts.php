<?php
// backend/api/parts.php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

setCors();
$db     = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$id     = (int)($_GET['id'] ?? 0);

if ($id) {
    match ($method) {
        'GET'    => getOne($db, $id),
        'PUT'    => update($db, $id),
        'DELETE' => delete($db, $id),
        default  => error('Method not allowed', 405),
    };
} else {
    match ($method) {
        'GET'  => getAll($db),
        'POST' => create($db),
        default => error('Method not allowed', 405),
    };
}

function getAll(PDO $db): void {
    $q         = trim($_GET['q']         ?? '');
    $carBrand  = $_GET['car_brand']      ?? '';
    $inStock   = $_GET['in_stock']       ?? '';

    $where  = ['1=1'];
    $params = [];

    if ($q) {
        $where[]  = '(name LIKE ? OR description LIKE ?)';
        $params[] = "%$q%";
        $params[] = "%$q%";
    }
    if ($carBrand) {
        $where[]  = 'car_brand = ?';
        $params[] = $carBrand;
    }
    if ($inStock !== '') {
        $where[]  = 'in_stock = ?';
        $params[] = (int)$inStock;
    }

    $sql  = "SELECT p.*, u.name AS seller_name, u.phone AS seller_phone
             FROM parts p
             JOIN users u ON u.id = p.seller_id
             WHERE " . implode(' AND ', $where) . "
             ORDER BY p.created_at DESC
             LIMIT 50";

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$r) {
        $r['price']    = (float)$r['price'];
        $r['in_stock'] = (bool)$r['in_stock'];
    }
    success($rows);
}

function getOne(PDO $db, int $id): void {
    $stmt = $db->prepare(
        "SELECT p.*, u.name AS seller_name, u.phone AS seller_phone
         FROM parts p JOIN users u ON u.id = p.seller_id WHERE p.id = ?"
    );
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) error('Topilmadi', 404);
    $row['price']    = (float)$row['price'];
    $row['in_stock'] = (bool)$row['in_stock'];
    success($row);
}

function create(PDO $db): void {
    $auth = getAuthUser();
    $body = getBody();
    foreach (['name', 'price'] as $f) {
        if (empty($body[$f])) error("$f kerak");
    }
    $stmt = $db->prepare(
        "INSERT INTO parts (seller_id, name, description, price, car_brand, car_model, in_stock, created_at)
         VALUES (?, ?, ?, ?, ?, ?, 1, NOW())"
    );
    $stmt->execute([
        $auth['id'],
        $body['name'],
        $body['description'] ?? '',
        $body['price'],
        $body['car_brand']   ?? '',
        $body['car_model']   ?? '',
    ]);
    success(['id' => (int)$db->lastInsertId()], 'Yaratildi', 201);
}

function update(PDO $db, int $id): void {
    $auth  = getAuthUser();
    $body  = getBody();
    $chk   = $db->prepare("SELECT id FROM parts WHERE id = ? AND seller_id = ?");
    $chk->execute([$id, $auth['id']]);
    if (!$chk->fetch() && $auth['role'] !== 'admin') error('Ruxsat yo\'q', 403);

    $allowed = ['name', 'description', 'price', 'car_brand', 'car_model', 'in_stock'];
    $fields  = [];
    $params  = [];
    foreach ($allowed as $f) {
        if (isset($body[$f])) { $fields[] = "$f = ?"; $params[] = $body[$f]; }
    }
    if (!$fields) error('O\'zgartirish yo\'q');
    $params[] = $id;
    $db->prepare("UPDATE parts SET " . implode(', ', $fields) . " WHERE id = ?")->execute($params);
    success(null, 'Yangilandi');
}

function delete(PDO $db, int $id): void {
    $auth = getAuthUser();
    $chk  = $db->prepare("SELECT id FROM parts WHERE id = ? AND seller_id = ?");
    $chk->execute([$id, $auth['id']]);
    if (!$chk->fetch() && $auth['role'] !== 'admin') error('Ruxsat yo\'q', 403);
    $db->prepare("DELETE FROM parts WHERE id = ?")->execute([$id]);
    success(null, "O'chirildi");
}
