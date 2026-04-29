<?php

function db_connect(){
  $servername = "localhost";
  $username = "root";
  $password = "";
  $dbname = "quiz_app";

  $conn = new mysqli($servername, $username, $password, $dbname);
  $conn->set_charset("utf8mb4");

  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }
  return $conn;
}

/*
  Table quizzes:
    name(varchar 100), 
    description(varchar 500)
    host_controlled(bool: true): host controls current question
    duration(int/null): in seconds, 
    allow_late_entry(bool: true),
    catch_up(bool: true): late user goes to host question or to the start
  
  Table questions:
    quiz_id(int),
    question(varchar 512),
    image_url(varchar 512),
    position(int),
    duration(int): in seconds,
    score(int: 1),

  Table answers:
    question_id(int),
    answer(varchar 320),
    is_correct(bool: 0),
    position(int),
  
  Table users:
    email(varchar 320),
    password_hash(varchar 255),

  Table sessions:
    quiz_id(int),
    host_id(int),
    code(varchar 10),
    current_question(int/null: null),
    status(enum ('LOBBY','ACTIVE','FINISHED'): 'LOBBY'),
    # and all settings from quiz

  Table participants:
    quiz_id(int),
    current_question(int),
    username(varchar 100),
    recovery_code(varchar 15),
    score(int: 0),
    finished(bool: false),
    started_at(TIMESTAMP: CURRENT_TIMESTAMP),

  Table user_answers:
    participant_id(int),
    question_id(int),
    answer_id(int/null),
    response_time(bigint): Response time in miliseconds,
  
*/