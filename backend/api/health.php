<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/db_connection.php';

try {
    getDatabaseConnection()->query('SELECT 1');
    echo json_encode(['status' => 'ok']);
} catch (Throwable $error) {
    http_response_code(503);
    echo json_encode(['status' => 'unavailable']);
}
