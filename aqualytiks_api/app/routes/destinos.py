from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.models.models import Destino

router = APIRouter(prefix="/destinos", tags=["Destinos"])

@router.get("/", summary="Obtener todos los destinos")
def get_destinos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    mercado: Optional[str] = Query(None, description="Filtrar por mercado"),
    continente: Optional[str] = Query(None, description="Filtrar por continente"),
    db: Session = Depends(get_db)
):
    query = db.query(Destino)
    
    if mercado:
        query = query.filter(Destino.mercado.ilike(f"%{mercado}%"))
    if continente:
        query = query.filter(Destino.continente_orig.ilike(f"%{continente}%"))
    
    total = query.count()
    results = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "data": results
    }

@router.get("/{destino_id}", summary="Obtener un destino por ID")
def get_destino(destino_id: int, db: Session = Depends(get_db)):
    destino = db.query(Destino).filter(Destino.id == destino_id).first()
    if not destino:
        raise HTTPException(status_code=404, detail="Destino no encontrado")
    return destino

@router.get("/buscar/puerto", summary="Buscar destinos por puerto")
def search_destinos(
    q: str = Query(..., min_length=1, description="Texto de búsqueda"),
    db: Session = Depends(get_db)
):
    results = db.query(Destino).filter(Destino.puertodestino.ilike(f"%{q}%")).all()
    return {"total": len(results), "data": results}
