<?php
require_once "../conn.php";
require_once "../headers.php";

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data["user_id"] ?? ($_POST["user_id"] ?? null);

if (!$user_id) {
    echo json_encode(["success" => false, "error" => "Missing parameters"]);
    exit();
}

$conn = db_connect();

$stmt = $conn->prepare("
    SELECT s.*, q.name as 'quiz_name'
    FROM sessions s
    JOIN quizzes q ON s.quiz_id = q.id
    WHERE s.host_id = ?
    ORDER BY 
        FIELD(s.status, 'LOBBY', 'ACTIVE', 'FINISHED', ''), 
        s.quiz_id ASC
");
$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
    $sessions[] = $row;
}

echo json_encode(["success" => true, "sessions" => $sessions]);

$stmt->close();
$conn->close();
