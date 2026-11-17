from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from auth import decode_token
import jwt

_bearer = HTTPBearer()


def require_auth(credentials: HTTPAuthorizationCredentials = Security(_bearer)) -> dict:
    try:
        return decode_token(credentials.credentials)
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")


def require_role(*roles: str):
    def checker(token: dict = Security(require_auth)) -> dict:
        if token.get("rol") not in roles:
            raise HTTPException(status_code=403, detail="Sin permiso para esta acción")
        return token
    return checker
