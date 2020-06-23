-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema oc_pizza_schema
-- -----------------------------------------------------
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`pizzeria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`pizzeria` ;

CREATE TABLE IF NOT EXISTS `mydb`.`pizzeria` (
  `id_pizzeria` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NULL,
  `zip_code` VARCHAR(45) NULL,
  `address` VARCHAR(255) NOT NULL,
  `localization` VARCHAR(40) NULL,
  `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pizzeria`));


-- -----------------------------------------------------
-- Table `mydb`.`employee`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`employee` ;

CREATE TABLE IF NOT EXISTS `mydb`.`employee` (
  `id_employee` INT NOT NULL AUTO_INCREMENT,
  `pizzeria_id_pizzeria` INT NOT NULL,
  `num_registration` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NULL,
  `entitlement` VARCHAR(50) NULL,
  `hire_date` DATE NULL,
  `password` VARCHAR(32) NOT NULL,
  `email` VARCHAR(255) NULL,
  `phone_number` VARCHAR(45) NULL,
  `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE INDEX `numReg_UNIQUE` (`num_registration` ASC) VISIBLE,
  PRIMARY KEY (`id_employee`, `pizzeria_id_pizzeria`),
  INDEX `fk_employee_pizerria1_idx` (`pizzeria_id_pizzeria` ASC) VISIBLE,
  CONSTRAINT `fk_employee_pizerria1`
    FOREIGN KEY (`pizzeria_id_pizzeria`)
    REFERENCES `mydb`.`pizzeria` (`id_pizzeria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`role` ;

CREATE TABLE IF NOT EXISTS `mydb`.`role` (
  `id_role` INT NOT NULL AUTO_INCREMENT,
  `id_parent` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `level` INT NULL,
  `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_role`, `id_parent`),
  INDEX `fk_role_role1_idx` (`id_parent` ASC) VISIBLE,
  CONSTRAINT `fk_role_role1`
    FOREIGN KEY (`id_parent`)
    REFERENCES `mydb`.`role` (`id_role`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `mydb`.`invoice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`invoice` ;

CREATE TABLE IF NOT EXISTS `mydb`.`invoice` (
  `id_invoice` INT NOT NULL AUTO_INCREMENT,
  `employee_id_employee` INT NOT NULL,
  `is_paid` TINYINT NULL DEFAULT 0,
  `is_on_place` TINYINT NULL,
  `payment_date` DATETIME NULL,
  `payment_mode` VARCHAR(45) NULL,
  PRIMARY KEY (`id_invoice`, `employee_id_employee`),
  INDEX `fk_invoice_employee1_idx` (`employee_id_employee` ASC) VISIBLE,
  CONSTRAINT `fk_invoice_employee1`
    FOREIGN KEY (`employee_id_employee`)
    REFERENCES `mydb`.`employee` (`id_employee`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`menu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`menu` ;

CREATE TABLE IF NOT EXISTS `mydb`.`menu` (
  `id_menu` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NULL,
  `price` DECIMAL NOT NULL,
  PRIMARY KEY (`id_menu`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`category` ;

CREATE TABLE IF NOT EXISTS `mydb`.`category` (
  `id_category` INT NOT NULL AUTO_INCREMENT,
  `id_category_parent` INT NOT NULL,
  `libelle` VARCHAR(100) NULL,
  PRIMARY KEY (`id_category`, `id_category_parent`),
  INDEX `fk_category_category1_idx` (`id_category_parent` ASC) VISIBLE,
  CONSTRAINT `fk_category_category1`
    FOREIGN KEY (`id_category_parent`)
    REFERENCES `mydb`.`category` (`id_category`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`menu_item`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`menu_item` ;

CREATE TABLE IF NOT EXISTS `mydb`.`menu_item` (
  `id_menu_item` INT NOT NULL AUTO_INCREMENT,
  `category_id_category` INT NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `unit_price` DECIMAL(10,2) NULL,
  `picture` VARCHAR(255) NULL,
  `preparation_time` INT NULL,
  PRIMARY KEY (`id_menu_item`, `category_id_category`),
  INDEX `fk_menu_item_category1_idx` (`category_id_category` ASC) VISIBLE,
  CONSTRAINT `fk_menu_item_category1`
    FOREIGN KEY (`category_id_category`)
    REFERENCES `mydb`.`category` (`id_category`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`order` ;

CREATE TABLE IF NOT EXISTS `mydb`.`order` (
  `id_order` INT NOT NULL AUTO_INCREMENT,
  `hist_id_pizzeria` INT NOT NULL,
  `num_order` INT NULL,
  `amount` DECIMAL(10,2) NULL,
  `order_date` DATETIME NULL,
  PRIMARY KEY (`id_order`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`recipe`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`recipe` ;

CREATE TABLE IF NOT EXISTS `mydb`.`recipe` (
  `id_recipe` INT NOT NULL AUTO_INCREMENT,
  `menu_item_id_menu_item` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(255) NULL,
  `preparation_time` INT NULL,
  `tl_procedure` VARCHAR(20000) NULL,
  PRIMARY KEY (`id_recipe`, `menu_item_id_menu_item`),
  INDEX `fk_recipe_menu_item1_idx` (`menu_item_id_menu_item` ASC) VISIBLE,
  CONSTRAINT `fk_recipe_menu_item1`
    FOREIGN KEY (`menu_item_id_menu_item`)
    REFERENCES `mydb`.`menu_item` (`id_menu_item`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`unit`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`unit` ;

CREATE TABLE IF NOT EXISTS `mydb`.`unit` (
  `id_unit` INT NOT NULL AUTO_INCREMENT,
  `label` VARCHAR(255) NOT NULL,
  `short_label` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_unit`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`ingredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`ingredient` ;

CREATE TABLE IF NOT EXISTS `mydb`.`ingredient` (
  `id_ingredient` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(250) NOT NULL,
  `id_unit` INT NULL,
  `value_unit` DECIMAL(10,2) NULL,
  `unit_price` DECIMAL(10,2) NULL,
  `minimum_limit` DECIMAL(10,2) NULL,
  PRIMARY KEY (`id_ingredient`),
  INDEX `fk_ingredient_unity1_idx` (`id_unit` ASC) VISIBLE,
  CONSTRAINT `fk_ingredient_unity1`
    FOREIGN KEY (`id_unit`)
    REFERENCES `mydb`.`unit` (`id_unit`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`stock_ingredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`stock_ingredient` ;

CREATE TABLE IF NOT EXISTS `mydb`.`stock_ingredient` (
  `ingredient_id_ingredient` INT NOT NULL,
  `date_change` TIMESTAMP NOT NULL,
  `pizzeria_id_pizzeria` INT NOT NULL,
  `value_stock` DECIMAL(10,2) NULL,
  PRIMARY KEY (`ingredient_id_ingredient`, `date_change`, `pizzeria_id_pizzeria`),
  INDEX `fk_stock_ingredient_pizzeria1_idx` (`pizzeria_id_pizzeria` ASC) VISIBLE,
  CONSTRAINT `fk_stock_ingredient_ingredient1`
    FOREIGN KEY (`ingredient_id_ingredient`)
    REFERENCES `mydb`.`ingredient` (`id_ingredient`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_stock_ingredient_pizzeria1`
    FOREIGN KEY (`pizzeria_id_pizzeria`)
    REFERENCES `mydb`.`pizzeria` (`id_pizzeria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`statut`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`statut` ;

CREATE TABLE IF NOT EXISTS `mydb`.`statut` (
  `id_statut` INT NOT NULL AUTO_INCREMENT,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_statut`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`person` ;

CREATE TABLE IF NOT EXISTS `mydb`.`person` (
  `id_person` INT NOT NULL AUTO_INCREMENT,
  `nick_name` VARCHAR(100) NOT NULL,
  `password` VARCHAR(32) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NULL,
  `phone_number` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_person`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`address`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`address` ;

CREATE TABLE IF NOT EXISTS `mydb`.`address` (
  `id_address` INT NOT NULL AUTO_INCREMENT,
  `num_address` INT NOT NULL,
  `person_id_person` INT NOT NULL,
  `is_current` TINYINT NULL,
  `street` VARCHAR(255) NOT NULL,
  `street_num` VARCHAR(45) NULL,
  `city` VARCHAR(100) NOT NULL,
  `zip_code` VARCHAR(45) NULL,
  `country` VARCHAR(45) NULL,
  `localization` VARCHAR(45) NULL,
  PRIMARY KEY (`id_address`, `num_address`, `person_id_person`),
  INDEX `fk_adress_person1_idx` (`person_id_person` ASC) VISIBLE,
  CONSTRAINT `fk_adress_person1`
    FOREIGN KEY (`person_id_person`)
    REFERENCES `mydb`.`person` (`id_person`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`employee_has_role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`employee_has_role` ;

CREATE TABLE IF NOT EXISTS `mydb`.`employee_has_role` (
  `employee_id_employee` INT NOT NULL,
  `role_id_role` INT NOT NULL,
  `start_date` TIMESTAMP NULL,
  PRIMARY KEY (`employee_id_employee`, `role_id_role`),
  INDEX `fk_employee_has_role_role1_idx` (`role_id_role` ASC) VISIBLE,
  INDEX `fk_employee_has_role_employee_idx` (`employee_id_employee` ASC) VISIBLE,
  CONSTRAINT `fk_employee_has_role_employee`
    FOREIGN KEY (`employee_id_employee`)
    REFERENCES `mydb`.`employee` (`id_employee`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_has_role_role1`
    FOREIGN KEY (`role_id_role`)
    REFERENCES `mydb`.`role` (`id_role`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`invoice_has_order`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`invoice_has_order` ;

CREATE TABLE IF NOT EXISTS `mydb`.`invoice_has_order` (
  `invoice_id_invoice` INT NOT NULL,
  `order_id_order` INT NOT NULL,
  PRIMARY KEY (`invoice_id_invoice`, `order_id_order`),
  INDEX `fk_invoice_has_order_order1_idx` (`order_id_order` ASC) VISIBLE,
  INDEX `fk_invoice_has_order_invoice1_idx` (`invoice_id_invoice` ASC) VISIBLE,
  CONSTRAINT `fk_invoice_has_order_invoice1`
    FOREIGN KEY (`invoice_id_invoice`)
    REFERENCES `mydb`.`invoice` (`id_invoice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_invoice_has_order_order1`
    FOREIGN KEY (`order_id_order`)
    REFERENCES `mydb`.`order` (`id_order`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order_has_menu_item`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`order_has_menu_item` ;

CREATE TABLE IF NOT EXISTS `mydb`.`order_has_menu_item` (
  `order_id_order` INT NOT NULL,
  `menu_item_id_menu_item` INT NOT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`order_id_order`, `menu_item_id_menu_item`),
  INDEX `fk_order_has_menu_item_menu_item1_idx` (`menu_item_id_menu_item` ASC) VISIBLE,
  INDEX `fk_order_has_menu_item_order1_idx` (`order_id_order` ASC) VISIBLE,
  CONSTRAINT `fk_order_has_menu_item_order1`
    FOREIGN KEY (`order_id_order`)
    REFERENCES `mydb`.`order` (`id_order`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_has_menu_item_menu_item1`
    FOREIGN KEY (`menu_item_id_menu_item`)
    REFERENCES `mydb`.`menu_item` (`id_menu_item`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`recipe_has_ingredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`recipe_has_ingredient` ;

CREATE TABLE IF NOT EXISTS `mydb`.`recipe_has_ingredient` (
  `recipe_id_recipe` INT NOT NULL,
  `ingredient_id_ingredient` INT NOT NULL,
  `quantity` DECIMAL(10,2) NULL,
  PRIMARY KEY (`recipe_id_recipe`, `ingredient_id_ingredient`),
  INDEX `fk_receipe_has_ingredient_ingredient1_idx` (`ingredient_id_ingredient` ASC) VISIBLE,
  INDEX `fk_receipe_has_ingredient_receipe1_idx` (`recipe_id_recipe` ASC) VISIBLE,
  CONSTRAINT `fk_receipe_has_ingredient_receipe1`
    FOREIGN KEY (`recipe_id_recipe`)
    REFERENCES `mydb`.`recipe` (`id_recipe`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_receipe_has_ingredient_ingredient1`
    FOREIGN KEY (`ingredient_id_ingredient`)
    REFERENCES `mydb`.`ingredient` (`id_ingredient`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order_has_person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`order_has_person` ;

CREATE TABLE IF NOT EXISTS `mydb`.`order_has_person` (
  `order_id_order` INT NOT NULL,
  `person_id_person` INT NOT NULL,
  `statut_id_statut` INT NOT NULL,
  `employee_id_employee` INT NOT NULL,
  `ts_change` TIMESTAMP NULL,
  PRIMARY KEY (`order_id_order`, `person_id_person`, `statut_id_statut`, `employee_id_employee`),
  INDEX `fk_order_has_person_person1_idx` (`person_id_person` ASC) VISIBLE,
  INDEX `fk_order_has_person_order1_idx` (`order_id_order` ASC) VISIBLE,
  INDEX `fk_order_has_person_statut1_idx` (`statut_id_statut` ASC) VISIBLE,
  INDEX `fk_order_has_person_employee1_idx` (`employee_id_employee` ASC) VISIBLE,
  CONSTRAINT `fk_order_has_person_order1`
    FOREIGN KEY (`order_id_order`)
    REFERENCES `mydb`.`order` (`id_order`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_has_person_person1`
    FOREIGN KEY (`person_id_person`)
    REFERENCES `mydb`.`person` (`id_person`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_has_person_statut1`
    FOREIGN KEY (`statut_id_statut`)
    REFERENCES `mydb`.`statut` (`id_statut`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_has_person_employee1`
    FOREIGN KEY (`employee_id_employee`)
    REFERENCES `mydb`.`employee` (`id_employee`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`address_has_pizzeria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`address_has_pizzeria` ;

CREATE TABLE IF NOT EXISTS `mydb`.`address_has_pizzeria` (
  `address_id_address` INT NOT NULL,
  `pizzeria_id_pizzeria` INT NOT NULL,
  `order` INT NULL,
  PRIMARY KEY (`address_id_address`, `pizzeria_id_pizzeria`),
  INDEX `fk_adress_has_pizerria_pizerria1_idx` (`pizzeria_id_pizzeria` ASC) VISIBLE,
  INDEX `fk_adress_has_pizerria_adress1_idx` (`address_id_address` ASC) VISIBLE,
  CONSTRAINT `fk_adress_has_pizerria_adress1`
    FOREIGN KEY (`address_id_address`)
    REFERENCES `mydb`.`address` (`id_address`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_adress_has_pizerria_pizerria1`
    FOREIGN KEY (`pizzeria_id_pizzeria`)
    REFERENCES `mydb`.`pizzeria` (`id_pizzeria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`menu_has_menu_item`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`menu_has_menu_item` ;

CREATE TABLE IF NOT EXISTS `mydb`.`menu_has_menu_item` (
  `menu_id_menu` INT NOT NULL,
  `menu_item_id_menu_item` INT NOT NULL,
  PRIMARY KEY (`menu_id_menu`, `menu_item_id_menu_item`),
  INDEX `fk_menu_has_menu_item_menu_item1_idx` (`menu_item_id_menu_item` ASC) VISIBLE,
  INDEX `fk_menu_has_menu_item_menu1_idx` (`menu_id_menu` ASC) VISIBLE,
  CONSTRAINT `fk_menu_has_menu_item_menu1`
    FOREIGN KEY (`menu_id_menu`)
    REFERENCES `mydb`.`menu` (`id_menu`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_menu_has_menu_item_menu_item1`
    FOREIGN KEY (`menu_item_id_menu_item`)
    REFERENCES `mydb`.`menu_item` (`id_menu_item`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
