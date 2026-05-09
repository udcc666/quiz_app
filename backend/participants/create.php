<?php
require_once "../conn.php";
require_once "../headers.php";

$data = json_decode(file_get_contents("php://input"), true);

$session_id = $data["session_id"] ?? ($_POST["session_id"] ?? null);
$username = $data["username"] ?? ($_POST["username"] ?? null);
$recovery_code = $data["recovery_code"] ?? ($_POST["recovery_code"] ?? null);
$started_at = $data["started_at"] ?? ($_POST["started_at"] ?? null);

if (
  is_null($session_id) ||
  is_null($username) ||
  is_null($recovery_code) ||
  is_null($started_at)
) {
  echo json_encode(["success" => false, "error" => "Missing parameters"]);
  exit();
}

$conn = db_connect();

// Check userName exists
$stmt = $conn->prepare(
  "SELECT * FROM participants WHERE session_id = ? AND username = ? LIMIT 1",
);
$stmt->bind_param("is", $session_id, $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
  echo json_encode(["success" => false, "error" => "Username already in use"]);
  $stmt->close();
  $conn->close();
  exit();
}

// Add participant
$stmt = $conn->prepare('
  INSERT INTO participants (session_id, username, recovery_code, started_at)
  VALUES (?, ?, ?, ?)');
$stmt->bind_param(
  "isss",
  $session_id,
  $username,
  $recovery_code,
  $started_at,
);
$stmt->execute();

echo json_encode([
  "success" => true,
  "participant_id" => $stmt->insert_id,
]);

$stmt->close();
$conn->close();
