<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/db_connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Use POST to submit a request.']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$title = trim(is_array($input) ? ($input['title'] ?? '') : '');
$category = trim(is_array($input) ? ($input['category'] ?? '') : '');
$description = trim(is_array($input) ? ($input['description'] ?? '') : '');
$allowedCategories = ['Technology', 'Facilities', 'Student Services', 'Other'];

if ($title === '' || strlen($title) > 120) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Title is required (up to 120 characters).']);
    exit;
}

if (!in_array($category, $allowedCategories, true)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Choose a valid request category.']);
    exit;
}

if ($description === '' || strlen($description) > 1000) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Details are required (up to 1000 characters).']);
    exit;
}

try {
    $connection = getDatabaseConnection();
    $statement = $connection->prepare(
        'INSERT INTO service_requests (title, category, description)
         VALUES (:title, :category, :description)'
    );
    $statement->execute([
        'title' => $title,
        'category' => $category,
        'description' => $description,
    ]);

    http_response_code(201);
    echo json_encode(['success' => true, 'message' => 'Request submitted.']);
} catch (Throwable $error) {
    http_response_code(503);
    echo json_encode([
        'success' => false,
        'error' => 'Your request could not be saved right now. Please try again.',
    ]);
}
