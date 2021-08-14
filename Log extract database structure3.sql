
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema hacdata
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema hacdata
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `hacdata` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema tree
-- -----------------------------------------------------
USE `hacdata` ;

-- -----------------------------------------------------
-- Table `hacdata`.`group`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`group` (
  `group_id` VARCHAR(20) NOT NULL,
  `group_name` VARCHAR(40) NULL,
  PRIMARY KEY (`group_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hacdata`.`cluster`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`cluster` (
  `cluster_id` VARCHAR(20) NOT NULL,
  `cluster_name` VARCHAR(20) NULL,
  PRIMARY KEY (`cluster_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hacdata`.`node`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`node` (
  `node_id` INT NOT NULL,
  `server` VARCHAR(30) NULL,
  PRIMARY KEY (`node_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hacdata`.`resource_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`resource_type` (
  `resource_type` VARCHAR(20) NOT NULL,
  `reinitialization_factor` INT NULL,
  PRIMARY KEY (`resource_type`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hacdata`.`configuration`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`configuration` (
  `resource_id` VARCHAR(16) NOT NULL,
  `resource_name` VARCHAR(30) NULL,
  `HAC_resource_name` VARCHAR(30) NULL,
  `group_group_id` VARCHAR(20) NOT NULL,
  `cluster_cluster_id` VARCHAR(20) NOT NULL,
  `node_node_id` INT NOT NULL,
  `resource_type_resource_type` VARCHAR(20) NOT NULL,
  `reinitialization_factor` INT NULL,
  `redundancy_factor` INT NULL,
  `dependency_type` INT NULL,
  `critical_factor` INT NULL,
  `dependency_level` INT NULL,
  `dependency_depth` INT NULL,
  `dependency_levels_up` INT NULL,
  `dependency_levels_down` INT NULL,
  PRIMARY KEY (`resource_id`),
  INDEX `fk_configuration_group_idx` (`group_group_id` ASC) VISIBLE,
  INDEX `fk_configuration_cluster1_idx` (`cluster_cluster_id` ASC) VISIBLE,
  INDEX `fk_configuration_node1_idx` (`node_node_id` ASC) VISIBLE,
  INDEX `fk_configuration_resource_type1_idx` (`resource_type_resource_type` ASC) VISIBLE,
  CONSTRAINT `fk_configuration_group`
    FOREIGN KEY (`group_group_id`)
    REFERENCES `hacdata`.`group` (`group_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_configuration_cluster1`
    FOREIGN KEY (`cluster_cluster_id`)
    REFERENCES `hacdata`.`cluster` (`cluster_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_configuration_node1`
    FOREIGN KEY (`node_node_id`)
    REFERENCES `hacdata`.`node` (`node_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_configuration_resource_type1`
    FOREIGN KEY (`resource_type_resource_type`)
    REFERENCES `hacdata`.`resource_type` (`resource_type`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hacdata`.`HAC_main`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hacdata`.`HAC_main` (
  `entry_id` INT NOT NULL AUTO_INCREMENT,
  `configuration_resource_id` VARCHAR(16) NOT NULL,
  `resource_name` VARCHAR(30) NULL,
  `HAC_resource_name` VARCHAR(30) NULL,
  `group_id` VARCHAR(20) NULL,
  `cluster_id` VARCHAR(20) NULL,
  `node_id` INT NULL,
  `error_message` VARCHAR(100) NULL,
  `event_date` DATETIME NULL,
  `current_state` VARCHAR(16) NULL,
  `aggeregated_failure_count` INT NULL,
  `failure_repetition` INT NULL,
  `error_rating` INT NULL,
  `dependency_factor` INT NULL,
  INDEX `fk_HAC_main_configuration1_idx` (`configuration_resource_id` ASC) VISIBLE,
  PRIMARY KEY (`entry_id`),
  CONSTRAINT `fk_HAC_main_configuration1`
    FOREIGN KEY (`configuration_resource_id`)
    REFERENCES `hacdata`.`configuration` (`resource_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
