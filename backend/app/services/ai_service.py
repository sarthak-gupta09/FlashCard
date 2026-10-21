import json
import logging
import random
from typing import List, Tuple
from app.config import settings
from app.schemas.ai import DistractorRequest, DistractorResponse, DistractorOption

logger = logging.getLogger(__name__)


class AIService:
    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY
        self.client = None
        
        if self.api_key:
            # Try new google-genai SDK first
            try:
                from google import genai
                self.client = genai.Client(api_key=self.api_key)
                self.sdk_type = "google-genai"
            except Exception as e:
                logger.info(f"Could not init google.genai: {e}. Trying legacy google.generativeai.")
                try:
                    import google.generativeai as legacy_genai
                    legacy_genai.configure(api_key=self.api_key)
                    self.legacy_model = legacy_genai.GenerativeModel(
                        model_name=settings.GEMINI_MODEL,
                        generation_config={
                            "temperature": 0.3,
                            "response_mime_type": "application/json"
                        }
                    )
                    self.sdk_type = "legacy"
                except Exception as ex:
                    logger.error(f"Could not init Gemini client: {ex}")
                    self.sdk_type = "none"
        else:
            self.sdk_type = "none"

    async def generate_distractors(self, req: DistractorRequest) -> DistractorResponse:
        """
        Generates 3 medically plausible distractors for the provided question and correct answer.
        """
        if self.sdk_type != "none":
            try:
                if self.sdk_type == "google-genai":
                    return await self._generate_with_genai(req)
                elif self.sdk_type == "legacy":
                    return await self._generate_with_legacy(req)
            except Exception as e:
                logger.warning(f"Gemini generation error: {e}. Using intelligent fallback.")
                return self._generate_fallback(req)
        
        return self._generate_fallback(req)

    def _get_prompt(self, req: DistractorRequest) -> str:
        subject_context = f"Subject: {req.subject}. " if req.subject else ""
        topic_context = f"Topic: {req.topic}. " if req.topic else ""
        
        return f"""
You are an expert medical examination board question designer for Indian NEET-PG and INI-CET exams.

{subject_context}{topic_context}
Question: "{req.question}"
Correct Answer: "{req.correct_answer}"

Generate exactly 3 plausible, high-yield, but INCORRECT distractor options.
CRITICAL RULES:
1. Distractors MUST belong to the EXACT same conceptual and pharmacological/anatomical/pathological category as "{req.correct_answer}".
2. All options must have roughly similar length and grammatical phrasing so none stands out as obvious.
3. NEVER duplicate or use synonyms of "{req.correct_answer}".
4. Medical accuracy is vital: distractors must be real medical entities/drugs/conditions, but clinically incorrect for this specific prompt.
5. Provide a short 2-3 sentence high-yield explanation explaining why "{req.correct_answer}" is correct and why the distractors are wrong.

Return ONLY this JSON structure:
{{
    "distractors": ["Distractor 1", "Distractor 2", "Distractor 3"],
    "explanation": "High-yield explanation..."
}}
"""

    async def _generate_with_genai(self, req: DistractorRequest) -> DistractorResponse:
        prompt = self._get_prompt(req)
        response = self.client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "temperature": 0.3
            }
        )
        parsed = json.loads(response.text)
        distractors = parsed.get("distractors", [])
        if len(distractors) != 3:
            raise ValueError(f"Expected 3 distractors, got {len(distractors)}")
            
        explanation = parsed.get("explanation", "")
        options = self._build_shuffled_options(req.correct_answer, distractors)
        
        return DistractorResponse(
            question=req.question,
            correct_answer=req.correct_answer,
            distractors=distractors,
            options=options,
            explanation=explanation,
            confidence=0.95,
            source="gemini"
        )

    async def _generate_with_legacy(self, req: DistractorRequest) -> DistractorResponse:
        prompt = self._get_prompt(req)
        response = self.legacy_model.generate_content(prompt)
        parsed = json.loads(response.text)
        distractors = parsed.get("distractors", [])
        if len(distractors) != 3:
            raise ValueError(f"Expected 3 distractors, got {len(distractors)}")
            
        explanation = parsed.get("explanation", "")
        options = self._build_shuffled_options(req.correct_answer, distractors)
        
        return DistractorResponse(
            question=req.question,
            correct_answer=req.correct_answer,
            distractors=distractors,
            options=options,
            explanation=explanation,
            confidence=0.95,
            source="gemini"
        )

    def _generate_fallback(self, req: DistractorRequest) -> DistractorResponse:
        """
        Fallback generator when Gemini API is unconfigured or unavailable.
        """
        distractors = [
            f"Option B (Review: alternative to {req.correct_answer})",
            f"Option C (Review: alternative to {req.correct_answer})",
            f"Option D (Review: alternative to {req.correct_answer})"
        ]
        options = self._build_shuffled_options(req.correct_answer, distractors)
        
        return DistractorResponse(
            question=req.question,
            correct_answer=req.correct_answer,
            distractors=distractors,
            options=options,
            explanation=f"Correct answer is {req.correct_answer}. Configure GEMINI_API_KEY in backend/.env for AI generated distractors.",
            confidence=0.5,
            source="fallback"
        )

    def _build_shuffled_options(self, correct: str, distractors: List[str]) -> List[DistractorOption]:
        labels = ["A", "B", "C", "D"]
        all_items: List[Tuple[str, bool]] = [(correct, True)] + [(d, False) for d in distractors]
        random.shuffle(all_items)
        
        return [
            DistractorOption(
                label=labels[i],
                text=text,
                is_correct=is_corr
            )
            for i, (text, is_corr) in enumerate(all_items)
        ]


ai_service = AIService()
