<?php
require_once '../conn.php';
require_once '../headers.php';

$id = $_GET['id'];

if (!$id){
    echo json_encode(['success' => false, 'error' => 'Missing parameters']);
    exit;
}

$conn = db_connect();

// Get
$stmt = $conn->prepare('SELECT * FROM quizzes WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0){
    echo json_encode(['success' => false, 'error' => 'Quiz not found']);
    exit;
}

$quiz = $result->fetch_assoc();

echo json_encode([
    'success' => true,
    'quiz' => $quiz
]);

$conn->close();
