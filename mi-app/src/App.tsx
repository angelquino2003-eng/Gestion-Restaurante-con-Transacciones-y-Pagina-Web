import { useState } from "react";
import Header from "./components/Header";
import Hero from "./components/Hero";
import MenuList from "./components/MenuList";
import CartSidebar from "./components/CartSidebar";
import type { Cart, Channel, Dish } from "./types/menu";
import "./App.css";
 
export default function App() {
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
 
  function handleCheckout() {
    // Bosquejo visual: aquí, cuando exista el backend, se enviaría
    // el pedido a la API para que entre a caja.
    alert("Bosquejo visual: aquí el pedido pasaría a caja una vez conectemos el backend.");
  }
 
  const cartCount = Object.values(cart).reduce((sum, item) => sum + item.qty, 0);
 
  return (
    <>
      <Header channel={channel} cartCount={cartCount} onChannelChange={setChannel} />
      <Hero />
      <div className="layout">
        <MenuList onAdd={handleAdd} />
        <CartSidebar
          cart={cart}
          channel={channel}
          address={address}
          onAddressChange={setAddress}
          onCheckout={handleCheckout}
        />
      </div>
    </>
  );
}
