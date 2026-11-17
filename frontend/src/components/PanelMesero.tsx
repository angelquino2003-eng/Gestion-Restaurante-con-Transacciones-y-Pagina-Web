import { useState } from 'react';
import { dishes } from '../data/menuData';

interface Mesa {
  id_mesa: number;
  numero: number;
  capacidad: number;
  estado: 'libre' | 'ocupada' | 'reservada';
}

interface ItemComanda {
  id_producto: string;
  nombre: string;
  precio: number;
  cantidad: number;
  observaciones: string;
}

const MESAS_INICIALES: Mesa[] = [
  { id_mesa: 1, numero: 1, capacidad: 2, estado: 'libre' },
  { id_mesa: 2, numero: 2, capacidad: 4, estado: 'ocupada' },
  { id_mesa: 3, numero: 3, capacidad: 4, estado: 'libre' },
  { id_mesa: 4, numero: 4, capacidad: 6, estado: 'reservada' },
  { id_mesa: 5, numero: 5, capacidad: 4, estado: 'libre' },
  { id_mesa: 6, numero: 6, capacidad: 8, estado: 'libre' },
];

export default function PanelMesero() {
  const [mesas, setMesas] = useState<Mesa[]>(MESAS_INICIALES);
  const [mesaSeleccionada, setMesaSeleccionada] = useState<Mesa | null>(MESAS_INICIALES[0]);
  const [comanda, setComanda] = useState<Record<number, ItemComanda[]>>({
    2: [
      { id_producto: 'lomo', nombre: 'Lomo saltado', precio: 28, cantidad: 2, observaciones: 'Término medio' },
      { id_producto: 'chicha', nombre: 'Chicha morada', precio: 6, cantidad: 1, observaciones: 'Helada' }
    ]
  });

  const [pedidosListos, setPedidosListos] = useState<{ id_venta: number; mesa: number; hora: string }[]>([
    { id_venta: 104, mesa: 2, hora: '19:15' }
  ]);

  const itemsActuales = mesaSeleccionada ? comanda[mesaSeleccionada.numero] || [] : [];
  const subtotal = itemsActuales.reduce((sum, item) => sum + item.precio * item.cantidad, 0);

  function agregarPlato(plato: typeof dishes[0]) {
    if (!mesaSeleccionada) return;

    setComanda((prev) => {
      const listaMesa = prev[mesaSeleccionada.numero] || [];
      const index = listaMesa.findIndex((i) => i.id_producto === plato.id);

      if (index >= 0) {
        const copia = [...listaMesa];
        copia[index] = { ...copia[index], cantidad: copia[index].cantidad + 1 };
        return { ...prev, [mesaSeleccionada.numero]: copia };
      }

      return {
        ...prev,
        [mesaSeleccionada.numero]: [
          ...listaMesa,
          { id_producto: plato.id, nombre: plato.name, precio: plato.price, cantidad: 1, observaciones: '' }
        ]
      };
    });

    if (mesaSeleccionada.estado === 'libre') {
      actualizarEstadoMesa(mesaSeleccionada.id_mesa, 'ocupada');
    }
  }

  function cambiarCantidad(id_producto: string, delta: number) {
    if (!mesaSeleccionada) return;

    setComanda((prev) => {
      const listaMesa = prev[mesaSeleccionada.numero] || [];
      const nuevaLista = listaMesa
        .map((item) => {
          if (item.id_producto === id_producto) {
            return { ...item, cantidad: item.cantidad + delta };
          }
          return item;
        })
        .filter((item) => item.cantidad > 0);

      return { ...prev, [mesaSeleccionada.numero]: nuevaLista };
    });
  }

  function actualizarObservacion(id_producto: string, obs: string) {
    if (!mesaSeleccionada) return;

    setComanda((prev) => {
      const listaMesa = prev[mesaSeleccionada.numero] || [];
      return {
        ...prev,
        [mesaSeleccionada.numero]: listaMesa.map((item) =>
          item.id_producto === id_producto ? { ...item, observaciones: obs } : item
        )
      };
    });
  }

  function actualizarEstadoMesa(id_mesa: number, nuevoEstado: Mesa['estado']) {
    setMesas((prev) =>
      prev.map((m) => (m.id_mesa === id_mesa ? { ...m, estado: nuevoEstado } : m))
    );
    if (mesaSeleccionada?.id_mesa === id_mesa) {
      setMesaSeleccionada((prev) => (prev ? { ...prev, estado: nuevoEstado } : null));
    }
  }

  function enviarCocina() {
    if (!mesaSeleccionada || itemsActuales.length === 0) return;
    alert(`Comanda de Mesa ${mesaSeleccionada.numero} enviada a cocina (${itemsActuales.length} ítems).`);
  }

  function atenderPedidoListo(id_venta: number) {
    setPedidosListos((prev) => prev.filter((p) => p.id_venta !== id_venta));
  }

  const estadoColores: Record<Mesa['estado'], { bg: string; text: string; border: string }> = {
    libre: { bg: '#e1e9de', text: '#1f3d2b', border: '#1f3d2b' },
    ocupada: { bg: '#fed7aa', text: '#9a3412', border: '#ea580c' },
    reservada: { bg: '#e0f2fe', text: '#0369a1', border: '#0284c7' }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {pedidosListos.length > 0 && (
        <div style={{
          background: '#fef3c7',
          border: '1px solid #f59e0b',
          borderRadius: '4px',
          padding: '14px 18px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center'
        }}>
          <div>
            <strong style={{ color: '#92400e' }}>Platos listos en cocina:</strong>
            <span style={{ marginLeft: '8px', color: '#78350f' }}>
              Mesa {pedidosListos.map((p) => p.mesa).join(', ')} lista para servir.
            </span>
          </div>
          <button
            type="button"
            onClick={() => atenderPedidoListo(pedidosListos[0].id_venta)}
            style={{
              background: '#d97706',
              color: '#fff',
              border: 'none',
              padding: '6px 14px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontWeight: 600,
              fontSize: '0.85rem'
            }}
          >
            Servir pedido
          </button>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '28px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div>
            <h2 style={{ fontFamily: 'var(--font-display)', margin: '0 0 14px' }}>Salón de Mesas</h2>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(130px, 1fr))', gap: '14px' }}>
              {mesas.map((mesa) => {
                const color = estadoColores[mesa.estado];
                const isSelected = mesaSeleccionada?.id_mesa === mesa.id_mesa;

                return (
                  <button
                    key={mesa.id_mesa}
                    type="button"
                    onClick={() => setMesaSeleccionada(mesa)}
                    style={{
                      background: isSelected ? 'var(--bg-panel-2)' : color.bg,
                      border: `2px solid ${isSelected ? 'var(--ink)' : color.border}`,
                      borderRadius: '6px',
                      padding: '16px 12px',
                      cursor: 'pointer',
                      textAlign: 'center',
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      gap: '4px'
                    }}
                  >
                    <span style={{ fontSize: '1.2rem', fontWeight: 700, color: 'var(--ink)' }}>
                      Mesa {mesa.numero}
                    </span>
                    <span style={{ fontSize: '0.78rem', color: 'var(--ink-soft)' }}>
                      Capacidad: {mesa.capacidad} pers.
                    </span>
                    <span style={{
                      fontSize: '0.72rem',
                      fontWeight: 700,
                      textTransform: 'uppercase',
                      color: color.text,
                      marginTop: '4px'
                    }}>
                      {mesa.estado}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>

          <div>
            <h3 style={{ fontFamily: 'var(--font-display)', margin: '0 0 12px' }}>Agregar platos a la mesa</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '10px' }}>
              {dishes.map((dish) => (
                <button
                  key={dish.id}
                  type="button"
                  onClick={() => agregarPlato(dish)}
                  style={{
                    background: 'var(--white)',
                    border: '1px solid var(--line)',
                    borderRadius: '4px',
                    padding: '10px 12px',
                    textAlign: 'left',
                    cursor: 'pointer',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '4px'
                  }}
                >
                  <strong style={{ fontSize: '0.88rem', color: 'var(--ink)' }}>{dish.name}</strong>
                  <span style={{ fontSize: '0.8rem', color: 'var(--gold)', fontWeight: 600 }}>
                    S/ {dish.price.toFixed(2)}
                  </span>
                </button>
              ))}
            </div>
          </div>
        </div>

        <aside style={{
          background: 'var(--bg-panel)',
          border: '1px solid var(--line)',
          borderRadius: '4px',
          padding: '24px 20px',
          display: 'flex',
          flexDirection: 'column',
          gap: '16px'
        }}>
          {mesaSeleccionada ? (
            <>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h2 style={{ fontFamily: 'var(--font-display)', margin: 0 }}>
                    Comanda Mesa {mesaSeleccionada.numero}
                  </h2>
                  <span style={{ fontSize: '0.8rem', color: 'var(--ink-soft)' }}>
                    Estado actual: {mesaSeleccionada.estado}
                  </span>
                </div>
                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    type="button"
                    onClick={() => actualizarEstadoMesa(mesaSeleccionada.id_mesa, 'libre')}
                    style={{
                      background: 'transparent',
                      border: '1px solid var(--line)',
                      borderRadius: '4px',
                      padding: '4px 8px',
                      fontSize: '0.75rem',
                      cursor: 'pointer'
                    }}
                  >
                    Liberar
                  </button>
                  <button
                    type="button"
                    onClick={() => actualizarEstadoMesa(mesaSeleccionada.id_mesa, 'ocupada')}
                    style={{
                      background: 'var(--green)',
                      color: 'var(--white)',
                      border: 'none',
                      borderRadius: '4px',
                      padding: '4px 8px',
                      fontSize: '0.75rem',
                      cursor: 'pointer'
                    }}
                  >
                    Ocupar
                  </button>
                </div>
              </div>

              {itemsActuales.length === 0 ? (
                <div style={{ padding: '30px 0', textAlign: 'center', color: 'var(--ink-faint)', fontSize: '0.88rem' }}>
                  Sin platos agregados. Selecciona un plato de la lista.
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {itemsActuales.map((item) => (
                    <div
                      key={item.id_producto}
                      style={{
                        background: 'var(--white)',
                        border: '1px solid var(--line)',
                        borderRadius: '4px',
                        padding: '10px'
                      }}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                        <span style={{ fontWeight: 600, fontSize: '0.88rem' }}>{item.nombre}</span>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <button
                            type="button"
                            onClick={() => cambiarCantidad(item.id_producto, -1)}
                            style={{
                              width: '22px',
                              height: '22px',
                              borderRadius: '50%',
                              border: '1px solid var(--line)',
                              background: 'transparent',
                              cursor: 'pointer'
                            }}
                          >
                            -
                          </button>
                          <span style={{ fontSize: '0.85rem', fontWeight: 600, minWidth: '16px', textAlign: 'center' }}>
                            {item.cantidad}
                          </span>
                          <button
                            type="button"
                            onClick={() => cambiarCantidad(item.id_producto, 1)}
                            style={{
                              width: '22px',
                              height: '22px',
                              borderRadius: '50%',
                              border: '1px solid var(--line)',
                              background: 'transparent',
                              cursor: 'pointer'
                            }}
                          >
                            +
                          </button>
                          <span style={{ marginLeft: '8px', fontWeight: 600, fontSize: '0.88rem', minWidth: '60px', textAlign: 'right' }}>
                            S/ {(item.precio * item.cantidad).toFixed(2)}
                          </span>
                        </div>
                      </div>

                      <input
                        type="text"
                        placeholder="Nota comanda (ej. sin picante, término medio)"
                        value={item.observaciones}
                        onChange={(e) => actualizarObservacion(item.id_producto, e.target.value)}
                        style={{
                          width: '100%',
                          padding: '6px 8px',
                          fontSize: '0.78rem',
                          border: '1px solid var(--line)',
                          borderRadius: '3px',
                          boxSizing: 'border-box'
                        }}
                      />
                    </div>
                  ))}

                  <div style={{ borderTop: '1px solid var(--line)', paddingTop: '12px', marginTop: '4px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '1rem', fontWeight: 700 }}>
                      <span>Subtotal Consumo:</span>
                      <span style={{ color: 'var(--gold)' }}>S/ {subtotal.toFixed(2)}</span>
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={enviarCocina}
                    style={{
                      background: 'var(--green)',
                      color: 'var(--white)',
                      border: 'none',
                      borderRadius: '4px',
                      padding: '12px',
                      fontWeight: 600,
                      cursor: 'pointer',
                      marginTop: '8px'
                    }}
                  >
                    Enviar Comanda a Cocina
                  </button>
                </div>
              )}
            </>
          ) : (
            <p style={{ color: 'var(--ink-faint)', textAlign: 'center' }}>Selecciona una mesa para gestionar su comanda.</p>
          )}
        </aside>
      </div>
    </div>
  );
}
