from fastapi import APIRouter, HTTPException, Security
from pydantic import BaseModel
from db import get_conn
from dependencies import require_role

router = APIRouter(prefix="/mesas", tags=["mesas"])


@router.get("")
def listar_mesas():
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT id_mesa, numero, capacidad, estado FROM mesa ORDER BY numero")
        return cur.fetchall()
    finally:
        conn.close()


class CambiarEstadoBody(BaseModel):
    estado: str


@router.patch("/{id_mesa}/estado")
def cambiar_estado(
    id_mesa: int,
    body: CambiarEstadoBody,
    token: dict = Security(require_role("mesero", "admin")),
):
    estados_validos = {"libre", "ocupada", "reservada", "inactiva"}
    if body.estado not in estados_validos:
        raise HTTPException(status_code=400, detail=f"Estado inválido. Opciones: {estados_validos}")

    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute("UPDATE mesa SET estado = %s WHERE id_mesa = %s", (body.estado, id_mesa))
        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail="Mesa no encontrada")
        conn.commit()
        return {"ok": True, "id_mesa": id_mesa, "estado": body.estado}
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()
