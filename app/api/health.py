"""
Application health-check endpoints.
"""

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app.db.database import engine


router = APIRouter()


@router.get("/health/live")
def liveness() -> dict:
    """
    Liveness check.

    Confirms that the application process is running.
    This endpoint does not depend on the database.
    """

    return {
        "status": "ok",
        "service": "platform-api",
    }


@router.get("/health/ready")
def readiness():
    """
    Readiness check.

    Confirms that the application can communicate
    with the PostgreSQL database.
    """

    if engine is None:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "service": "platform-api",
                "database": "not_configured",
            },
        )

    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        return {
            "status": "ok",
            "service": "platform-api",
            "database": "connected",
        }

    except Exception:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "service": "platform-api",
                "database": "unavailable",
            },
        )