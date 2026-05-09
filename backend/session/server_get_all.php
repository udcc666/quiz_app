<?php
require_once "../conn.php";
require_once "../headers.php";

$conn = db_connect();

$stmt = $conn->prepare("
  SELECT * FROM sessions
  where status != 'FINISHED';
");
$stmt->execute();

$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
  $stmt = $conn->prepare("
    SELECT * FROM sessions
    where status != 'FINISHED';
  ");
  $stmt->execute();
  
  $sessions[] = $row;
}

echo json_encode(["success" => true, "sessions" => $sessions]);

$stmt->close();
$conn->close();
