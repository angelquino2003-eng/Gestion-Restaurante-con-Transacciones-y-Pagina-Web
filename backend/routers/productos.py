from fastapi import APIRouter
from db import get_conn

router = APIRouter(prefix="/productos", tags=["productos"])


@router.get("")
def listar_productos():
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT p.id_producto, p.nombre, p.descripcion, p.precio,
                   c.nombre AS categoria
            FROM producto p
            JOIN categoria c ON c.id_categoria = p.id_categoria
            WHERE p.activo = 1
            ORDER BY c.nombre, p.nombre
        """)
        return cur.fetchall()
    finally:
        conn.close()


@router.get("/categorias")
def listar_categorias():
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT id_categoria, nombre FROM categoria WHERE activo = 1 ORDER BY nombre")
        return cur.fetchall()
    finally:
        conn.close()
