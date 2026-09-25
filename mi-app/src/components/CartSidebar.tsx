import type { Cart, Channel } from "../types/menu";
 
interface CartSidebarProps {
  cart: Cart;
  channel: Channel;
  address: string;
  onAddressChange: (value: string) => void;
  onCheckout: () => void;
}
 
const DELIVERY_FEE = 5;
 
export default function CartSidebar({
  cart,
  channel,
  address,
  onAddressChange,
  onCheckout,
}: CartSidebarProps) {
  const items = Object.values(cart);
  const isDelivery = channel === "delivery";
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const total = subtotal + (isDelivery ? DELIVERY_FEE : 0);
 
  return (
    <aside className="cart">
      <h2>Tu pedido</h2>
      <p className="cart-sub">{isDelivery ? "Para delivery" : "Para recoger en salón"}</p>
 
      {items.length === 0 ? (
        <div className="cart-empty">Aún no agregaste ningún plato.</div>
      ) : (
        <>
          <ul className="cart-items">
            {items.map((item) => (
              <li key={item.id}>
                <span className="name">
                  {item.name}
                  <span className="qty">x{item.qty}</span>
                </span>
                <span className="amt">S/ {(item.price * item.qty).toFixed(2)}</span>
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
                <span>Delivery</span>
                <span>S/ {DELIVERY_FEE.toFixed(2)}</span>
              </div>
            )}
            <div className="row total">
              <span>Total</span>
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
            placeholder="Av. Siempre Viva 123"
            value={address}
            onChange={(e) => onAddressChange(e.target.value)}
          />
        </div>
      )}
 
      <button className="checkout-btn" disabled={items.length === 0} onClick={onCheckout}>
        Confirmar y enviar a caja
      </button>
      <p className="checkout-note">
        Esto es un bosquejo visual — todavía no se conecta con caja ni con la base de datos.
      </p>
    </aside>
  );
}