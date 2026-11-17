from fastapi import APIRouter, HTTPException, Security
from pydantic import BaseModel
from typing import Optional
from db import get_conn
from dependencies import require_role

router = APIRouter(prefix="/ventas", tags=["ventas"])


class ItemVenta(BaseModel):
    id_producto: int
    cantidad: int
    observaciones: Optional[str] = None


class NuevaVentaPresencial(BaseModel):
    id_mesa: int
    id_caja: int
    items: list[ItemVenta]


class NuevaVentaDelivery(BaseModel):
    id_cliente: int
    direccion_entrega: str
    telefono_contacto: str
    items: list[ItemVenta]


def _insertar_detalle(cur, id_venta: int, items: list[ItemVenta]):
    for item in items:
        cur.execute(
            "SELECT precio FROM producto WHERE id_producto = %s AND activo = 1",
            (item.id_producto,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail=f"Producto {item.id_producto} no encontrado")
        cur.execute(
            """INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, observaciones)
               VALUES (%s, %s, %s, %s, %s)""",
            (id_venta, item.id_producto, item.cantidad, row["precio"], item.observaciones),
        )


@router.post("/presencial")
def crear_venta_presencial(
    body: NuevaVentaPresencial,
    token: dict = Security(require_role("mesero", "cajero", "admin")),
):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT estado FROM mesa WHERE id_mesa = %s", (body.id_mesa,))
        mesa = cur.fetchone()
        if not mesa:
            raise HTTPException(status_code=404, detail="Mesa no encontrada")
        if mesa["estado"] not in ("libre", "reservada"):
            raise HTTPException(status_code=409, detail=f"Mesa en estado '{mesa['estado']}', no disponible")

        cur.execute("SELECT id_caja FROM caja WHERE id_caja = %s AND estado = 'abierta'", (body.id_caja,))
        if not cur.fetchone():
            raise HTTPException(status_code=409, detail="La caja indicada no está abierta")

        cur.execute(
            """INSERT INTO venta (tipo_venta, estado, id_empleado, id_mesa, id_caja)
               VALUES ('presencial', 'pendiente', %s, %s, %s)""",
            (token["sub"], body.id_mesa, body.id_caja),
        )
        id_venta = cur.lastrowid
        _insertar_detalle(cur, id_venta, body.items)

        conn.commit()
        return {"ok": True, "id_venta": id_venta}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.post("/delivery")
def crear_venta_delivery(body: NuevaVentaDelivery):
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT id_cliente FROM cliente WHERE id_cliente = %s", (body.id_cliente,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Cliente no encontrado")

        cur.execute(
            """INSERT INTO venta (tipo_venta, estado, id_cliente, costo_delivery)
               VALUES ('delivery', 'pendiente', %s, 5.00)""",
            (body.id_cliente,),
        )
        id_venta = cur.lastrowid
        _insertar_detalle(cur, id_venta, body.items)

        from datetime import date
        cur.execute(
            """INSERT INTO delivery (id_venta, direccion_entrega, telefono_contacto, fecha_entrega_programada)
               VALUES (%s, %s, %s, %s)""",
            (id_venta, body.direccion_entrega, body.telefono_contacto, date.today()),
        )

        conn.commit()
        return {"ok": True, "id_venta": id_venta}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@router.patch("/{id_venta}/estado")
def cambiar_estado_venta(
    id_venta: int,
    body: dict,
    token: dict = Security(require_role("mesero", "cajero", "cocina", "admin")),
):
    estados_validos = {"pendiente", "en_proceso", "listo", "entregado", "finalizada", "cancelado"}
    nuevo = body.get("estado")
    if nuevo not in estados_validos:
        raise HTTPException(status_code=400, detail="Estado inválido")

    conn = get_conn()
    try:
        cur = conn.cursor()
        if nuevo == "cancelado":
            motivo = body.get("motivo_cancelacion")
            if not motivo:
                raise HTTPException(status_code=400, detail="Se requiere motivo_cancelacion al cancelar")
            cur.execute(
                "UPDATE venta SET estado = %s, motivo_cancelacion = %s WHERE id_venta = %s",
                (nuevo, motivo, id_venta),
            )
        elif nuevo == "listo":
            cur.execute(
                "UPDATE venta SET estado = 'listo', hora_listo = NOW() WHERE id_venta = %s",
                (id_venta,),
            )
        else:
            cur.execute("UPDATE venta SET estado = %s WHERE id_venta = %s", (nuevo, id_venta))

        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail="Venta no encontrada")
        conn.commit()
        return {"ok": True, "id_venta": id_venta, "estado": nuevo}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()
