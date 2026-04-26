<?php
require_once '../conn.php';
require_once '../headers.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = $data['email'] ?? $_POST['email'] ?? null;
$password = $data['password'] ?? $_POST['password'] ?? null;

if (!$email || !$password) {
    echo json_encode(['success' => false, 'error' => 'Missing parameters']);
    exit;
}

$conn = db_connect();

// Check email and password
$stmt = $conn->prepare('SELECT id, username, password FROM users WHERE email = ?');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'error' => 'Invalid email or password']);
    $stmt->close();
    $conn->close();
    exit;
}

$user = $result->fetch_assoc();

// Check password
if (password_verify($password, $user['password'])){
    echo json_encode([
        'success' => true,
        'user_id' => $user['id'],
        'username' => $user['username'],
    ]);
} else {
    echo json_encode(['success' => false, 'error' => 'Invalid email or password']);
}

$stmt->close();
$conn->close();
