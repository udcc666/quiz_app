<?php
require_once '../conn.php';
require_once '../headers.php';

$id = $_GET['id'] ?? null;

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

// Get questions
$stmt = $conn->prepare('SELECT * FROM questions WHERE quiz_id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
$result = $stmt->get_result();

$questions = [];

while ($row = $result->fetch_assoc()){
    // Get answers
    $stmt = $conn->prepare('SELECT answer, is_correct FROM answers WHERE question_id = ? ORDER BY position');
    $stmt->bind_param('i', $row['id']);
    $stmt->execute();
    $aResult = $stmt->get_result();

    $answers = [];

    while ($row1 = $aResult->fetch_assoc()){
        $answers[] = $row1;
    }
    $row['answers'] = $answers;

    $questions[] = $row;
}

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
        'questions' => $questions,
    ],
]);

$conn->close();
