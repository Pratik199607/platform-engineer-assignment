"""
Main FastAPI application.
"""

from fastapi import FastAPI

from app.api.health import router as health_router
from app.api.users import router as users_router


app = FastAPI(
    title="Internal Platform API",
    description="Platform Engineer Technical Assignment",
    version="1.0.0",
)


app.include_router(
    health_router,
    prefix="/api",
    tags=["Health"],
)

app.include_router(
    users_router,
    prefix="/api",
    tags=["Users"],
)


@app.get(
    "/",
    tags=["Application"],
)
def root() -> dict:
    """
    Return basic application information.
    """

    return {
        "application": "Internal Platform API",
        "status": "running",
        "version": "1.0.0",
    }