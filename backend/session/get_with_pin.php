<?php
require_once "../conn.php";
require_once "../headers.php";

$pin = $_GET["pin"] ?? null;

if (!$pin) {
    echo json_encode(["success" => false, "error" => "Missing parameters"]);
    exit();
}

$conn = db_connect();

$stmt = $conn->prepare("
    SELECT s.*, q.name as 'quiz_name'
    FROM sessions s
    JOIN quizzes q ON s.quiz_id = q.id
    WHERE s.code = ?
");
$stmt->bind_param("s", $pin);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "error" => "Invalid pin"]);
    $stmt->close();
    $conn->close();
    exit();
}

$sessions = $result->fetch_assoc();

echo json_encode(["success" => true, "session" => $sessions]);

$stmt->close();
$conn->close();
