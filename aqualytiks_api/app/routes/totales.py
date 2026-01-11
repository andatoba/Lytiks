from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.models.models import TotalesMes

router = APIRouter(prefix="/totales", tags=["Totales por Mes"])

@router.get("/", summary="Obtener totales por mes")
def get_totales(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    id_dt: Optional[float] = Query(None, description="ID de dimensión temporal"),
    db: Session = Depends(get_db)
):
    query = db.query(TotalesMes)
    
    if id_dt:
        query = query.filter(TotalesMes.id_dt == id_dt)
    
    total = query.count()
    results = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "data": results
    }

@router.get("/{total_id}", summary="Obtener un total por ID")
def get_total(total_id: int, db: Session = Depends(get_db)):
    total = db.query(TotalesMes).filter(TotalesMes.id == total_id).first()
    if not total:
        raise HTTPException(status_code=404, detail="Total no encontrado")
    return total
