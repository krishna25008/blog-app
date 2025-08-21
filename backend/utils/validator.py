import re
from models.user import User
def validate_signup(username, email, password):
    if not username or not email or not password:
        return "Missing required fields"
    if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
        return "Invalid email format"
    if User.query.filter_by(email=email).first():
        return "Email already exists"
    if User.query.filter_by(username=username).first():
        return "Username already exists"
    return None