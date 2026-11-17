from fastapi import APIRouter, HTTPException, Security
from pydantic import BaseModel
from typing import Optional
from db import get_conn
from dependencies import require_role

router = APIRouter(prefix="/caja", tags=["caja"])


class AbrirCajaBody(BaseModel):
    monto_inicial: float


class CerrarCajaBody(BaseModel):
    monto_contado: float


class PagoBody(BaseModel):
    id_venta: int
    id_metodo: int
    monto: float
    monto_recibido: Optional[float] = None
    codigo_operacion: Optional[str] = None


@router.get("/activa")
def caja_activa(token: dict = Security(require_role("cajero", "admin"))):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            """SELECT id_caja, monto_inicial, fecha_apertura
               FROM caja WHERE id_empleado = %s AND estado = 'abierta' LIMIT 1""",
            (token["sub"],),
        )
        caja = cur.fetchone()
        if not caja:
            return {"caja": None}
        return {"caja": caja}
    finally:
        conn.close()


@router.post("/abrir")
def abrir_caja(
    body: AbrirCajaBody,
    token: dict = Security(require_role("cajero", "admin")),
):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_caja FROM caja WHERE id_empleado = %s AND estado = 'abierta'",
            (token["sub"],),
        )
        if cur.fetchone():
            raise HTTPException(status_code=409, detail="Ya tienes una caja abierta")

        cur.execute(
            "INSERT INTO caja (id_empleado, monto_inicial) VALUES (%s, %s)",
            (token["sub"], body.monto_inicial),
        )
        id_caja = cur.lastrowid

        cur.execute(
            "INSERT INTO bitacora (id_empleado, tipo_accion, descripcion) VALUES (%s, 'apertura_caja', %s)",
            (token["sub"], f"Apertura caja #{id_caja}, fondo S/ {body.monto_inicial:.2f}"),
        )
        conn.commit()
        return {"ok": True, "id_caja": id_caja}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.post("/{id_caja}/cerrar")
def cerrar_caja(
    id_caja: int,
    body: CerrarCajaBody,
    token: dict = Security(require_role("cajero", "admin")),
):
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.callproc("sp_cerrar_caja", (id_caja, body.monto_contado, token["sub"]))
        conn.commit()
        return {"ok": True, "id_caja": id_caja}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()


@router.post("/pago")
def registrar_pago(
    body: PagoBody,
    token: dict = Security(require_role("cajero", "admin")),
):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)

        cur.execute(
            "SELECT id_caja FROM caja WHERE id_empleado = %s AND estado = 'abierta' LIMIT 1",
            (token["sub"],),
        )
        caja = cur.fetchone()
        if not caja:
            raise HTTPException(status_code=409, detail="No tienes una caja abierta")

        cur.execute(
            """INSERT INTO pago (id_venta, id_metodo, id_caja, monto, monto_recibido,
                                 estado, codigo_operacion, id_empleado, fecha_revision)
               VALUES (%s, %s, %s, %s, %s, 'confirmado', %s, %s, NOW())""",
            (body.id_venta, body.id_metodo, caja["id_caja"], body.monto,
             body.monto_recibido, body.codigo_operacion, token["sub"]),
        )
        id_pago = cur.lastrowid

        cur.execute(
            "UPDATE venta SET estado = 'finalizada' WHERE id_venta = %s AND estado NOT IN ('cancelado','perdida')",
            (body.id_venta,),
        )

        cur.execute(
            "INSERT INTO bitacora (id_empleado, id_venta, tipo_accion, descripcion) VALUES (%s, %s, 'pago_confirmado', %s)",
            (token["sub"], body.id_venta, f"Pago confirmado S/ {body.monto:.2f}"),
        )

        conn.commit()
        return {"ok": True, "id_pago": id_pago}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.get("/resumen")
def resumen_caja(token: dict = Security(require_role("cajero", "admin"))):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM v_resumen_caja WHERE cajero = (SELECT nombre FROM empleado WHERE id_empleado = %s)", (token["sub"],))
        return cur.fetchall()
    finally:
        conn.close()
