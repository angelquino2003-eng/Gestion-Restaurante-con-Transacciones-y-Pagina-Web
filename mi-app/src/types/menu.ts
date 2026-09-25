export type Category = "entradas" | "fondos" | "bebidas" | "postres";
 
export type Channel = "presencial" | "delivery";
 
export interface Dish {
  id: string;
  name: string;
  description: string;
  price: number;
  category: Category;
}
 
export interface CartItem {
  id: string;
  name: string;
  price: number;
  qty: number;
}
 
export type Cart = Record<string, CartItem>;
 