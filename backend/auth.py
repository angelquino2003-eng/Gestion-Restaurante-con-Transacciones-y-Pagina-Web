import os
import jwt
import bcrypt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

load_dotenv()

_SECRET = os.getenv("JWT_SECRET", "dev_secret")
_EXPIRE_HOURS = int(os.getenv("JWT_EXPIRE_HOURS", 8))


def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def create_token(payload: dict) -> str:
    data = payload.copy()
    data["exp"] = datetime.now(timezone.utc) + timedelta(hours=_EXPIRE_HOURS)
    return jwt.encode(data, _SECRET, algorithm="HS256")


def decode_token(token: str) -> dict:
    return jwt.decode(token, _SECRET, algorithms=["HS256"])
