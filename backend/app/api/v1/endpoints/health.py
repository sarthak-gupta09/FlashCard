from fastapi import APIRouter
from app.config import settings

router = APIRouter()


@router.get("/health", summary="Service Health Check")
async def health_check():
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "environment": settings.ENVIRONMENT,
        "gemini_configured": bool(settings.GEMINI_API_KEY)
    }
