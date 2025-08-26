from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Post, Like
from extension import db
like_bp = Blueprint("like", __name__)
@like_bp.route("/like/<int:post_id>", methods=["POST"])
@jwt_required()
def toggle_like(post_id):
    user_id = int(get_jwt_identity())
    post = Post.query.get_or_404(post_id)
    existing_like = Like.query.filter_by(user_id=user_id, post_id=post_id).first()
    if existing_like:
        db.session.delete(existing_like)
        db.session.commit()
        return jsonify({"message": "Post unliked successfully"}), 200
    new_like = Like(user_id=user_id, post_id=post_id)
    db.session.add(new_like)
    db.session.commit()
    return jsonify({"message": "Post liked successfully"}), 200
@like_bp.route("/likes/<int:post_id>", methods=["GET"])
def get_likes(post_id):
    post = Post.query.get_or_404(post_id)
    userss = [like.user.username for like in post.likes]
    print(userss)
    return jsonify({"post_id": post_id, "likes_count": len(post.likes)})