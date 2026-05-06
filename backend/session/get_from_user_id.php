<?php
require_once "../conn.php";
require_once "../headers.php";

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data["user_id"] ?? (_GET["user_id"] ?? null);

if (!$user_id) {
  echo json_encode(["success" => false, "error" => "Missing parameters"]);
  exit();
}

$conn = db_connect();

$stmt = $conn->prepare("SELECT * FROM sessions WHERE host_id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
  $sessions[] = $row;
}

echo json_encode(['success' => true, 'sessions' => $sessions]);

$stmt->close();
$conn->close();