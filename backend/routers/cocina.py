from fastapi import APIRouter, Security
from db import get_conn
from dependencies import require_role

router = APIRouter(prefix="/cocina", tags=["cocina"])


@router.get("/pedidos")
def pedidos_por_preparar(token: dict = Security(require_role("cocina", "admin"))):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT id_venta, tipo_venta, mesa, estado, fecha, pedido FROM v_pedidos_cocina ORDER BY fecha")
        return cur.fetchall()
    finally:
        conn.close()


@router.get("/pedidos-listos")
def pedidos_listos(token: dict = Security(require_role("cocina", "mesero", "admin"))):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT id_venta, tipo_venta, mesa, mesero, hora_listo FROM v_pedidos_listos ORDER BY hora_listo")
        return cur.fetchall()
    finally:
        conn.close()
