from typing import List, Optional
from pydantic import BaseModel, Field


class DistractorRequest(BaseModel):
    question: str = Field(..., description="The medical question or prompt")
    correct_answer: str = Field(..., description="The definitive correct answer provided by the user")
    subject: Optional[str] = Field(None, description="Medical subject e.g. Pharmacology, Radiology")
    topic: Optional[str] = Field(None, description="Specific topic or sub-specialty")

    model_config = {
        "json_schema_extra": {
            "example": {
                "question": "What is the drug of choice for Trigeminal Neuralgia?",
                "correct_answer": "Carbamazepine",
                "subject": "Pharmacology",
                "topic": "Neuropharmacology"
            }
        }
    }


class DistractorOption(BaseModel):
    label: str  # A, B, C, D
    text: str
    is_correct: bool


class DistractorResponse(BaseModel):
    question: str
    correct_answer: str
    distractors: List[str] = Field(..., min_length=3, max_length=3, description="Exactly 3 incorrect distractors")
    options: List[DistractorOption] = Field(..., description="All 4 formatted options ready for the mobile app")
    explanation: Optional[str] = Field(None, description="Explanation of why the correct answer is right and distractors wrong")
    confidence: float = Field(default=1.0, ge=0.0, le=1.0)
    source: str = Field(default="ai", description="'gemini' or 'fallback'")


class ClinicalVignetteRequest(BaseModel):
    fact: str = Field(..., description="High-yield medical fact to convert into clinical vignette")
    correct_answer: str
    subject: Optional[str] = None


class ClinicalVignetteResponse(BaseModel):
    vignette_question: str
    correct_answer: str
    distractors: List[str]
    options: List[DistractorOption]
    explanation: Optional[str] = None
