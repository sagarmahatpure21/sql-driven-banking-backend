-- 03_dql.sql
-- Some SELECT queries showing WHERE, JOIN, GROUP BY, subquery, ORDER BY
-- (this is the DQL part of the project)
USE bank_management_system;

-- customers born after year 2000
SELECT full_name, email, phone, date_of_birth
FROM Customers
WHERE date_of_birth > '2000-01-01';

SELECT "" AS " ";

-- join Customers -> Accounts -> Branches to see who has what account where
SELECT c.full_name, a.account_type, a.balance, b.branch_name, b.city
FROM Customers c
JOIN Accounts  a ON c.customer_id = a.customer_id
JOIN Branches  b ON a.branch_id   = b.branch_id
ORDER BY a.balance DESC;


SELECT "" AS " ";

-- total balance per branch
SELECT b.branch_name, COUNT(a.account_id) AS num_accounts, SUM(a.balance) AS total_balance
FROM Branches b
LEFT JOIN Accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_balance DESC;


SELECT "" AS " ";

-- transaction history for account 1, newest first
SELECT transaction_id, txn_type, amount, txn_date, description
FROM Transactions
WHERE account_id = 1
ORDER BY txn_date DESC;

SELECT "" AS " ";

-- subquery example - customers with balance above the average
SELECT c.full_name, a.balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.balance > (SELECT AVG(balance) FROM Accounts);


SELECT "" AS " ";

-- NOTE: this last query needs fn_account_balance(), which is only
-- created in 04_procedures_functions_triggers.sql. If you're running
-- these files in order for the first time this one query will error
-- out here - that's expected, just run 04 next and it'll work fine.
SELECT account_id, fn_account_balance(account_id) AS live_balance
FROM Accounts;
