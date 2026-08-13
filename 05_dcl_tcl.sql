-- 05_dcl_tcl.sql
-- Setting up a separate DB user for the app (DCL) + a TCL example
USE bank_management_system;

-- ---- DCL: user & privileges ----

-- app.py should NOT connect as root, so create a limited user for it
-- (this is the same user/password used in connectdb.py / config.py)
CREATE USER IF NOT EXISTS 'bank_app'@'localhost' IDENTIFIED BY 'BankApp@2026';

-- only give bank_app the access it actually needs for the routes in app.py
GRANT SELECT, INSERT ON bank_management_system.Customers    TO 'bank_app'@'localhost';
GRANT SELECT, INSERT ON bank_management_system.Accounts     TO 'bank_app'@'localhost';
GRANT SELECT, INSERT ON bank_management_system.Transactions TO 'bank_app'@'localhost';
GRANT SELECT             ON bank_management_system.Branches   TO 'bank_app'@'localhost';
GRANT EXECUTE ON PROCEDURE bank_management_system.sp_transfer_funds TO 'bank_app'@'localhost';
GRANT EXECUTE ON FUNCTION  bank_management_system.fn_account_balance TO 'bank_app'@'localhost';

FLUSH PRIVILEGES;

-- app never inserts customers directly through raw SQL, so revoke that
REVOKE INSERT ON bank_management_system.Customers FROM 'bank_app'@'localhost';

-- just to double check the permissions look right
SHOW GRANTS FOR 'bank_app'@'localhost';

-- ---- TCL: transaction control ----
-- sp_transfer_funds already does this internally, this is just a
-- standalone example so the commands are visible on their own

START TRANSACTION;

    UPDATE Accounts SET balance = balance - 500 WHERE account_id = 3;
    SAVEPOINT before_credit;

    UPDATE Accounts SET balance = balance + 500 WHERE account_id = 99; -- account 99 doesn't exist

    -- undo just the credit attempt above, keep the debit
    ROLLBACK TO before_credit;

COMMIT;

-- if the debit had failed too, a plain ROLLBACK; here (instead of
-- COMMIT;) would have undone everything in this block
