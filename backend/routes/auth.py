from flask import Blueprint, jsonify,request
from extension import db
from models import User
from sqlalchemy import or_
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
from utils.validator import validate_signup
auth_bp=Blueprint('auth',__name__)
@auth_bp.route("/signup", methods=["POST"])
def signup():
    data = request.get_json() or {}
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    error =validate_signup(username, email, password)
    if error:
        return jsonify({"error": error}), 400
    hashed_password = generate_password_hash(password, method='pbkdf2:sha256')
    new_user = User(username=username, email=email, password=hashed_password)
    
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "User created successfully"}), 201
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    identifier = data.get('identifier')
    password = data.get('password')
    if not identifier or not password:
        return jsonify({"error": "Missing required fields"}), 400
    user = User.query.filter(or_(User.email == identifier, User.username == identifier)).first()
    if not user:
        return jsonify({"error": "User not found"}), 404
    if user and check_password_hash(user.password, password):
        access_token=create_access_token(identity=str(user.id), additional_claims={"username": user.username})
        return jsonify({
        "message": "Login successful",
        "access_token": access_token,
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email
        }
    }), 200
    return jsonify({"error": "Invalid password"}), 401
@auth_bp.route('/hello')
def method_name():
    return jsonify({"message": "Hello, World!"})
