from extension import db
from datetime import datetime

class Post(db.Model):
    __tablename__ = "posts"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=True, default=None)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    user = db.relationship("User", backref="posts", lazy=True)

    image_url = db.Column(db.String(500))
    likes = db.relationship(
        "Like",
        backref="post",
        cascade="all, delete-orphan",
        passive_deletes=True
    )
    comments = db.relationship("Comment", backref="post",cascade="all, delete-orphan",
        passive_deletes=True)