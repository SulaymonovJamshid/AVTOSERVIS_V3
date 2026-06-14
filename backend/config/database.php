<?php
// backend/config/database.php

class Database {
    private static ?PDO $conn = null;

    private string $host     = 'localhost';
    private string $db_name  = 'avtogram_db';
    private string $username = 'root';
    private string $password = '';

    public function getConnection(): PDO {
        if (self::$conn !== null) return self::$conn;
        try {
            self::$conn = new PDO(
                "mysql:host={$this->host};dbname={$this->db_name};charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ]
            );
        } catch (PDOException $e) {
            http_response_code(500);
            die(json_encode(['success' => false, 'message' => 'DB ulanish xatosi']));
        }
        return self::$conn;
    }
}
