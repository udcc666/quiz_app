<?php
require 'vendor/autoload.php';

require_once '../conn.php';
require_once '../headers.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = $data['email'] ?? $_POST['email'] ?? null;
$password = $data['password'] ?? $_POST['password'] ?? null;

if (!$email || !$password) {
    echo json_encode(['sucess' => false, 'error' => 'Missing parameters']);
    exit;
}

$conn = db_connect();

// Check email
$checkEmail = $conn->prepare('SELECT id, username FROM users WHERE email = ?');
$checkEmail->bind_param('s', $email);
$checkEmail->execute();
$result = $checkEmail->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['sucess' => false, 'error' => 'Invalid email or password']);
    exit;
}

$user = $result->fetch_assoc();

// Check password
if ($password === $user['password']){
    echo json_encode([
        'success' => true,
        'user_id' => $user['id'],
        'username' => $user['username']
    ]);
}else{
    echo json_encode(['sucess' => false, 'error' => 'Invalid email or password']);
}

$stmt->close();
$conn->close();
