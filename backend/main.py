import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from routers import auth, productos, mesas, ventas, cocina, caja

load_dotenv()

app = FastAPI(
    title="La Caleta del Sabor — API",
    version="1.0.0",
    description="Backend del sistema de gestión del restaurante.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[os.getenv("FRONTEND_URL", "http://localhost:4321")],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(productos.router)
app.include_router(mesas.router)
app.include_router(ventas.router)
app.include_router(cocina.router)
app.include_router(caja.router)


@app.get("/health")
def health():
    return {"status": "ok"}