import { useState } from "react";
import MenuList from "./MenuList";
import CartSidebar from "./CartSidebar";
import type { Cart, Channel, Dish } from "../types/menu";

export default function PedidoOnline() {
  const [cart, setCart] = useState<Cart>({});
  const [channel, setChannel] = useState<Channel>("presencial");
  const [address, setAddress] = useState("");

  function handleAdd(dish: Dish) {
    setCart((prev) => {
      const existing = prev[dish.id];
      return {
        ...prev,
        [dish.id]: existing
          ? { ...existing, qty: existing.qty + 1 }
          : { id: dish.id, name: dish.name, price: dish.price, qty: 1 },
      };
    });
  }

  function handleRemove(dishId: string) {
    setCart((prev) => {
      const existing = prev[dishId];
      if (!existing) return prev;
      if (existing.qty <= 1) {
        const copy = { ...prev };
        delete copy[dishId];
        return copy;
      }
      return {
        ...prev,
        [dishId]: { ...existing, qty: existing.qty - 1 },
      };
    });
  }

  function handleCheckout() {
    const totalItems = Object.values(cart).reduce((s, i) => s + i.qty, 0);
    alert(`¡Pedido confirmado! Se enviaron ${totalItems} plato(s) a la cola de pedidos de caja y cocina.`);
  }

  return (
    <div className="layout">
      <MenuList onAdd={handleAdd} />
      <CartSidebar
        cart={cart}
        channel={channel}
        onChannelChange={setChannel}
        address={address}
        onAddressChange={setAddress}
        onAdd={handleAdd}
        onRemove={handleRemove}
        onCheckout={handleCheckout}
      />
    </div>
  );
}
