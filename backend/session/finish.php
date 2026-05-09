<?php
require_once "../conn.php";
require_once "../headers.php";

$data = json_decode(file_get_contents("php://input"), true);

$pin = $data["pin"] ?? ($_POST["pin"] ?? null);

if (is_null($pin)) {
  echo json_encode(["success" => false, "error" => "Missing parameters"]);
  exit();
}

$conn = db_connect();

// Get session
$stmt = $conn->prepare(
  "SELECT id, status FROM sessions WHERE code = ? LIMIT 1",
);
$stmt->bind_param("i", $pin);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode(["success" => false, "error" => "Session not found"]);
  $stmt->close();
  $conn->close();
  exit();
}

$session = $result->fetch_assoc();

if ($session["status"] === "finished") {
  echo json_encode(["success" => false, "error" => "Session already finished"]);
  $stmt->close();
  $conn->close();
  exit();
}

// Update status
$stmt = $conn->prepare('UPDATE sessions SET status="finished" WHERE id = ?');
$stmt->bind_param("i", $session["id"]);
$stmt->execute();

echo json_encode(["success" => true]);

$stmt->close();
$conn->close();
