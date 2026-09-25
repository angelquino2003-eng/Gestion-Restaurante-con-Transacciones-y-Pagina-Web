import type { Category, Dish } from "../types/menu";
 
export const categories: { id: Category; label: string; note: string }[] = [
  { id: "entradas", label: "Entradas", note: "Para abrir el apetito, a la criolla." },
  { id: "fondos", label: "Platos de fondo", note: "Los clásicos de siempre, recién salidos de la cocina." },
  { id: "bebidas", label: "Bebidas", note: "Frescas, para acompañar cualquier plato." },
  { id: "postres", label: "Postres", note: "Para cerrar la comida con algo dulce." },
];
 
export const dishes: Dish[] = [
  {
    id: "causa",
    name: "Causa limeña",
    description: "Papa amarilla prensada, ají amarillo, relleno de pollo y palta.",
    price: 15.0,
    category: "entradas",
  },
  {
    id: "lomo",
    name: "Lomo saltado",
    description: "Res salteada al wok con cebolla, tomate y papas fritas, acompañado de arroz.",
    price: 28.0,
    category: "fondos",
  },
  {
    id: "aji",
    name: "Ají de gallina",
    description: "Pollo deshilachado en crema de ají amarillo y nueces, con arroz y huevo.",
    price: 24.0,
    category: "fondos",
  },
  {
    id: "chicha",
    name: "Chicha morada",
    description: "Maíz morado, piña, canela y clavo de olor, jarra de 1 litro.",
    price: 6.0,
    category: "bebidas",
  },
  {
    id: "suspiro",
    name: "Suspiro a la limeña",
    description: "Manjar blanco con merengue al oporto y canela.",
    price: 12.0,
    category: "postres",
  },
];