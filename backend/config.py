import os

class Config:
    SQLALCHEMY_DATABASE_URI = "postgresql://saikrishna@localhost:5432/blogdb"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = "sihsauidbi"