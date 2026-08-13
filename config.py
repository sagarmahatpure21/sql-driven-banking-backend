# config.py
# Keeping config separate from app.py so the db password isn't just
# sitting in the middle of the route code.

import os

# in a real app these would be environment variables instead of
# hardcoded, but hardcoding is fine for a college project running locally
DB_CONFIG = {
    "host": "localhost",
    "user": "bank_app",
    "password": "BankApp@2026",
    "database": "bank_management_system",
}

# needed so Flask can sign the session cookie (keeps you logged in
# between page loads)
SECRET_KEY = os.environ.get("FLASK_SECRET_KEY", "dev-only-secret-change-me")

# fake login for demo purposes only, not tied to a real Users table
DEMO_USERNAME = "admin"
DEMO_PASSWORD = "admin123"
