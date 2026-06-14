<?php
// backend/api/reviews.php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

setCors();
$db     = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

match ($method) {
    'GET'    => getReviews($db),
    'POST'   => addReview($db),
    'DELETE' => deleteReview($db),
    default  => error('Method not allowed', 405),
};

function getReviews(PDO $db): void {
    $serviceId = (int)($_GET['service_id'] ?? 0);
    if (!$serviceId) error('service_id kerak');
    $stmt = $db->prepare(
        "SELECT r.*, u.name AS user_name, u.avatar AS user_avatar
         FROM reviews r
         JOIN users u ON u.id = r.user_id
         WHERE r.service_id = ?
         ORDER BY r.created_at DESC"
    );
    $stmt->execute([$serviceId]);
    success($stmt->fetchAll());
}

function addReview(PDO $db): void {
    $auth = getAuthUser();
    $body = getBody();
    $serviceId = (int)($body['service_id'] ?? 0);
    $rating    = (int)($body['rating']     ?? 0);
    $comment   = trim($body['comment']     ?? '');

    if (!$serviceId || !$rating || !$comment) error('Barcha maydonlar kerak');
    if ($rating < 1 || $rating > 5) error('Reyting 1-5 orasida bo\'lishi kerak');

    // One review per user per service
    $chk = $db->prepare("SELECT id FROM reviews WHERE user_id = ? AND service_id = ?");
    $chk->execute([$auth['id'], $serviceId]);
    if ($chk->fetch()) error('Siz bu servisga allaqachon izoh qoldirdingiz');

    $stmt = $db->prepare(
        "INSERT INTO reviews (user_id, service_id, rating, comment, created_at)
         VALUES (?, ?, ?, ?, NOW())"
    );
    $stmt->execute([$auth['id'], $serviceId, $rating, $comment]);
    success(['id' => (int)$db->lastInsertId()], 'Izoh qo\'shildi', 201);
}

function deleteReview(PDO $db): void {
    requireRole('admin');
    $id = (int)($_GET['id'] ?? 0);
    if (!$id) error('id kerak');
    $db->prepare("DELETE FROM reviews WHERE id = ?")->execute([$id]);
    success(null, 'O\'chirildi');
}
