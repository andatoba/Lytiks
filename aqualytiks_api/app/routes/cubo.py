from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from app.database import get_db
from app.models.models import Cubo

router = APIRouter(prefix="/cubo", tags=["Cubo"])

@router.get("/", summary="Obtener todos los registros del cubo")
def get_cubos(
    skip: int = Query(0, ge=0, description="Registros a saltar"),
    limit: int = Query(100, ge=1, le=1000, description="Cantidad de registros"),
    id_empresa: Optional[str] = Query(None, description="ID de empresa"),
    id_destino: Optional[int] = Query(None, description="ID de destino"),
    db: Session = Depends(get_db)
):
    query = db.query(Cubo)
    
    if id_empresa:
        query = query.filter(Cubo.id_empresa == id_empresa)
    if id_destino:
        query = query.filter(Cubo.id_destino == id_destino)
    
    total = query.count()
    results = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "skip": skip,
        "limit": limit,
        "data": results
    }

@router.get("/{cubo_id}", summary="Obtener un registro por ID")
def get_cubo(cubo_id: int, db: Session = Depends(get_db)):
    cubo = db.query(Cubo).filter(Cubo.id == cubo_id).first()
    if not cubo:
        raise HTTPException(status_code=404, detail="Registro no encontrado")
    return cubo

@router.get("/empresa/{id_empresa}", summary="Obtener registros por empresa")
def get_cubos_by_empresa(
    id_empresa: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    query = db.query(Cubo).filter(Cubo.id_empresa == id_empresa)
    total = query.count()
    results = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "id_empresa": id_empresa,
        "data": results
    }
