<?php
require_once '../conn.php';
require_once '../headers.php';

$conn = db_connect();

// Get
$result = $conn->query('SELECT id, name, description FROM quizzes');

$quizzes = array();

while($quiz = $result->fetch_assoc()){
	$quizzes[] = [
        'id' => $quiz['id'],
        'name' => $quiz['name'],
        'description' => $quiz['description']
    ];
}

echo json_encode([
    'success' => true,
    'quizzes' => $quizzes
]);

$conn->close();
