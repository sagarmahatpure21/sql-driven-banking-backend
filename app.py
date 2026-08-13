# app.py
# Main Flask app for the Bank Account Management mini project.
# Run with: python3 app.py
# Then open http://127.0.0.1:5000

from flask import Flask, render_template, request, redirect, url_for, session, flash
from connectdb import ConnectDB
import config

app = Flask(__name__)
app.secret_key = config.SECRET_KEY


def require_login():
    # used at the start of every route that needs the user logged in
    return session.get("logged_in", False)


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        # NOTE: just comparing plain text for this project. A real app
        # would check a hashed password from a Users table instead.
        if username == config.DEMO_USERNAME and password == config.DEMO_PASSWORD:
            session["logged_in"] = True
            return redirect(url_for("dashboard"))
        flash("Invalid username or password")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("home"))


@app.route("/dashboard")
def dashboard():
    if not require_login():
        return redirect(url_for("login"))
    with ConnectDB() as db:
        branch_report = db.get_branch_report()
    return render_template("dashboard.html", branch_report=branch_report)


@app.route("/customers")
def customers():
    if not require_login():
        return redirect(url_for("login"))
    with ConnectDB() as db:
        customer_list = db.get_all_customers()
    return render_template("customers.html", customers=customer_list)


@app.route("/accounts")
def accounts():
    # pulls from the vw_account_overview view instead of joining
    # Accounts/Customers/Branches again here
    if not require_login():
        return redirect(url_for("login"))
    with ConnectDB() as db:
        account_list = db.get_account_overview()
    return render_template("accounts.html", accounts=account_list)


@app.route("/transactions/<int:account_id>")
def transactions(account_id):
    if not require_login():
        return redirect(url_for("login"))
    with ConnectDB() as db:
        txns = db.get_transactions_for_account(account_id)
        balance = db.call_function("fn_account_balance", [account_id])
    return render_template(
        "transactions.html", transactions=txns, account_id=account_id, balance=balance
    )


@app.route("/transfer", methods=["GET", "POST"])
def transfer():
    if not require_login():
        return redirect(url_for("login"))

    if request.method == "POST":
        from_account = request.form.get("from_account", type=int)
        to_account = request.form.get("to_account", type=int)
        amount = request.form.get("amount", type=float)

        with ConnectDB() as db:
            try:
                db.call_procedure("sp_transfer_funds", [from_account, to_account, amount])
                flash(f"Transferred {amount} from account {from_account} to {to_account}")
            except Exception as e:
                # usually the trigger raising an error for insufficient funds
                flash(f"Transfer failed: {e}")
        return redirect(url_for("transfer"))

    return render_template("transfer.html")


@app.route("/search", methods=["GET", "POST"])
def search():
    if not require_login():
        return redirect(url_for("login"))
    results = []
    if request.method == "POST":
        keyword = request.form.get("keyword", "")
        with ConnectDB() as db:
            results = db.search_customers(keyword)
    return render_template("search.html", results=results)


@app.route("/reports")
def reports():
    # same query as dashboard, just showing it on its own page too
    if not require_login():
        return redirect(url_for("login"))
    with ConnectDB() as db:
        branch_report = db.get_branch_report()
    return render_template("reports.html", branch_report=branch_report)


if __name__ == "__main__":
    app.run(debug=True)
