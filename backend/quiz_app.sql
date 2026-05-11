-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 11, 2026 at 11:20 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `quiz_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

CREATE TABLE `answers` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer` varchar(320) NOT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  `position` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `answers`
--

INSERT INTO `answers` (`id`, `question_id`, `answer`, `is_correct`, `position`) VALUES
(1, 1, 'J.R.R. Tolkien', 1, 1),
(2, 1, 'George R.R. Martin', 0, 2),
(3, 1, 'C.S. Lewis', 0, 3),
(4, 2, '1977', 1, 1),
(5, 2, '1980', 0, 2),
(6, 2, '1983', 0, 3),
(7, 3, 'Structured Query Language', 1, 1),
(8, 3, 'Simple Question Language', 0, 2),
(9, 3, 'Standard Query List', 0, 3),
(10, 4, 'DELETE', 0, 1),
(11, 4, 'TRUNCATE', 1, 2),
(12, 4, 'DROP', 0, 3);

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `current_question` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `recovery_code` varchar(15) NOT NULL,
  `score` int(11) NOT NULL DEFAULT 0,
  `finished` tinyint(1) NOT NULL DEFAULT 0,
  `started_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `participants`
--

INSERT INTO `participants` (`id`, `session_id`, `current_question`, `username`, `recovery_code`, `score`, `finished`, `started_at`) VALUES
(1, 1, 0, '9IVSQSW3B', '9IVSQSW3B', 0, 0, '2026-05-11 20:56:30');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `question` varchar(512) NOT NULL,
  `image_url` varchar(512) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL COMMENT 'In seconds',
  `score` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `quiz_id`, `question`, `image_url`, `position`, `duration`, `score`) VALUES
(1, 1, 'Quem é o autor de \"O Senhor dos Anéis\"?', NULL, 1, 20, 1),
(2, 1, 'Em que ano foi lançado Star Wars?', NULL, 2, 15, 1),
(3, 2, 'O que significa SQL?', NULL, 1, 60, 1),
(4, 2, 'Comando para apagar registros?', NULL, 2, 45, 2);

-- --------------------------------------------------------

--
-- Table structure for table `quizzes`
--

CREATE TABLE `quizzes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) NOT NULL,
  `host_controlled` tinyint(1) NOT NULL COMMENT 'Host controls current question',
  `allow_late_entry` tinyint(1) NOT NULL,
  `max_clients` int(11) DEFAULT NULL,
  `show_leaderboard_between_questions` tinyint(1) NOT NULL,
  `show_answers` tinyint(1) NOT NULL,
  `duration` bigint(20) DEFAULT NULL COMMENT 'In seconds',
  `start_at_host` tinyint(1) NOT NULL COMMENT 'Client starts at host or from the start'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `quizzes`
--

INSERT INTO `quizzes` (`id`, `name`, `description`, `host_controlled`, `allow_late_entry`, `max_clients`, `show_leaderboard_between_questions`, `show_answers`, `duration`, `start_at_host`) VALUES
(1, 'Campeonato Geek', 'Quiz pop', 1, 1, 50, 1, 1, NULL, 1),
(2, 'Fundamentos SQL', 'Banco de dados', 0, 1, NULL, 0, 1, 3600, 0);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `current_question` int(11) DEFAULT NULL,
  `status` enum('LOBBY','ACTIVE','FINISHED','') NOT NULL DEFAULT 'LOBBY',
  `host_controlled` tinyint(1) NOT NULL COMMENT 'Host controls current question',
  `allow_late_entry` tinyint(1) NOT NULL,
  `max_clients` int(11) DEFAULT NULL,
  `show_leaderboard_between_questions` tinyint(1) NOT NULL,
  `show_answers` tinyint(1) NOT NULL,
  `duration` bigint(20) DEFAULT NULL,
  `start_at_host` tinyint(1) NOT NULL COMMENT 'Client starts at host or from the start'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `quiz_id`, `host_id`, `code`, `current_question`, `status`, `host_controlled`, `allow_late_entry`, `max_clients`, `show_leaderboard_between_questions`, `show_answers`, `duration`, `start_at_host`) VALUES
(1, 2, 1, '9IVSQSW3B', NULL, 'LOBBY', 0, 1, NULL, 0, 1, 3600, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(320) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`) VALUES
(1, 'Nelson', 'udccnelson@gmail.com', '$2y$10$AM0SzycbqAktQ2Iw075LmOp0K7Uuwu4NQvo1fNtmm7UWiwHnzutfq');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_answers_questions` (`question_id`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_participants_sessions` (`session_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_questions_quizzes` (`quiz_id`);

--
-- Indexes for table `quizzes`
--
ALTER TABLE `quizzes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code_unique` (`code`),
  ADD KEY `idx_quiz` (`quiz_id`),
  ADD KEY `idx_host` (`host_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `answers`
--
ALTER TABLE `answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `quizzes`
--
ALTER TABLE `quizzes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `answers`
--
ALTER TABLE `answers`
  ADD CONSTRAINT `fk_answers_questions` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `participants`
--
ALTER TABLE `participants`
  ADD CONSTRAINT `fk_participants_sessions` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_questions_quizzes` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_sessions_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sessions_quizzes` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
