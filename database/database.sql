-- phpMyAdmin SQL Dump
-- version 4.2.7.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: 
-- Версия на сървъра: 5.6.20
-- PHP Version: 5.5.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `test`
--

-- --------------------------------------------------------

--
-- Структура на таблица `task`
--

CREATE TABLE IF NOT EXISTS `task` (
  `id` tinyint(4) NOT NULL,
  `number_of_jobs` int(11) NOT NULL,
  `type_of_job` char(1) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Схема на данните от таблица `task`
--

INSERT INTO `task` (`id`, `number_of_jobs`, `type_of_job`) VALUES
(0, 1, 'A'),
(1, 3, 'B');

--
-- Тригери `task`
--
DELIMITER //
CREATE TRIGGER `record_data` AFTER UPDATE ON `task`
 FOR EACH ROW BEGIN
    DECLARE _action,_flag int(10);
    SET _action=0;
    SET _flag=0;
    SELECT flag INTO _flag FROM task_monitor LIMIT 1;
    IF _flag>0 THEN BEGIN
      IF NEW.number_of_jobs<OLD.number_of_jobs THEN BEGIN
        SET _action = 1;
      END; END IF;

      insert into task_metrics (type_of_job,action) value (NEW.type_of_job,_action);
    END; END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура на таблица `task_metrics`
--

CREATE TABLE IF NOT EXISTS `task_metrics` (
`id` int(11) NOT NULL,
  `type_of_job` char(1) COLLATE utf8_unicode_ci NOT NULL,
  `action` smallint(6) NOT NULL
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=8 ;

--
-- Схема на данните от таблица `task_metrics`
--

INSERT INTO `task_metrics` (`id`, `type_of_job`, `action`) VALUES
(4, 'A', 1),
(5, 'A', 0),
(6, 'A', 1),
(7, 'B', 0);

-- --------------------------------------------------------

--
-- Структура на таблица `task_monitor`
--

CREATE TABLE IF NOT EXISTS `task_monitor` (
  `flag` smallint(6) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Схема на данните от таблица `task_monitor`
--

INSERT INTO `task_monitor` (`flag`) VALUES
(1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `task`
--
ALTER TABLE `task`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_metrics`
--
ALTER TABLE `task_metrics`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_monitor`
--
ALTER TABLE `task_monitor`
 ADD PRIMARY KEY (`flag`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `task_metrics`
--
ALTER TABLE `task_metrics`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
