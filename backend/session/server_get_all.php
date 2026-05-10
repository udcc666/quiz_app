<?php
require_once "../conn.php";
require_once "../headers.php";

function get_participants($conn, $quiz_id) {
  $stmt = $conn->prepare("
    SELECT id, username, recovery_code
    FROM participants
    WHERE session_id = ?
  ");
  $stmt->bind_param("i", $quiz_id);
  $stmt->execute();
  $result = $stmt->get_result();

  $participants = $result->fetch_all(MYSQLI_ASSOC);

  $stmt->close();

  return $participants;
}

$conn = db_connect();

$stmt = $conn->prepare("
  SELECT s.id, s.quiz_id, q.name as 'quiz_name', s.host_id, s.code, s.status
  FROM sessions s
  JOIN quizzes q ON s.quiz_id = q.id
  WHERE status != 'FINISHED';
");
$stmt->execute();
$result = $stmt->get_result();

$sessions = $result->fetch_all(MYSQLI_ASSOC); 

foreach ($sessions as $key => $session) {
  $sessions[$key]['participants'] = get_participants($conn, $session['id']);
}

echo json_encode(["success" => true, "sessions" => $sessions]);

$stmt->close();
$conn->close();
