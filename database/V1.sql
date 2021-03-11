-- MySQL Script generated by MySQL Workbench
-- dom 07 mar 2021 21:17:44
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ferrocene
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `group`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `group` (
  `uuid` BINARY(16) NOT NULL,
  `name` VARCHAR(190) NOT NULL,
  `comments` MEDIUMTEXT NOT NULL,
  PRIMARY KEY (`uuid`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `name_UNIQUE` ON `group` (`name` ASC);


-- -----------------------------------------------------
-- Table `app`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app` (
  `uuid` BINARY(16) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `url` VARCHAR(1024) NOT NULL,
  `users_group` BINARY(16) NOT NULL,
  `key` MEDIUMBLOB NOT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_app_group1`
    FOREIGN KEY (`users_group`)
    REFERENCES `group` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `users_group_UNIQUE` ON `app` (`users_group` ASC);

CREATE INDEX `fk_app_group1` ON `app` (`users_group` ASC);


-- -----------------------------------------------------
-- Table `audit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `audit` (
  `audit_id` INT(11) NOT NULL AUTO_INCREMENT,
  `ip_addr` VARBINARY(16) NULL DEFAULT NULL COMMENT 'Use INET6_ATON and INET6_ATON',
  `when` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `subject_uuid` BINARY(16) NULL DEFAULT NULL,
  `level` CHAR(1) NOT NULL,
  `msg_code` VARCHAR(190) NOT NULL,
  `msg` MEDIUMTEXT NOT NULL,
  `kv` MEDIUMBLOB NULL DEFAULT NULL,
  PRIMARY KEY (`audit_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE INDEX `subject_uuid_IDX` ON `audit` (`subject_uuid` ASC);

CREATE INDEX `ip_addr_IDX` ON `audit` (`ip_addr` ASC);

CREATE INDEX `when_IDX` ON `audit` (`when` ASC);


-- -----------------------------------------------------
-- Table `group_members`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `group_members` (
  `group_uuid` BINARY(16) NOT NULL,
  `member_uuid` BINARY(16) NOT NULL,
  `when` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`group_uuid`, `member_uuid`),
  CONSTRAINT `fk_group_members_group`
    FOREIGN KEY (`group_uuid`)
    REFERENCES `group` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `object_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `object_type` (
  `uuid` BINARY(16) NOT NULL,
  `type` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`uuid`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `kv`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `kv` (
  `row_id` INT(11) NOT NULL AUTO_INCREMENT,
  `uuid` BINARY(16) NOT NULL,
  `key` VARCHAR(190) NOT NULL,
  `val` VARCHAR(190) NULL DEFAULT NULL,
  `val_extra` MEDIUMBLOB NULL DEFAULT NULL,
  PRIMARY KEY (`row_id`),
  CONSTRAINT `fk_kv_object_type1`
    FOREIGN KEY (`uuid`)
    REFERENCES `object_type` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE INDEX `uuid_IDX` ON `kv` (`uuid` ASC);

CREATE INDEX `key_IDX` ON `kv` (`key` ASC);

CREATE INDEX `fk_kv_object_type1` ON `kv` (`uuid` ASC);


-- -----------------------------------------------------
-- Table `user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `uuid` BINARY(16) NOT NULL,
  `display_name` VARCHAR(30) NOT NULL,
  `added` DATETIME NOT NULL DEFAULT NOW(),
  `last_login` DATETIME NULL,
  PRIMARY KEY (`uuid`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;


-- -----------------------------------------------------
-- Table `login_handle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `login_handle` (
  `login_handle` VARCHAR(190) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `kind` VARCHAR(50) NOT NULL DEFAULT 'OTHER',
  `added` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`login_handle`),
  CONSTRAINT `fk_login_handle_user`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE INDEX `user_uuid_IDX` ON `login_handle` (`user_uuid` ASC);

CREATE INDEX `fk_login_handle_user` ON `login_handle` (`user_uuid` ASC);


-- -----------------------------------------------------
-- Table `sessions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sessions` (
  `uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `real_user_uuid` BINARY(16) NOT NULL,
  `login_time` DATETIME NOT NULL DEFAULT NOW(),
  `last_used` DATETIME NOT NULL DEFAULT NOW(),
  `remember_me` TINYINT NOT NULL DEFAULT 0,
  `ip_addr` VARCHAR(50) NOT NULL,
  `user_agent` VARCHAR(190) NOT NULL,
  `data` JSON NOT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_sessions_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_sessions_user2`
    FOREIGN KEY (`real_user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE INDEX `fk_sessions_user1_idx` ON `sessions` (`user_uuid` ASC);

CREATE INDEX `fk_sessions_user1` ON `sessions` (`user_uuid` ASC);

CREATE INDEX `fk_sessions_user2_idx` ON `sessions` (`real_user_uuid` ASC);


-- -----------------------------------------------------
-- Table `basic_otp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `basic_otp` (
  `uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `algorithm` VARCHAR(16) NOT NULL,
  `codes` MEDIUMTEXT NOT NULL,
  `added` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `used` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_recovery_code_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_recovery_code_user1_idx` ON `basic_otp` (`user_uuid` ASC);

CREATE INDEX `fk_recovery_code_user1` ON `basic_otp` (`user_uuid` ASC);


-- -----------------------------------------------------
-- Table `auto_otp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `auto_otp` (
  `uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `algorithm` VARCHAR(10) NOT NULL,
  `key` VARBINARY(500) NOT NULL,
  `counter` INT NULL DEFAULT NULL COMMENT 'NULL if TOTP',
  `added` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `last_used` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_auto_otp_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_auto_otp_user1_idx` ON `auto_otp` (`user_uuid` ASC);

CREATE INDEX `fk_auto_otp_user1` ON `auto_otp` (`user_uuid` ASC);


-- -----------------------------------------------------
-- Table `webauthn`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `webauthn` (
  `uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `aaguid` BINARY(16) NULL DEFAULT NULL,
  `name` VARCHAR(180) NOT NULL,
  `counter` INT NOT NULL,
  `cloned` TINYINT NOT NULL DEFAULT 0,
  `allow_cloning` TINYINT NOT NULL DEFAULT 0,
  `cred_id` MEDIUMBLOB NOT NULL,
  `pub_key` MEDIUMBLOB NOT NULL,
  `added` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `last_used` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_webauthn_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_webauthn_user1_idx` ON `webauthn` (`user_uuid` ASC);

CREATE UNIQUE INDEX `name_UNIQUE` ON `webauthn` (`user_uuid` ASC, `name` ASC);

CREATE INDEX `fk_webauthn_user1` ON `webauthn` (`user_uuid` ASC);


-- -----------------------------------------------------
-- Table `scope`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `scope` (
  `uuid` BINARY(16) NOT NULL,
  `name` VARCHAR(190) NOT NULL,
  `desc` MEDIUMTEXT NOT NULL DEFAULT '',
  `keys` MEDIUMTEXT NOT NULL DEFAULT '[]',
  PRIMARY KEY (`uuid`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `name_UNIQUE` ON `scope` (`name` ASC);


-- -----------------------------------------------------
-- Table `app_user_scope`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_user_scope` (
  `app_uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `scope_uuid` BINARY(16) NOT NULL,
  `when` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`app_uuid`, `user_uuid`, `scope_uuid`),
  CONSTRAINT `fk_app_user_scope_app1`
    FOREIGN KEY (`app_uuid`)
    REFERENCES `app` (`uuid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_app_user_scope_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_app_user_scope_scope1`
    FOREIGN KEY (`scope_uuid`)
    REFERENCES `scope` (`uuid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_app_user_scope_user1_idx` ON `app_user_scope` (`user_uuid` ASC);

CREATE INDEX `fk_app_user_scope_scope1_idx` ON `app_user_scope` (`scope_uuid` ASC);

CREATE INDEX `fk_app_user_scope_user1` ON `app_user_scope` (`user_uuid` ASC);

CREATE INDEX `fk_app_user_scope_scope1` ON `app_user_scope` (`scope_uuid` ASC);


-- -----------------------------------------------------
-- Table `password`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `password` (
  `uuid` BINARY(16) NOT NULL,
  `user_uuid` BINARY(16) NOT NULL,
  `name` VARCHAR(45) NOT NULL DEFAULT 'Main Password',
  `algorithm` VARCHAR(16) NOT NULL,
  `password` VARCHAR(512) CHARACTER SET 'ascii' COLLATE 'ascii_general_ci' NOT NULL,
  `requires_2fa` TINYINT NOT NULL DEFAULT 1,
  `added` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `last_used` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  CONSTRAINT `fk_table1_user1`
    FOREIGN KEY (`user_uuid`)
    REFERENCES `user` (`uuid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_table1_user1_idx` ON `password` (`user_uuid` ASC);

CREATE INDEX `fk_table1_user1` ON `password` (`user_uuid` ASC);

CREATE UNIQUE INDEX `name_UNIQUE` ON `password` (`user_uuid` ASC, `name` ASC);


DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`group_BEFORE_INSERT` BEFORE INSERT ON `group` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'GROUP');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`group_BEFORE_DELETE` BEFORE DELETE ON `group` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`app_BEFORE_INSERT` BEFORE INSERT ON `app` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'APP');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`app_BEFORE_DELETE` BEFORE DELETE ON `app` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`user_BEFORE_INSERT` BEFORE INSERT ON `user` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'USER');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`user_BEFORE_DELETE` BEFORE DELETE ON `user` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`sessions_BEFORE_INSERT` BEFORE INSERT ON `sessions` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'SESSION');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`sessions_BEFORE_DELETE` BEFORE DELETE ON `sessions` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`basic_otp_BEFORE_INSERT` BEFORE INSERT ON `basic_otp` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'B_OTP');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`basic_otp_BEFORE_DELETE` BEFORE DELETE ON `basic_otp` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`auto_otp_BEFORE_INSERT` BEFORE INSERT ON `auto_otp` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'A_OTP');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`auto_otp_BEFORE_DELETE` BEFORE DELETE ON `auto_otp` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`webauthn_BEFORE_INSERT` BEFORE INSERT ON `webauthn` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'WEBAUTHN');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`webauthn_BEFORE_DELETE` BEFORE DELETE ON `webauthn` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`scope_BEFORE_INSERT` BEFORE INSERT ON `scope` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'SCOPE');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`scope_BEFORE_DELETE` BEFORE DELETE ON `scope` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`password_BEFORE_INSERT` BEFORE INSERT ON `password` FOR EACH ROW
BEGIN
	INSERT INTO `object_type` (`uuid`, `type`) VALUES (NEW.`uuid`, 'PASSWORD');
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `ferrocene`.`password_BEFORE_DELETE` BEFORE DELETE ON `password` FOR EACH ROW
BEGIN
	DELETE FROM `object_type` WHERE `uuid` = OLD.`uuid`;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `user`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `user` (`uuid`, `display_name`, `added`, `last_login`) VALUES (0xD6FCB336EE52416D9AA04A0F7D59612C, 'Super Admin', NOW(), NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `login_handle`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `login_handle` (`login_handle`, `user_uuid`, `kind`, `added`) VALUES ('admin', 0xD6FCB336EE52416D9AA04A0F7D59612C, 'OTHER', NOW());

COMMIT;


-- -----------------------------------------------------
-- Data for table `scope`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `scope` (`uuid`, `name`, `desc`, `keys`) VALUES (0xBBFEF0381DF84BDFB39F3A447A4DECEA, 'Basic', 'User ID and display name', '[\'user.uuid\', \'user.display_name\']');
INSERT INTO `scope` (`uuid`, `name`, `desc`, `keys`) VALUES (0x2A86C74946F540928E7CD47EA7BA3E64, 'Email Address', 'Your email addresses', '[\'user.login_handle[kind=\\\'EMAIL\\\']\']');
INSERT INTO `scope` (`uuid`, `name`, `desc`, `keys`) VALUES (0xD940DB94C0F346708D88850A8BF0B740, 'Phone Number', 'Your phone and mobile numbers', '[\'user.login_handle[kind=\\\'PHONE\\\'|kind=\\\'MOBILE\\\']\']');
INSERT INTO `scope` (`uuid`, `name`, `desc`, `keys`) VALUES (0xDB935E386CFD4E6D90C1CAD84F7EA2EE, 'Login Names', 'All usernames except email address, phone and mobile numbers', '[\'user.login_handle[kind!=\\\'EMAIL\\\'&kind!=\\\'PHONE\\\'&kind!=\\\'MOBILE\\\']\']');

COMMIT;


-- -----------------------------------------------------
-- Data for table `password`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `password` (`uuid`, `user_uuid`, `name`, `algorithm`, `password`, `requires_2fa`, `added`, `last_used`) VALUES (0x3B2D4234E81448F0808BBBBF9B7BF5AB, 0xD6FCB336EE52416D9AA04A0F7D59612C, DEFAULT, 'Argon2', '$argon2id$v=19$m=4096,t=192,p=16$c2FsdHNhbHRzYWx0$tz06nxFEeiD7jm+po95x67Ky2K/4BstPcy+7flDnKt0', 0, DEFAULT, NULL);

COMMIT;

