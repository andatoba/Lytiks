from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import cubo, destinos, empresas, totales
from app.database import engine, Base
import os

# Crear las tablas si no existen (opcional, solo para verificar conexión)
# Base.metadata.create_all(bind=engine)

# Obtener la IP del servidor desde variable de entorno
SERVER_IP = os.getenv("SERVER_IP", "localhost")
SERVER_PORT = os.getenv("API_PORT", "8083")

app = FastAPI(
    title="Aqualytiks API",
    description="API de solo consulta para la base de datos Aqualytiks",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    servers=[
        {
            "url": f"http://{SERVER_IP}:{SERVER_PORT}",
            "description": "Servidor de Producción"
        },
        {
            "url": "http://localhost:8083",
            "description": "Servidor Local"
        }
    ]
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica los orígenes permitidos
    allow_credentials=True,
    allow_methods=["GET"],  # Solo permitir GET (consultas)
    allow_headers=["*"],
)

# Incluir routers
app.include_router(cubo.router)
app.include_router(destinos.router)
app.include_router(empresas.router)
app.include_router(totales.router)

@app.get("/", tags=["Health"])
def root():
    return {
        "message": "Aqualytiks API - Solo Consultas",
        "status": "online",
        "docs": "/docs",
        "redoc": "/redoc"
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy"}
