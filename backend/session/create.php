<?php
require_once '../conn.php';
require_once '../headers.php';

function generateSessionCode($lengthMin = 4, $lengthMax = 9) {
    $length = random_int($lengthMin, $lengthMax);
    
    $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $code = '';
    for ($i = 0; $i < $length; $i++) {
        $code .= $characters[random_int(0, strlen($characters) - 1)];
    }
    return $code;
}

$data = json_decode(file_get_contents("php://input"), true);

$quiz_id = $data['quiz_id'] ?? $_POST['quiz_id'] ?? null;
$host_id = $data['user_id'] ?? $_POST['host_id'] ?? null;

$settings = $data['settings'] ?? $_POST['settings'] ?? [];
$s = [];

// Conversão correta para 1 e 0
foreach ($settings as $key => $value) {
    if (is_bool($value)) {
        $s[$key] = $value ? 1 : 0;
    } else {
        $s[$key] = $value;
    }
}

$host_controlled = $s['host_controlled'] ?? null;
$allow_late_entry = $s['allow_late_entry'] ?? null;
$max_clients = $s['max_clients'] ?? null;
$show_leaderboard = $s['show_leaderboard_between_questions'] ?? null;
$show_answers = $s['show_answers'] ?? null;
$duration = $s['duration'] ?? null;
$start_at_host = $s['start_at_host'] ?? null;

if (
    is_null($quiz_id) || 
    is_null($host_id) || 
    is_null($host_controlled) || 
    is_null($allow_late_entry) || 
    is_null($show_leaderboard) || 
    is_null($show_answers) || 
    is_null($start_at_host)
) {
    echo json_encode(['success' => false, 'error' => 'Missing parameters']);
    exit;
}

$conn = db_connect();

// Check quiz exists
$stmt = $conn->prepare('SELECT * FROM quizzes WHERE id = ?');
$stmt->bind_param('i', $quiz_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'error' => 'Quiz not found']);
    $stmt->close();
    $conn->close();
    exit;
}

$stmt->close();

// Check host exists
$stmt = $conn->prepare('SELECT * FROM users WHERE id = ?');
$stmt->bind_param('i', $host_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'error' => 'Host not found']);
    $stmt->close();
    $conn->close();
    exit;
}

$stmt->close();

// Create unique code
$code = '';
$isUnique = false;

while (!$isUnique) {
    $code = generateSessionCode();
    $stmt = $conn->prepare('SELECT id FROM sessions WHERE code = ?');
    $stmt->bind_param('s', $code);
    $stmt->execute();
    if ($stmt->get_result()->num_rows === 0) {
        $isUnique = true;
    }
    $stmt->close();
}

// Create session
$stmt = $conn->prepare('INSERT INTO sessions (
    quiz_id, host_id, code, host_controlled, allow_late_entry, 
    max_clients, show_leaderboard_between_questions, show_answers, 
    duration, start_at_host
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');

$stmt->bind_param('iisiiiiiii', 
    $quiz_id, 
    $host_id, 
    $code, 
    $host_controlled, 
    $allow_late_entry, 
    $max_clients, 
    $show_leaderboard, 
    $show_answers, 
    $duration, 
    $start_at_host
);
$stmt->execute();

echo json_encode([
    'success' => true,
    'session_code' => $code,
]);

$conn->close();
