const API_BASE = "http://localhost:8000";

function authHeaders(): Record<string, string> {
  const token = localStorage.getItem("token");
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...authHeaders(),
      ...(options.headers ?? {}),
    },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ detail: res.statusText }));
    throw new Error(err.detail ?? "Error de red");
  }
  return res.json();
}

export async function login(usuario: string, password: string) {
  const data = await request<{ token: string; rol: string; nombre: string }>("/auth/login", {
    method: "POST",
    body: JSON.stringify({ usuario, password }),
  });
  localStorage.setItem("token", data.token);
  localStorage.setItem("rol", data.rol);
  localStorage.setItem("nombre", data.nombre);
  return data;
}

export function logout() {
  localStorage.removeItem("token");
  localStorage.removeItem("rol");
  localStorage.removeItem("nombre");
}

export async function getProductos() {
  return request<{ id_producto: number; nombre: string; descripcion: string; precio: number; categoria: string }[]>("/productos");
}

export async function getMesas() {
  return request<{ id_mesa: number; numero: number; capacidad: number; estado: string }[]>("/mesas");
}

export async function cambiarEstadoMesa(id_mesa: number, estado: string) {
  return request(`/mesas/${id_mesa}/estado`, {
    method: "PATCH",
    body: JSON.stringify({ estado }),
  });
}

export async function crearVentaPresencial(payload: {
  id_mesa: number;
  id_caja: number;
  items: { id_producto: number; cantidad: number; observaciones?: string }[];
}) {
  return request<{ ok: boolean; id_venta: number }>("/ventas/presencial", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function crearVentaDelivery(payload: {
  id_cliente: number;
  direccion_entrega: string;
  telefono_contacto: string;
  items: { id_producto: number; cantidad: number; observaciones?: string }[];
}) {
  return request<{ ok: boolean; id_venta: number }>("/ventas/delivery", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function cambiarEstadoVenta(id_venta: number, estado: string, motivo?: string) {
  return request(`/ventas/${id_venta}/estado`, {
    method: "PATCH",
    body: JSON.stringify({ estado, ...(motivo ? { motivo_cancelacion: motivo } : {}) }),
  });
}

export async function getPedidosCocina() {
  return request<{ id_venta: number; tipo_venta: string; mesa: number; estado: string; pedido: string }[]>("/cocina/pedidos");
}

export async function getPedidosListos() {
  return request<{ id_venta: number; tipo_venta: string; mesa: number; mesero: string }[]>("/cocina/pedidos-listos");
}

export async function getCajaActiva() {
  return request<{ caja: { id_caja: number; monto_inicial: number; fecha_apertura: string } | null }>("/caja/activa");
}

export async function abrirCaja(monto_inicial: number) {
  return request<{ ok: boolean; id_caja: number }>("/caja/abrir", {
    method: "POST",
    body: JSON.stringify({ monto_inicial }),
  });
}

export async function cerrarCaja(id_caja: number, monto_contado: number) {
  return request(`/caja/${id_caja}/cerrar`, {
    method: "POST",
    body: JSON.stringify({ monto_contado }),
  });
}

export async function registrarPago(payload: {
  id_venta: number;
  id_metodo: number;
  monto: number;
  monto_recibido?: number;
  codigo_operacion?: string;
}) {
  return request<{ ok: boolean; id_pago: number }>("/caja/pago", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}
