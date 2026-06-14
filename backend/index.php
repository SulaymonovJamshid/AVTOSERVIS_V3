<?php
// backend/index.php  — Asosiy router
// Apache: mod_rewrite yoki Nginx: try_files kerak

require_once __DIR__ . '/config/helpers.php';
setCors();

$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri    = trim(str_replace('/api', '', $uri), '/');
$parts  = explode('/', $uri);
$endpoint = $parts[0] ?? '';

// id ni GET parametriga joylash
if (!empty($parts[1]) && is_numeric($parts[1])) {
    $_GET['id'] = $parts[1];
}

match ($endpoint) {
    'auth'     => require __DIR__ . '/api/auth.php',
    'services' => require __DIR__ . '/api/services.php',
    'bookings' => require __DIR__ . '/api/bookings.php',
    'reviews'  => require __DIR__ . '/api/reviews.php',
    'parts'    => require __DIR__ . '/api/parts.php',
    'health'   => success(['status' => 'ok', 'version' => '1.0.0']),
    default    => error("Route topilmadi: $endpoint", 404),
};
