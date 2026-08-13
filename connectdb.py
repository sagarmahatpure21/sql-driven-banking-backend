# connectdb.py
# Small wrapper class around mysql-connector-python so app.py doesn't
# have to deal with cursors/commits everywhere.
#
# pip install mysql-connector-python

import mysql.connector
from mysql.connector import Error


class ConnectDB:
    def __init__(self, host="localhost", user="bank_app",
                 password="BankApp@2026", database="bank_management_system"):
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.connection = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database,
            )
            return self.connection
        except Error as e:
            print(f"Database connection failed: {e}")
            raise

    def close(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()

    # so we can do "with ConnectDB() as db:" in app.py
    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def execute_query(self, query, params=None, fetch=False):
        cursor = self.connection.cursor(dictionary=True)
        try:
            cursor.execute(query, params or ())
            if fetch:
                return cursor.fetchall()
            self.connection.commit()
            return cursor.rowcount
        except Error as e:
            self.connection.rollback()
            print(f"Query failed, rolled back: {e}")
            raise
        finally:
            cursor.close()

    def call_procedure(self, proc_name, args=None):
        cursor = self.connection.cursor()
        try:
            cursor.callproc(proc_name, args or [])
            self.connection.commit()
        except Error:
            self.connection.rollback()
            raise
        finally:
            cursor.close()

    def call_function(self, func_name, args=None):
        # mysql-connector doesn't have a direct "call function" api,
        # so just SELECT it like any other value
        args = args or []
        placeholders = ", ".join(["%s"] * len(args))
        query = f"SELECT {func_name}({placeholders}) AS result"
        cursor = self.connection.cursor()
        try:
            cursor.execute(query, args)
            row = cursor.fetchone()
            return row[0] if row else None
        finally:
            cursor.close()

    # ---- everything below is just the specific queries each page needs ----

    def get_all_customers(self):
        return self.execute_query(
            "SELECT customer_id, full_name, email, phone FROM Customers", fetch=True
        )

    def get_account_overview(self):
        # this comes from the view defined in 06_advanced_dql.sql
        return self.execute_query("SELECT * FROM vw_account_overview", fetch=True)

    def get_transactions_for_account(self, account_id):
        return self.execute_query(
            "SELECT * FROM Transactions WHERE account_id = %s ORDER BY txn_date DESC",
            (account_id,), fetch=True
        )

    def search_customers(self, keyword):
        like = f"%{keyword}%"
        return self.execute_query(
            "SELECT customer_id, full_name, email, phone FROM Customers "
            "WHERE full_name LIKE %s OR email LIKE %s",
            (like, like), fetch=True
        )

    def get_branch_report(self):
        return self.execute_query(
            "SELECT b.branch_name, COUNT(a.account_id) AS num_accounts, "
            "SUM(a.balance) AS total_balance "
            "FROM Branches b LEFT JOIN Accounts a ON a.branch_id = b.branch_id "
            "GROUP BY b.branch_id, b.branch_name",
            fetch=True
        )
