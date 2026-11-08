const API_BASE = "http://localhost:8000/api";

export async function getProductos() {
  // MIENTRAS NO HAYA BACKEND: Devuelve los datos mock de menuData.ts
  // CUANDO EL BACKEND ESTÉ LISTO: Descomentas la siguiente línea:
  // const res = await fetch(`${API_BASE}/productos`); return await res.json();
  return import('../data/menuData').then(m => m.dishes);
}

export async function getMesasLibres() {
  // Simulación de la vista v_mesas_libres
  return [
    { id_mesa: 1, numero: 1, capacidad: 4, estado: 'libre' },
    { id_mesa: 2, numero: 2, capacidad: 2, estado: 'ocupada' }
  ];
}