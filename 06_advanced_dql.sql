-- 06_advanced_dql.sql
-- A few more advanced query concepts: VIEW, WINDOW FUNCTION, CTE,
-- CORRELATED SUBQUERY. The view here is what the Flask "Accounts"
-- page actually queries.
USE bank_management_system;

-- saved query that acts like a table, so app.py doesn't need to
-- repeat this same 3-table join every time it needs account info
CREATE OR REPLACE VIEW vw_account_overview AS
SELECT
    a.account_id,
    c.full_name      AS customer_name,
    a.account_type,
    a.balance,
    b.branch_name,
    b.city
FROM Accounts a
JOIN Customers c ON a.customer_id = c.customer_id
JOIN Branches  b ON a.branch_id   = b.branch_id;


SELECT "" AS " ";

SELECT * FROM vw_account_overview ORDER BY balance DESC;

-- the view didn't exist when 05_dcl_tcl.sql ran, so bank_app couldn't
-- have been granted access to it back then - granting it now instead
GRANT SELECT ON bank_management_system.vw_account_overview TO 'bank_app'@'localhost';

SELECT "" AS " ";

SELECT "" AS " ";
-- rank accounts by balance within each branch (window function,
-- doesn't collapse rows like GROUP BY would)
SELECT
    branch_name,
    customer_name,
    balance,
    RANK() OVER (PARTITION BY branch_name ORDER BY balance DESC) AS branch_rank
FROM vw_account_overview;



SELECT "" AS " ";
-- CTE - basically a named temp result we can query, makes this
-- easier to read than nesting it all as a subquery
WITH branch_totals AS (
    SELECT branch_name, SUM(balance) AS total_balance
    FROM vw_account_overview
    GROUP BY branch_name
)
SELECT branch_name, total_balance
FROM branch_totals
WHERE total_balance > 50000;



SELECT "" AS " ";
-- correlated subquery - the inner query references the outer row
-- (t2.account_id = a.account_id) so it runs once per row instead of
-- just once. finds the biggest transaction for each account.
SELECT
    a.account_id,
    t.amount,
    t.txn_type
FROM Accounts a
JOIN Transactions t ON t.account_id = a.account_id
WHERE t.amount = (
    SELECT MAX(t2.amount)
    FROM Transactions t2
    WHERE t2.account_id = a.account_id
);
