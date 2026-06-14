<?php
// backend/api/auth.php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

setCors();

$db     = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

match ($action) {
    'register' => register($db),
    'login'    => login($db),
    'me'       => me($db),
    'logout'   => success(null, 'Chiqildi'),
    default    => error('Noma\'lum action', 404),
};

// ─── Register ────────────────────────────────────────────────────────────────
function register(PDO $db): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('POST kerak', 405);

    $body = getBody();
    $name  = trim($body['name']  ?? '');
    $phone = trim($body['phone'] ?? '');
    $pass  = $body['password']   ?? '';
    $role  = in_array($body['role'] ?? '', ['user', 'owner']) ? $body['role'] : 'user';

    if (!$name || !$phone || !$pass) error('Barcha maydonlar kerak');
    if (strlen($pass) < 6) error('Parol kamida 6 ta belgi');

    // Check duplicate
    $chk = $db->prepare("SELECT id FROM users WHERE phone = ?");
    $chk->execute([$phone]);
    if ($chk->fetch()) error('Bu telefon raqam allaqachon ro\'yxatdan o\'tgan');

    $hash = password_hash($pass, PASSWORD_BCRYPT);
    $stmt = $db->prepare(
        "INSERT INTO users (name, phone, password, role, created_at)
         VALUES (?, ?, ?, ?, NOW())"
    );
    $stmt->execute([$name, $phone, $hash, $role]);
    $userId = (int)$db->lastInsertId();

    $token = generateToken(['id' => $userId, 'role' => $role]);

    success([
        'id'    => $userId,
        'name'  => $name,
        'phone' => $phone,
        'email' => '',
        'role'  => $role,
        'token' => $token,
    ], 'Ro\'yxatdan o\'tildi', 201);
}

// ─── Login ────────────────────────────────────────────────────────────────────
function login(PDO $db): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('POST kerak', 405);

    $body  = getBody();
    $phone = trim($body['phone']    ?? '');
    $pass  = $body['password']      ?? '';

    if (!$phone || !$pass) error('Telefon va parol kerak');

    $stmt = $db->prepare("SELECT * FROM users WHERE phone = ? AND is_blocked = 0");
    $stmt->execute([$phone]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($pass, $user['password'])) {
        error('Telefon yoki parol noto\'g\'ri', 401);
    }

    $token = generateToken(['id' => $user['id'], 'role' => $user['role']]);

    success([
        'id'     => $user['id'],
        'name'   => $user['name'],
        'phone'  => $user['phone'],
        'email'  => $user['email'] ?? '',
        'role'   => $user['role'],
        'avatar' => $user['avatar'] ?? null,
        'token'  => $token,
    ]);
}

// ─── Me ───────────────────────────────────────────────────────────────────────
function me(PDO $db): void {
    $auth = getAuthUser();

    $stmt = $db->prepare("SELECT id, name, phone, email, role, avatar FROM users WHERE id = ?");
    $stmt->execute([$auth['id']]);
    $user = $stmt->fetch();

    if (!$user) error('Foydalanuvchi topilmadi', 404);
    success($user);
}
