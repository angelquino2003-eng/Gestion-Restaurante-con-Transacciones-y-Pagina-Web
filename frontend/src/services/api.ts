import { dishes } from "../data/menuData";
import type { Dish } from "../types/menu";

const API_BASE = "http://localhost:8000/api";

/**
 * Obtiene el menú de platos activos desde el backend.
 * Devuelve los datos simulados de menuData.ts
 */
export async function getProductos(): Promise<Dish[]> {
  /*
  // Descomentar cuando el backend esté listo
  const res = await fetch(`${API_BASE}/productos`);
  if (!res.ok) throw new Error("Error al obtener productos");
  return await res.json();
  */
  return dishes;
}

/**
 * Envía un nuevo pedido a la base de datos a través del backend.
 * El backend se encarga de crear la transacción ACID en MySQL.
 */
export async function crearPedido(pedido: {
  tipo_venta: "salon" | "delivery";
  items: { id_producto: string; cantidad: number }[];
  direccion?: string;
}) {
  /*
  const res = await fetch(`${API_BASE}/ventas`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(pedido),
  });
  return await res.json();
  */
  console.log("Simulando envío al backend de:", pedido);
  return { ok: true, id_venta: 101, mensaje: "Pedido registrado con éxito" };
}
