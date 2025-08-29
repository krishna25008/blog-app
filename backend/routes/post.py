from flask import Blueprint, request, jsonify
from extension import db
from models import Post,Like
from flask_jwt_extended import jwt_required, get_jwt_identity
import cloudinary.uploader
post_bp = Blueprint("post", __name__)

@post_bp.route("/posts", methods=["POST"])
@jwt_required()
def create_post():
    title = request.form.get("title")
    content = request.form.get("content")
    print(get_jwt_identity())
    user_id = int(get_jwt_identity())
    file = request.files.get("file")
    image_url = None
    if not title or not content:
        return jsonify({"error": "Title and content required"}), 400
    if file:
        upload_result = cloudinary.uploader.upload(file)
        image_url = upload_result.get("secure_url")
    else:
        return jsonify({"error": "Image file is required"}), 400
    new_post = Post(title=title, content=content, user_id=user_id,image_url=image_url)
    db.session.add(new_post)
    db.session.commit()
    return jsonify({"message": "Post created successfully"}), 201
#get all posts
@post_bp.route("/posts", methods=["GET"])
@jwt_required()
def get_posts():
    liked=False
    posts = Post.query.order_by(Post.created_at.desc()).all()
    result = []
    user_id = int(get_jwt_identity())
    for post in posts:
        likes_count = Like.query.filter_by(post_id=post.id).count()
        liked= Like.query.filter_by(post_id=post.id,user_id=user_id).first() is not None
        result.append({
            "id": post.id,
            "title": post.title,
            "caption": post.content,
            "date": post.created_at,
            "username": post.user.username,
            "postImage": post.image_url,
            "userImage": None,
            "likes": likes_count,
            "comments": 0,
            "is_liked": liked
        })
    return jsonify(result), 200
@post_bp.route("/posts/<int:post_id>", methods=["GET"])
@jwt_required()
def get_post(post_id):
    post = Post.query.get_or_404(post_id)
    userss = [like.user.username for like in post.likes]
    print(userss)
    return jsonify({
        "id": post.id,
        "title": post.title,
        "content": post.content,
        "created_at": post.created_at,
        "author": post.user.username
    }), 200
@post_bp.route("/posts/del", methods=["DELETE"])
def deleteAllPosts():
    try:
        num_rows_deleted = db.session.query(Post).delete()
        db.session.commit()
        return f"Deleted {num_rows_deleted} posts."
    except Exception as e:
        db.session.rollback()
        return str(e)