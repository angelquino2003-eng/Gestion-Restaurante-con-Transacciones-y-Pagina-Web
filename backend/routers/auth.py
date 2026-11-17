from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from db import get_conn
from auth import verify_password, create_token

router = APIRouter(prefix="/auth", tags=["auth"])


class LoginBody(BaseModel):
    usuario: str
    password: str


@router.post("/login")
def login(body: LoginBody):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_empleado, nombre, rol, password_hash FROM empleado WHERE usuario = %s AND activo = 1",
            (body.usuario,),
        )
        empleado = cur.fetchone()
    finally:
        conn.close()

    if not empleado or not verify_password(body.password, empleado["password_hash"]):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    token = create_token({
        "sub": empleado["id_empleado"],
        "nombre": empleado["nombre"],
        "rol": empleado["rol"],
    })
    return {"token": token, "rol": empleado["rol"], "nombre": empleado["nombre"]}
