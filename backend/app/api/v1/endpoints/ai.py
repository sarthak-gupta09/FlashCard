from fastapi import APIRouter, HTTPException, status
from app.schemas.ai import DistractorRequest, DistractorResponse
from app.services.ai_service import ai_service

router = APIRouter()


@router.post(
    "/generate-distractors",
    response_model=DistractorResponse,
    status_code=status.HTTP_200_OK,
    summary="Generate 3 Medically Plausible MCQ Distractors",
    description="Takes a question and 1 correct answer. Returns 3 plausible distractors and 4 formatted options A-D."
)
async def generate_distractors(request: DistractorRequest):
    if not request.question.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Question cannot be empty"
        )
    if not request.correct_answer.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Correct answer cannot be empty"
        )
    
    try:
        response = await ai_service.generate_distractors(request)
        return response
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Distractor generation failed: {str(e)}"
        )
