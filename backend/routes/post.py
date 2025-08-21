from flask import Blueprint, request, jsonify
from extension import db
from models import Post
from flask_jwt_extended import jwt_required, get_jwt_identity

post_bp = Blueprint("post", __name__)

@post_bp.route("/posts", methods=["POST"])
@jwt_required()
def create_post():
    data = request.get_json()
    title = data.get("title")
    content = data.get("content")
    user_id = int(get_jwt_identity())
    if not title or not content:
        return jsonify({"error": "Title and content required"}), 400

    new_post = Post(title=title, content=content, user_id=user_id)
    db.session.add(new_post)
    db.session.commit()

    return jsonify({"message": "Post created successfully"}), 201

# Get all posts
@post_bp.route("/posts", methods=["GET"])
def get_posts():
    posts = Post.query.all()
    result = []
    for post in posts:
        result.append({
            "id": post.id,
            "title": post.title,
            "content": post.content,
            "created_at": post.created_at,
            "author": post.user.username
        })
    return jsonify(result), 200

@post_bp.route("/posts/<int:post_id>", methods=["GET"])
def get_post(post_id):
    post = Post.query.get_or_404(post_id)
    return jsonify({
        "id": post.id,
        "title": post.title,
        "content": post.content,
        "created_at": post.created_at,
        "author": post.user.username
    }), 200