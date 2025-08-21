from flask import Flask, jsonify
from extension import db,cors,jwt
from routes.auth import auth_bp
from routes.post import post_bp
from config import Config
from models import User
def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)
    cors.init_app(app)
    jwt.init_app(app)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(post_bp, url_prefix='/api')
    with app.app_context():
        db.create_all()
    return app
if __name__ == "__main__":
    app=create_app()
    app.run(debug=True)
