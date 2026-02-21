from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

load_dotenv()

# Configuración de la base de datos
DB_HOST = os.getenv("DB_HOST", "lytiks-new-mysql")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "cla@ISdb$26")
DB_NAME = os.getenv("DB_NAME", "aqualytiks")

# URL de conexión - codificar la contraseña para caracteres especiales
PASSWORD_ENCODED = quote_plus(DB_PASSWORD)
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{PASSWORD_ENCODED}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Crear engine
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600,
    echo=False  # Cambiar a True para ver queries SQL
)

# Sesión de base de datos
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para los modelos
Base = declarative_base()

# Dependencia para obtener la sesión de BD
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
