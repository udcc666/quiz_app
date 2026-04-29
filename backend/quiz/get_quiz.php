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
    'quiz' => [
        'id' => $quiz['id'],
        'name' => $quiz['name'],
        'description' => $quiz['description'],
        'host_controlled' => $quiz['host_controlled'] == '1',
        'allow_late_entry' => $quiz['allow_late_entry'] == '1',
        'max_clients' => $quiz['max_clients'],
        'show_leaderboard_between_questions' => $quiz['show_leaderboard_between_questions'] === '1',
        'show_answers' => $quiz['show_answers'] == '1',
        'duration' => $quiz['duration'],
        'start_at_host' => $quiz['start_at_host'] == '1',
    ],
]);

$conn->close();
