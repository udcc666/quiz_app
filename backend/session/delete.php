<?php
require_once '../conn.php';
require_once '../headers.php';


$data = json_decode(file_get_contents("php://input"), true);

$pin = $data['pin'] ?? $_POST['pin'] ?? null;

if (is_null($pin)) {
    echo json_encode(['success' => false, 'error' => 'Missing parameters']);
    exit;
}

$conn = db_connect();

$stmt = $conn->prepare('DELETE FROM sessions WHERE code = ?');
$stmt->bind_param('i', $pin);
$stmt->execute();

echo json_encode(['success' => true]);

$stmt->close();
$conn->close();