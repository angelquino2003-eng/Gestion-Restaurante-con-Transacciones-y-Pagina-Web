import type { Channel } from "../types/menu";
 
interface HeaderProps {
  channel: Channel;
  cartCount: number;
  onChannelChange: (channel: Channel) => void;
}
 
export default function Header({ channel, cartCount, onChannelChange }: HeaderProps) {
  return (
    <header className="header">
      <div className="header-inner">
        <div className="brand">
          <svg className="mark" viewBox="0 0 32 32" fill="none">
            <circle cx="16" cy="16" r="15" stroke="var(--green)" strokeWidth="1.4" />
            <path d="M11 20c0-4 2.5-8 5-9 2.5 1 5 5 5 9" stroke="var(--green)" strokeWidth="1.4" strokeLinecap="round" />
            <path d="M16 11V8" stroke="var(--gold)" strokeWidth="1.4" strokeLinecap="round" />
          </svg>
          La Caleta del Sabor
        </div>
 
        <nav className="main-nav">
          <a href="#menu" className="active">Menú</a>
          <a href="#">Nuestra historia</a>
          <a href="#">Locales</a>
        </nav>
 
        <div className="header-right">
          <div className="channel-toggle">
            <button
              className={channel === "presencial" ? "on" : ""}
              onClick={() => onChannelChange("presencial")}
            >
              Recoger en salón
            </button>
            <button
              className={channel === "delivery" ? "on" : ""}
              onClick={() => onChannelChange("delivery")}
            >
              Delivery
            </button>
          </div>
 
          <div className="cart-chip">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
              <path d="M4 6h2l2.2 11.2a2 2 0 0 0 2 1.6h7.1a2 2 0 0 0 2-1.6L21 9H7" />
              <circle cx="10" cy="21" r="1.1" fill="currentColor" stroke="none" />
              <circle cx="18" cy="21" r="1.1" fill="currentColor" stroke="none" />
            </svg>
            <span>Tu pedido</span>
            <span className="cart-count">{cartCount}</span>
          </div>
        </div>
      </div>
    </header>
  );
}