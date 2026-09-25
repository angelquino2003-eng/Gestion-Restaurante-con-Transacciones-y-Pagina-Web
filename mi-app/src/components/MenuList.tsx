import { useState } from "react";
import { categories, dishes } from "../data/menuData";
import type { Category, Dish } from "../types/menu";
 
interface MenuListProps {
  onAdd: (dish: Dish) => void;
}
 
export default function MenuList({ onAdd }: MenuListProps) {
  const [activeCategory, setActiveCategory] = useState<Category>("entradas");
 
  const currentCategory = categories.find((c) => c.id === activeCategory)!;
  const currentDishes = dishes.filter((d) => d.category === activeCategory);
 
  return (
    <div id="menu">
      <div className="tabs">
        {categories.map((cat) => (
          <button
            key={cat.id}
            className={cat.id === activeCategory ? "on" : ""}
            onClick={() => setActiveCategory(cat.id)}
          >
            {cat.label}
          </button>
        ))}
      </div>
 
      <div className="menu-section">
        <h2>{currentCategory.label}</h2>
        <p className="section-note">{currentCategory.note}</p>
 
        {currentDishes.map((dish) => (
          <div className="dish" key={dish.id}>
            <div className="dish-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="var(--green)" strokeWidth="1.5">
                <circle cx="12" cy="12" r="8" />
              </svg>
            </div>
            <div className="dish-info">
              <h3>{dish.name}</h3>
              <p>{dish.description}</p>
            </div>
            <div className="dish-buy">
              <span className="dish-price">S/ {dish.price.toFixed(2)}</span>
              <button
                className="add-btn"
                aria-label={`Agregar ${dish.name}`}
                onClick={() => onAdd(dish)}
              >
                +
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}