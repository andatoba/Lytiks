from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.models.models import Empresa

router = APIRouter(prefix="/empresas", tags=["Empresas"])

@router.get("/", summary="Obtener todas las empresas")
def get_empresas(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    total = db.query(Empresa).count()
    results = db.query(Empresa).offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "data": results
    }

@router.get("/{empresa_id}", summary="Obtener una empresa por ID")
def get_empresa(empresa_id: str, db: Session = Depends(get_db)):
    empresa = db.query(Empresa).filter(Empresa.id == empresa_id).first()
    if not empresa:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa

@router.get("/buscar/razon-social", summary="Buscar empresas por razón social")
def search_empresas(
    q: str = Query(..., min_length=1, description="Texto de búsqueda"),
    db: Session = Depends(get_db)
):
    results = db.query(Empresa).filter(Empresa.razon_social.ilike(f"%{q}%")).all()
    return {"total": len(results), "data": results}
