<?php

function getDatabaseConnection(): PDO
{
    $config = is_readable('/etc/hello-world/db.env')
        ? parse_ini_file('/etc/hello-world/db.env')
        : [];

    $host = $config['DB_HOST'] ?? getenv('DB_HOST');
    $database = $config['DB_NAME'] ?? (getenv('DB_NAME') ?: 'hello_world');
    $username = $config['DB_USER'] ?? getenv('DB_USER');
    $password = $config['DB_PASSWORD'] ?? getenv('DB_PASSWORD');

    if (!$host || !$username || !$password) {
        throw new RuntimeException('Database configuration is missing.');
    }

    $dsn = "mysql:host={$host};dbname={$database};charset=utf8mb4";
    return new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}
