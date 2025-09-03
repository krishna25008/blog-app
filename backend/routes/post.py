from datetime import datetime
from flask import Blueprint, request, jsonify
from extension import db
from models import Post,Like,Comment
from flask_jwt_extended import jwt_required, get_jwt_identity
import cloudinary.uploader
import arrow
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
    db.session.close()
    return jsonify({"message": "Post created successfully"}), 201
@post_bp.route("/posts", methods=["GET"])
@jwt_required()
def get_posts():
    liked=False
    posts = Post.query.order_by(Post.created_at.desc()).all()
    result = []
    user_id = int(get_jwt_identity())
    for post in posts:
        likes_count = Like.query.filter_by(post_id=post.id).count()
        comment_count=Comment.query.filter_by(post_id=post.id).count()
        liked= Like.query.filter_by(post_id=post.id,user_id=user_id).first() is not None
        result.append({
            "id": post.id,
            "title": post.title,
            "content": post.content,
            "date": arrow.get(post.created_at).humanize(),
            "username": post.user.username,
            "postImage": post.image_url,
            "updated at": post.updated_at,
            "userImage": None,
            "likes": likes_count,
            "comments": comment_count,
            "is_liked": liked
        })
    return jsonify(result), 200
#get a single post
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
#update a post
@post_bp.route("/posts/<int:post_id>", methods=["PUT"])
@jwt_required()
def update_post(post_id):
    user_id = int(get_jwt_identity())
    post = Post.query.get_or_404(post_id) 
    if post.user_id != user_id:
        return jsonify({"error": "Unauthorized"}), 403

    data = request.form
    title = data.get("title")  # Get title from form
    content = data.get("content")  # Get content from form

    print(f"Title: {title}, Content: {content}")

    image_url = None

    if 'image' in request.files:
        file = request.files['image']
        try:
            upload_result = cloudinary.uploader.upload(file)
            image_url = upload_result.get("secure_url")  # Get the Cloudinary URL
            print(f"File received: {file.filename}")  # Debugging line
            print(f"Image URL: {image_url}")  # Debugging line
        except Exception as e:
            print(f"Error uploading image: {e}")  # Debugging line
            return jsonify({"error": "Failed to upload image"}), 500

    # Validate title and content
    if not title or not content:
        return jsonify({"error": "Title and content are required"}), 400

    # Update the post details
    post.title = title
    post.content = content
    post.updated_at = datetime.utcnow()
    if image_url:
        post.image_url = image_url

    # Commit the changes to the database
    db.session.commit()
    db.session.refresh(post)
    db.session.close()
    return jsonify({
        "message": "Post updated successfully",
        "post": {
            "id": post.id,
            "title": post.title,
            "postImage": post.image_url,
            "content": post.content,
            "updated_at": post.updated_at
        }
    }), 200
#delete a post
@post_bp.route("/posts/<int:post_id>", methods=["DELETE"])
@jwt_required()
def delete_post(post_id):
    user_id = int(get_jwt_identity())
    post = Post.query.get_or_404(post_id)
    if post.user_id != user_id:
        return jsonify({"error": "Unauthorized"}), 403
    db.session.delete(post)
    db.session.commit()
    db.session.close()
    return jsonify({"message": "Post deleted successfully"}), 200