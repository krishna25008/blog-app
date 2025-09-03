from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extension import db
from models import Comment, Post

comment_bp = Blueprint("comment", __name__)

# Add a comment
@comment_bp.route("/posts/<int:post_id>/comments", methods=["POST"])
@jwt_required()
def add_comment(post_id):
    data = request.get_json()
    text = data.get("text")
    if not text:
        return jsonify({"error": "Comment text required"}), 400

    user_id = get_jwt_identity() 

    post = Post.query.get(post_id)
    if not post:
        return jsonify({"error": "Post not found"}), 404

    comment = Comment(text=text, user_id=user_id, post_id=post_id)
    db.session.add(comment)
    db.session.commit()

    return jsonify({
        "id": comment.id,
        "text": comment.text,
        "username": comment.user.username,
        "created_at": comment.created_at.isoformat()
    }), 201

# Get comments for a post
@comment_bp.route("/posts/<int:post_id>/comments", methods=["GET"])
def get_comments(post_id):
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"error": "Post not found"}), 404
    comments = Comment.query.filter_by(post_id=post_id).all()
    return jsonify([
        {
            "id": c.id,
            "text": c.text,
            "username": c.user.username,
            "created_at": c.created_at.isoformat()
        }
        for c in comments
    ]), 200