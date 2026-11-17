# Backend — La Caleta del Sabor

API REST en **Python + FastAPI** que conecta el frontend Astro con la base de datos MySQL `restaurante_ventas_v2`.

## Requisitos previos

- Python 3.11 o superior
- MySQL 8.0 con la base de datos `restaurante_ventas_v2` ya cargada

## Puesta en marcha (primera vez)

### 1. Configurar variables de entorno

```bash
cd backend
copy .env.example .env
```

Abre `.env` y ajusta tu contraseña de MySQL:

```
DB_PASSWORD=tu_password_aqui
JWT_SECRET=cualquier_cadena_larga_y_secreta
```

### 2. Crear entorno virtual e instalar dependencias

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Cargar datos de prueba (una sola vez)

```bash
python seed_empleados.py
```

Crea los siguientes usuarios para hacer login desde el frontend:

| Usuario  | Contraseña | Rol     |
|----------|------------|---------|
| `admin`  | `admin123` | admin   |
| `carlos` | `mesa123`  | mesero  |
| `lucia`  | `caja123`  | cajero  |
| `pedro`  | `cocina123`| cocina  |

También crea 6 mesas, las categorías y los 10 productos del menú.

### 4. Levantar el servidor

```bash
uvicorn main:app --reload --port 8000
```

El servidor queda disponible en `http://localhost:8000`.

## Documentación interactiva (Swagger)

Abre en el navegador: **http://localhost:8000/docs**

Desde ahí puedes probar todos los endpoints directamente, con formularios y sin necesidad de Postman.

## Endpoints principales

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/auth/login` | Login, devuelve JWT |
| `GET` | `/productos` | Lista de platos activos |
| `GET` | `/mesas` | Estado de todas las mesas |
| `PATCH` | `/mesas/{id}/estado` | Cambiar estado de mesa |
| `POST` | `/ventas/presencial` | Crear venta en salón |
| `POST` | `/ventas/delivery` | Crear pedido delivery |
| `PATCH` | `/ventas/{id}/estado` | Avanzar estado de venta |
| `GET` | `/cocina/pedidos` | Cola de pedidos para cocina |
| `GET` | `/cocina/pedidos-listos` | Pedidos listos para servir |
| `GET` | `/caja/activa` | Consultar caja abierta propia |
| `POST` | `/caja/abrir` | Abrir turno de caja |
| `POST` | `/caja/{id}/cerrar` | Cerrar turno (llama `sp_cerrar_caja`) |
| `POST` | `/caja/pago` | Registrar pago y finalizar venta |
| `GET` | `/health` | Verificar que el servidor está vivo |

## Flujo normal de una venta presencial

```
1. POST /auth/login          → token JWT
2. GET  /mesas               → elegir mesa libre
3. POST /ventas/presencial   → crear venta con los items
4. PATCH /ventas/{id}/estado → cocina: en_proceso → listo
5. POST /caja/pago           → cajero confirma pago → estado: finalizada
```
