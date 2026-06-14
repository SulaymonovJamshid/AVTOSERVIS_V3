<?php
// backend/config/helpers.php

define('JWT_SECRET', 'avtogram_super_secret_key_2026');
define('JWT_EXPIRE', 60 * 60 * 24 * 30); // 30 kun

// ─── CORS ────────────────────────────────────────────────────────────────────
function setCors(): void {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Content-Type: application/json; charset=UTF-8');
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

// ─── Response helpers ────────────────────────────────────────────────────────
function success(mixed $data = null, string $message = 'OK', int $code = 200): void {
    http_response_code($code);
    echo json_encode(['success' => true, 'message' => $message, 'data' => $data]);
    exit;
}

function error(string $message = 'Xatolik', int $code = 400): void {
    http_response_code($code);
    echo json_encode(['success' => false, 'message' => $message]);
    exit;
}

// ─── Simple JWT ──────────────────────────────────────────────────────────────
function generateToken(array $payload): string {
    $header  = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
    $payload['exp'] = time() + JWT_EXPIRE;
    $payload = base64_encode(json_encode($payload));
    $sig     = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    return "$header.$payload.$sig";
}

function verifyToken(string $token): ?array {
    $parts = explode('.', $token);
    if (count($parts) !== 3) return null;
    [$header, $payload, $sig] = $parts;
    $expected = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    if (!hash_equals($expected, $sig)) return null;
    $data = json_decode(base64_decode($payload), true);
    if (!$data || $data['exp'] < time()) return null;
    return $data;
}

function getAuthUser(): array {
    $auth = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (!str_starts_with($auth, 'Bearer ')) error('Token topilmadi', 401);
    $token = substr($auth, 7);
    $user  = verifyToken($token);
    if (!$user) error('Token yaroqsiz yoki muddati tugagan', 401);
    return $user;
}

function requireRole(string ...$roles): array {
    $user = getAuthUser();
    if (!in_array($user['role'], $roles)) error('Ruxsat yo\'q', 403);
    return $user;
}

// ─── Request body ────────────────────────────────────────────────────────────
function getBody(): array {
    return json_decode(file_get_contents('php://input'), true) ?? [];
}

// ─── Haversine distance (km) ─────────────────────────────────────────────────
function haversine(float $lat1, float $lng1, float $lat2, float $lng2): float {
    $R = 6371;
    $dLat = deg2rad($lat2 - $lat1);
    $dLng = deg2rad($lng2 - $lng1);
    $a = sin($dLat / 2) ** 2
       + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
    return round($R * 2 * atan2(sqrt($a), sqrt(1 - $a)), 2);
}
