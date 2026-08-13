-- 02_dml.sql
-- Adding sample data + a few UPDATE/DELETE examples (DML part)
USE bank_management_system;

-- insert some branches, employees, customers and accounts to work with
INSERT INTO Branches (branch_name, city, ifsc_code) VALUES
('MG Road Branch',   'Pune',   'BANK0001234'),
('Andheri Branch',   'Mumbai', 'BANK0005678'),
('Camp Branch',      'Pune',   'BANK0009999');

INSERT INTO Employees (emp_name, role, branch_id, salary) VALUES
('Anita Kulkarni', 'Branch Manager', 1, 75000.00),
('Rohan Mehta',     'Teller',         1, 32000.00),
('Sneha Iyer',      'Branch Manager', 2, 78000.00);

INSERT INTO Customers (full_name, email, phone, address, date_of_birth) VALUES
('Sagar Patil',    'sagar.patil@example.com',   '9876543210', 'Pune, MH',   '2002-04-15'),
('Priya Sharma',   'priya.sharma@example.com',  '9876500001', 'Mumbai, MH', '1998-11-02'),
('Vikram Rao',     'vikram.rao@example.com',    '9876500002', 'Pune, MH',   '1995-07-21');

INSERT INTO Accounts (customer_id, branch_id, account_type, balance) VALUES
(1, 1, 'SAVINGS', 15000.00),
(2, 2, 'SAVINGS', 42000.00),
(3, 1, 'CURRENT', 100000.00);

-- normally transactions come from the app/procedure, but adding one
-- manually here just to show the trigger updating the balance
INSERT INTO Transactions (account_id, txn_type, amount, description) VALUES
(1, 'DEPOSIT', 5000.00, 'Cash deposit at counter');

-- UPDATE examples
UPDATE Customers
SET phone = '9876543211'
WHERE customer_id = 1;

UPDATE Employees
SET salary = salary * 1.10
WHERE role = 'Branch Manager';

-- DELETE example - removing a low-salary teller record
DELETE FROM Employees WHERE emp_name = 'Rohan Mehta' AND salary < 30000;
