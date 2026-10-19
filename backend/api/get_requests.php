<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/db_connection.php';

try {
    $connection = getDatabaseConnection();
    $statement = $connection->query(
        'SELECT id, title, category, description, status, created_at
         FROM service_requests
         ORDER BY created_at DESC, id DESC
         LIMIT 20'
    );

    echo json_encode([
        'success' => true,
        'requests' => $statement->fetchAll(),
    ], JSON_THROW_ON_ERROR);
} catch (Throwable $error) {
    http_response_code(503);
    echo json_encode([
        'success' => false,
        'error' => 'The request list is temporarily unavailable.',
    ]);
}
