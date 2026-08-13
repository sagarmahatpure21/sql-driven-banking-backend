-- 04_procedures_functions_triggers.sql
-- Stored procedure, a function, and two triggers
USE bank_management_system;

DELIMITER $$

-- returns the current balance for an account
CREATE FUNCTION fn_account_balance(p_account_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    SELECT balance INTO v_balance
    FROM Accounts
    WHERE account_id = p_account_id;
    RETURN IFNULL(v_balance, 0.00);
END$$

-- stops a withdrawal/transfer that would take the balance below 0
CREATE TRIGGER trg_before_transaction_insert
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_current_balance DECIMAL(12,2);

    IF NEW.txn_type IN ('WITHDRAWAL', 'TRANSFER_OUT') THEN
        SELECT balance INTO v_current_balance
        FROM Accounts WHERE account_id = NEW.account_id;

        IF v_current_balance < NEW.amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient funds for this transaction';
        END IF;
    END IF;
END$$

-- after a transaction row is inserted, actually update the account balance
CREATE TRIGGER trg_after_transaction_insert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF NEW.txn_type IN ('DEPOSIT', 'TRANSFER_IN') THEN
        UPDATE Accounts
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    ELSEIF NEW.txn_type IN ('WITHDRAWAL', 'TRANSFER_OUT') THEN
        UPDATE Accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END$$

-- moves money from one account to another. wrapped in a transaction so
-- if anything fails halfway through (like the overdraft trigger firing)
-- both legs get rolled back instead of only moving money out one side
CREATE PROCEDURE sp_transfer_funds(
    IN p_from_account INT,
    IN p_to_account   INT,
    IN p_amount       DECIMAL(12,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- pass the error back up so Flask can catch it
    END;

    START TRANSACTION;

    INSERT INTO Transactions (account_id, txn_type, amount, description)
    VALUES (p_from_account, 'TRANSFER_OUT', p_amount,
            CONCAT('Transfer to account ', p_to_account));

    INSERT INTO Transactions (account_id, txn_type, amount, description)
    VALUES (p_to_account, 'TRANSFER_IN', p_amount,
            CONCAT('Transfer from account ', p_from_account));

    COMMIT;
END$$

DELIMITER ;
