-- FindinG - Production Database Schema v2.0
-- Optimized with indexes, constraints, and security improvements

CREATE DATABASE IF NOT EXISTS project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE project;

-- Users table - with BCrypt passwords, indexes, constraints
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user` VARCHAR(50) NOT NULL PRIMARY KEY,
  `pwd` VARCHAR(255) NOT NULL COMMENT 'BCrypt hashed password',
  `fname` VARCHAR(100) NOT NULL,
  `lname` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `occ` ENUM('stu','hr') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` TIMESTAMP NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  UNIQUE KEY `idx_email` (`email`),
  KEY `idx_occ` (`occ`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Students table - optimized
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `user` VARCHAR(50) NOT NULL PRIMARY KEY,
  `age` TINYINT UNSIGNED,
  `mnum` VARCHAR(15),
  `fname` VARCHAR(100),
  `mname` VARCHAR(100),
  `addr` VARCHAR(255),
  `cid` VARCHAR(150) COMMENT 'College Name',
  `uid` VARCHAR(150) COMMENT 'University',
  `brch` VARCHAR(50) COMMENT 'Branch',
  `sem` TINYINT UNSIGNED,
  `10thb` VARCHAR(100) COMMENT '10th Board',
  `10thp` VARCHAR(10) COMMENT '10th Percentage',
  `12thb` VARCHAR(100) COMMENT '12th Board',
  `12thp` VARCHAR(10) COMMENT '12th Percentage',
  `t1` VARCHAR(100) COMMENT 'Major Technology',
  `c1` VARCHAR(150) COMMENT 'Major Company',
  `ds1` VARCHAR(50) COMMENT 'Duration Start',
  `de1` VARCHAR(50) COMMENT 'Duration End',
  `t2` VARCHAR(100) COMMENT 'Minor Technology',
  `c2` VARCHAR(150) COMMENT 'Minor Company',
  `ds2` VARCHAR(50),
  `de2` VARCHAR(50),
  `jid` VARCHAR(100) COMMENT 'Job Post Preference',
  `ja` VARCHAR(100) COMMENT 'Job Area',
  `jt` VARCHAR(100) COMMENT 'Job Type',
  `js` VARCHAR(50) COMMENT 'Job Salary',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user`) REFERENCES `user`(`user`) ON DELETE CASCADE,
  KEY `idx_cid` (`cid`),
  KEY `idx_brch` (`brch`),
  KEY `idx_t1` (`t1`),
  KEY `idx_jid` (`jid`),
  FULLTEXT KEY `ft_search` (`user`, `cid`, `uid`, `brch`, `t1`, `t2`, `jid`, `ja`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Companies table - optimized
DROP TABLE IF EXISTS `company`;
CREATE TABLE `company` (
  `user` VARCHAR(50) NOT NULL PRIMARY KEY,
  `cid` VARCHAR(150) NOT NULL COMMENT 'Company Name',
  `auth` VARCHAR(100) COMMENT 'Authorization',
  `yr` SMALLINT COMMENT 'Year Established',
  `emp` VARCHAR(50) COMMENT 'Total Employees',
  `hsal` VARCHAR(50) COMMENT 'Highest Salary',
  `brch` VARCHAR(20) COMMENT 'Branches',
  `addr` VARCHAR(255) COMMENT 'Head Office Address',
  `t1` VARCHAR(150) COMMENT 'Major Product Objective',
  `c1` VARCHAR(150) COMMENT 'Major Product Company',
  `y1` VARCHAR(10) COMMENT 'Created Year',
  `a1` VARCHAR(50) COMMENT 'Amount',
  `t2` VARCHAR(150) COMMENT 'Minor Product',
  `c2` VARCHAR(150),
  `y2` VARCHAR(10),
  `a2` VARCHAR(50),
  `jid` VARCHAR(100) COMMENT 'Major Job Post',
  `ja` VARCHAR(100) COMMENT 'Job Area',
  `jt` VARCHAR(100) COMMENT 'Job Type',
  `js` VARCHAR(50) COMMENT 'Salary',
  `jid2` VARCHAR(100) COMMENT 'Minor Job Post',
  `ja2` VARCHAR(100),
  `jt2` VARCHAR(100),
  `js2` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user`) REFERENCES `user`(`user`) ON DELETE CASCADE,
  KEY `idx_cid` (`cid`),
  KEY `idx_jid` (`jid`),
  KEY `idx_yr` (`yr`),
  FULLTEXT KEY `ft_search` (`user`, `cid`, `t1`, `t2`, `jid`, `jid2`, `jt`, `jt2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Demo data with BCrypt hashed passwords (password: Student@123 and Company@123)
-- BCrypt hash for 'Student@123' with work factor 12: $2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXC2x4hG
-- For demo, using plain placeholder that will be upgraded on first login
INSERT INTO `user` (user, pwd, fname, lname, email, occ) VALUES
('student1', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXC2x4hG', 'John', 'Doe', 'student1@example.com', 'stu'),
('company1', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNiLXC2x4hG', 'Tech', 'Corp', 'hr@techcorp.com', 'hr')
ON DUPLICATE KEY UPDATE email=VALUES(email);

INSERT INTO `student` (user, age, mnum, fname, mname, addr, cid, uid, brch, sem, `10thb`, `10thp`, `12thb`, `12thp`, t1, c1, ds1, de1, t2, c2, ds2, de2, jid, ja, jt, js) VALUES
('student1', 22, '9876543210', 'Robert Doe', 'Jane Doe', 'New Delhi', 'PIET', 'MDU', 'CSE', 6, 'CBSE', '85%', 'CBSE', '80%', 'Java', 'Infosys', '2023-01', '2023-06', 'Python', 'TCS', '2023-07', '2023-12', 'Software Engineer', 'Bangalore', 'Product Based', '8 LPA')
ON DUPLICATE KEY UPDATE cid=VALUES(cid);

INSERT INTO `company` (user, cid, auth, yr, emp, hsal, brch, addr, t1, c1, y1, a1, t2, c2, y2, a2, jid, ja, jt, js, jid2, ja2, jt2, js2) VALUES
('company1', 'TechCorp Solutions', 'AUTH123', 2010, '5000', '50 LPA', '12', 'Bangalore, Karnataka', 'AI Platform', 'Google', '2022', '2M', 'Mobile App', 'Amazon', '2023', '500K', 'Software Engineer', 'Bangalore', 'Full Time', '12 LPA', 'Intern', 'Remote', 'Internship', '30K')
ON DUPLICATE KEY UPDATE cid=VALUES(cid);

-- Performance: Add additional indexes for search
CREATE INDEX idx_student_search_composite ON student (brch, cid, t1);
CREATE INDEX idx_company_search_composite ON company (cid, jid, jt);

-- Security audit log (new feature)
CREATE TABLE IF NOT EXISTS audit_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user VARCHAR(50),
  action VARCHAR(100),
  ip_address VARCHAR(45),
  user_agent VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_user (user),
  KEY idx_action (action),
  KEY idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
