-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2012 年 11 月 27 日 13:54
-- 服务器版本: 5.5.24
-- PHP 版本: 5.3.10-1ubuntu3.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `monitor`
--

-- --------------------------------------------------------

--
-- 表的结构 `vm_monitor`
--

CREATE TABLE IF NOT EXISTS `vm_monitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` char(20) NOT NULL,
  `cpu_usage` char(5) NOT NULL,
  `mem_free` int(11) NOT NULL,
  `mem_max` int(11) NOT NULL,
  `nic_in` char(200) NOT NULL,
  `nic_out` char(200) NOT NULL,
  `disk_read` char(200) NOT NULL,
  `disk_write` char(200) NOT NULL,
  `monitor_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid` char(40) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
