-- 01_ddl.sql
-- Creating the database and all the tables (DDL part of the project)

DROP DATABASE IF EXISTS bank_management_system;
CREATE DATABASE bank_management_system;
USE bank_management_system;

-- Branches table
CREATE TABLE Branches (
    branch_id     INT AUTO_INCREMENT PRIMARY KEY,
    branch_name   VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    ifsc_code     VARCHAR(20)  NOT NULL UNIQUE
);

-- Employees table, each employee belongs to one branch
CREATE TABLE Employees (
    emp_id        INT AUTO_INCREMENT PRIMARY KEY,
    emp_name      VARCHAR(100) NOT NULL,
    role          VARCHAR(50)  NOT NULL,
    branch_id     INT NOT NULL,
    salary        DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Customers table
CREATE TABLE Customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15)  NOT NULL,
    address       VARCHAR(200),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Accounts table, one customer can have multiple accounts
CREATE TABLE Accounts (
    account_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    branch_id     INT NOT NULL,
    account_type  ENUM('SAVINGS','CURRENT') NOT NULL DEFAULT 'SAVINGS',
    balance       DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    opened_on     DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Transactions table, every deposit/withdrawal/transfer gets a row here
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id     INT NOT NULL,
    txn_type       ENUM('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT') NOT NULL,
    amount         DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    txn_date       DATETIME DEFAULT CURRENT_TIMESTAMP,
    description    VARCHAR(200),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- adding this after the fact to show ALTER TABLE usage
ALTER TABLE Customers ADD COLUMN date_of_birth DATE NULL;

-- indexes to speed up the lookups we do later in the DQL file
CREATE INDEX idx_accounts_customer ON Accounts(customer_id);
CREATE INDEX idx_txn_account ON Transactions(account_id);
