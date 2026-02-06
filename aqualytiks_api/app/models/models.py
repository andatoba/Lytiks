from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Date, BigInteger, Boolean, TIMESTAMP
from app.database import Base

class Cubo(Base):
    __tablename__ = "cubo"
    
    id = Column(BigInteger, primary_key=True, index=True)
    id_dt = Column(BigInteger)
    id_destino = Column(BigInteger)
    id_puerto = Column(BigInteger)
    id_empresa = Column(Text)
    valorfob = Column(Float)
    libras = Column(Float)
    cartones = Column(BigInteger)

class Destino(Base):
    __tablename__ = "destinos"
    
    id = Column(BigInteger, primary_key=True, index=True)
    puertodestino = Column(Text)
    país = Column(Text)  # Nota: contiene carácter especial
    mercado = Column(Text)
    continente_orig = Column(Text)

class DT(Base):
    __tablename__ = "dt"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    datevalue = Column(Date, nullable=False)
    year = Column(Integer, nullable=False)
    month = Column(Integer, nullable=False)
    day = Column(Integer, nullable=False)
    iso_week_year = Column(Integer, nullable=False)
    iso_week = Column(Integer, nullable=False)
    unix = Column(BigInteger, nullable=False)
    unix_month = Column(BigInteger, nullable=False)

class Empresa(Base):
    __tablename__ = "empresas"
    
    id = Column(Text, primary_key=True, index=True)
    razon_social = Column(Text)

class Puerto(Base):
    __tablename__ = "puertos"
    
    id = Column(BigInteger, primary_key=True, index=True)
    nombre = Column(Text)

class TotalesMes(Base):
    __tablename__ = "totales_mes"
    
    id = Column(BigInteger, primary_key=True, index=True)
    id_dt = Column(Float)
    valorfob = Column(Float)
    libras = Column(Float)
    cartones = Column(Float)

class User(Base):
    __tablename__ = "users"
    
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    email_verified_at = Column(TIMESTAMP)
    password = Column(String(255), nullable=False)
    remember_token = Column(String(100))
    is_admin = Column(Boolean, default=False, nullable=False)
    created_at = Column(TIMESTAMP)
    updated_at = Column(TIMESTAMP)
