import type { Cart, Channel, Dish } from "../types/menu.ts";

interface CartSidebarProps {
  cart: Cart;
  channel: Channel;
  onChannelChange: (channel: Channel) => void;
  address: string;
  onAddressChange: (value: string) => void;
  onAdd: (dish: Dish) => void;
  onRemove: (dishId: string) => void;
  onCheckout: () => void;
}

const DELIVERY_FEE = 5;

export default function CartSidebar({
  cart,
  channel,
  onChannelChange,
  address,
  onAddressChange,
  onAdd,
  onRemove,
  onCheckout,
}: CartSidebarProps) {
  const items = Object.values(cart);
  const isDelivery = channel === "delivery";
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const total = subtotal + (isDelivery ? DELIVERY_FEE : 0);

  return (
    <aside className="cart">
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "14px" }}>
        <h2 style={{ margin: 0 }}>Tu pedido</h2>
        <div className="channel-toggle">
          <button
            type="button"
            className={channel === "presencial" ? "on" : ""}
            onClick={() => onChannelChange("presencial")}
          >
            Salón
          </button>
          <button
            type="button"
            className={channel === "delivery" ? "on" : ""}
            onClick={() => onChannelChange("delivery")}
          >
            Delivery
          </button>
        </div>
      </div>

      <p className="cart-sub">
        {isDelivery ? "Modalidad: Delivery a domicilio (+S/ 5.00)" : "Modalidad: Atención en salón / Recojo"}
      </p>

      {items.length === 0 ? (
        <div className="cart-empty">Aún no agregaste ningún plato al pedido.</div>
      ) : (
        <>
          <ul className="cart-items">
            {items.map((item) => (
              <li key={item.id} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 0" }}>
                <div>
                  <span className="name" style={{ display: "block", fontWeight: 600 }}>{item.name}</span>
                  <span style={{ fontSize: "0.78rem", color: "var(--ink-faint)" }}>S/ {item.price.toFixed(2)} c/u</span>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                  <button
                    type="button"
                    onClick={() => onRemove(item.id)}
                    style={{
                      width: "22px",
                      height: "22px",
                      borderRadius: "50%",
                      border: "1px solid var(--line)",
                      background: "var(--white)",
                      cursor: "pointer",
                      display: "inline-flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontWeight: "bold",
                    }}
                    aria-label="Restar uno"
                  >
                    -
                  </button>
                  <span style={{ fontWeight: 600, minWidth: "18px", textAlign: "center", fontSize: "0.85rem" }}>
                    {item.qty}
                  </span>
                  <button
                    type="button"
                    onClick={() => onAdd({ id: item.id, name: item.name, price: item.price } as Dish)}
                    style={{
                      width: "22px",
                      height: "22px",
                      borderRadius: "50%",
                      border: "1px solid var(--line)",
                      background: "var(--white)",
                      cursor: "pointer",
                      display: "inline-flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontWeight: "bold",
                    }}
                    aria-label="Agregar uno más"
                  >
                    +
                  </button>
                  <span className="amt" style={{ marginLeft: "8px", minWidth: "65px", textAlign: "right" }}>
                    S/ {(item.price * item.qty).toFixed(2)}
                  </span>
                </div>
              </li>
            ))}
          </ul>

          <div className="cart-totals">
            <div className="row">
              <span>Subtotal</span>
              <span>S/ {subtotal.toFixed(2)}</span>
            </div>
            {isDelivery && (
              <div className="row">
                <span>Costo Delivery</span>
                <span>S/ {DELIVERY_FEE.toFixed(2)}</span>
              </div>
            )}
            <div className="row total">
              <span>Total Estimado</span>
              <span>S/ {total.toFixed(2)}</span>
            </div>
          </div>
        </>
      )}

      {isDelivery && (
        <div className="field show">
          <label htmlFor="address">Dirección de entrega</label>
          <input
            id="address"
            type="text"
            placeholder="Av. Universitaria 1801, San Miguel"
            value={address}
            onChange={(e) => onAddressChange(e.target.value)}
          />
        </div>
      )}

      <button
        className="checkout-btn"
        disabled={items.length === 0 || (isDelivery && !address.trim())}
        onClick={onCheckout}
      >
        {isDelivery && !address.trim() && items.length > 0
          ? "Ingresa tu dirección para continuar"
          : "Confirmar y enviar a caja"}
      </button>

      <p className="checkout-note">
        El cálculo final de impuestos (IGV) y la creación de la venta serán procesados por el backend en la base de datos.
      </p>
    </aside>
  );
}
