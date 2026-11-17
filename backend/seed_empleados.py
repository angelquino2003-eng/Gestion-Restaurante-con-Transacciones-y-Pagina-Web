"""
Script de utilidad para insertar empleados de prueba con password hasheado.
Ejecutar UNA sola vez: python seed_empleados.py
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from db import get_conn
from auth import hash_password

EMPLEADOS = [
    {"nombre": "Admin Sistema",    "rol": "admin",   "usuario": "admin",   "password": "admin123"},
    {"nombre": "Carlos Mesero",    "rol": "mesero",  "usuario": "carlos",  "password": "mesa123"},
    {"nombre": "Lucia Cajera",     "rol": "cajero",  "usuario": "lucia",   "password": "caja123"},
    {"nombre": "Pedro Cocinero",   "rol": "cocina",  "usuario": "pedro",   "password": "cocina123"},
]

MESAS = [
    (1, 2), (2, 4), (3, 4), (4, 6), (5, 4), (6, 8),
]

CATEGORIAS = ["Entradas", "Platos de fondo", "Bebidas", "Postres"]

PRODUCTOS = [
    ("Causa limeña",           "Papa amarilla prensada, ají amarillo, relleno de pollo y palta.", 15.00, "Entradas"),
    ("Tequeños de queso",      "Masa de pan rellena con queso crema, frita hasta dorar.",         12.00, "Entradas"),
    ("Lomo saltado",           "Res al wok con cebolla, tomate y papas fritas, con arroz.",       28.00, "Platos de fondo"),
    ("Ají de gallina",         "Pollo deshilachado en crema de ají amarillo y nueces, con arroz.",24.00, "Platos de fondo"),
    ("Ceviche clásico",        "Pescado fresco en limón, cebolla morada, ají limo y cilantro.",   32.00, "Platos de fondo"),
    ("Arroz con leche",        "Arroz cocido con leche evaporada, canela y coco rallado.",         8.00, "Postres"),
    ("Suspiro a la limeña",    "Manjar blanco con merengue al oporto y canela.",                  12.00, "Postres"),
    ("Chicha morada",          "Maíz morado, piña, canela y clavo, jarra de 1 litro.",            6.00, "Bebidas"),
    ("Limonada frozen",        "Jugo de limón con hielo granizado y menta.",                      7.00, "Bebidas"),
    ("Agua mineral 600ml",     "Agua San Luis o San Mateo.",                                      3.50, "Bebidas"),
]

def seed():
    conn = get_conn()
    cur = conn.cursor()

    for e in EMPLEADOS:
        cur.execute("SELECT id_empleado FROM empleado WHERE usuario = %s", (e["usuario"],))
        if cur.fetchone():
            print(f"  ya existe: {e['usuario']}")
            continue
        cur.execute(
            "INSERT INTO empleado (nombre, rol, usuario, password_hash) VALUES (%s, %s, %s, %s)",
            (e["nombre"], e["rol"], e["usuario"], hash_password(e["password"])),
        )
        print(f"  creado: {e['usuario']} / {e['password']}")

    for numero, capacidad in MESAS:
        cur.execute("SELECT id_mesa FROM mesa WHERE numero = %s", (numero,))
        if not cur.fetchone():
            cur.execute("INSERT INTO mesa (numero, capacidad) VALUES (%s, %s)", (numero, capacidad))
            print(f"  mesa {numero} creada")

    id_cat = {}
    for cat in CATEGORIAS:
        cur.execute("SELECT id_categoria FROM categoria WHERE nombre = %s", (cat,))
        row = cur.fetchone()
        if row:
            id_cat[cat] = row[0]
        else:
            cur.execute("INSERT INTO categoria (nombre) VALUES (%s)", (cat,))
            id_cat[cat] = cur.lastrowid
            print(f"  categoría creada: {cat}")

    for nombre, desc, precio, cat in PRODUCTOS:
        cur.execute("SELECT id_producto FROM producto WHERE nombre = %s", (nombre,))
        if not cur.fetchone():
            cur.execute(
                "INSERT INTO producto (nombre, descripcion, id_categoria, precio) VALUES (%s, %s, %s, %s)",
                (nombre, desc, id_cat[cat], precio),
            )
            print(f"  producto creado: {nombre}")

    conn.commit()
    conn.close()
    print("\nSeed completado.")

if __name__ == "__main__":
    seed()
