"""
User API endpoints.
"""

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import select

from app.db.database import SessionLocal
from app.db.models import User


router = APIRouter()


class UserCreate(BaseModel):
    """
    Request model for creating a user.
    """

    name: str
    email: str


@router.get("/users")
def get_users():
    """
    Return users stored in PostgreSQL.
    """

    if SessionLocal is None:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unavailable",
                "message": "Database is not configured",
            },
        )

    db = SessionLocal()

    try:
        result = db.execute(
            select(User).order_by(User.id)
        )

        users = [
            {
                "id": user.id,
                "name": user.name,
                "email": user.email,
            }
            for user in result.scalars().all()
        ]

        return {
            "users": users,
        }

    except Exception:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": "Unable to retrieve users",
            },
        )

    finally:
        db.close()


@router.post("/users", status_code=201)
def create_user(user_data: UserCreate):
    """
    Create a new user in PostgreSQL.
    """

    if SessionLocal is None:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unavailable",
                "message": "Database is not configured",
            },
        )

    db = SessionLocal()

    try:
        existing_user = db.execute(
            select(User).where(
                User.email == user_data.email
            )
        ).scalar_one_or_none()

        if existing_user:
            return JSONResponse(
                status_code=409,
                content={
                    "status": "error",
                    "message": "User with this email already exists",
                },
            )

        user = User(
            name=user_data.name,
            email=user_data.email,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        return {
            "id": user.id,
            "name": user.name,
            "email": user.email,
        }

    except Exception:
        db.rollback()

        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": "Unable to create user",
            },
        )

    finally:
        db.close()