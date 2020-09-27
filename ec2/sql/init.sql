CREATE USER 'dbuser'@'localhost' IDENTIFIED BY 'akvelon#cLoudUser2020';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'localhost' WITH GRANT OPTION;
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'akvelon#cLoudUser2020';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE SCHEMA `cloud_test` ;
CREATE TABLE `cloud_test`.`GlobalVariables` (
  `idGlobalVariables` INT NOT NULL AUTO_INCREMENT,
  `Name` NVARCHAR(20),
  `Comment` NVARCHAR(255) NULL,
  `Value` VARCHAR(255) NULL,
  PRIMARY KEY (`idGlobalVariables`),
  UNIQUE INDEX `Name_UNIQUE` (`Name` ASC));
INSERT INTO `cloud_test`.`GlobalVariables`
(`Name`,
`Value`)
VALUES
('VisitorsCounter',
'0');

USE `cloud_test`;
DROP procedure IF EXISTS `GetIncrementedVisitorsCounter`;

DELIMITER $$
USE `cloud_test`$$
CREATE PROCEDURE `GetIncrementedVisitorsCounter` ()
BEGIN
  DECLARE counter INT;
  SELECT convert(Value, UNSIGNED INTEGER)
  INTO counter
  FROM cloud_test.GlobalVariables
  WHERE Name = 'VisitorsCounter';
  SET counter = counter + 1;
  UPDATE cloud_test.GlobalVariables
  SET Value = convert(counter, CHAR)
  WHERE Name = 'VisitorsCounter';
  SELECT counter as IncrementedCounter;
END$$
