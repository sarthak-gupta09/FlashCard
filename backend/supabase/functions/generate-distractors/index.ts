// ==============================================================================
// 🏥 SUPABASE EDGE FUNCTION: generate-distractors
// Deploy command: supabase functions deploy generate-distractors --no-verify-jwt
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  question: string;
  correct_answer: string;
  subject?: string;
  topic?: string;
}

interface DistractorOption {
  label: "A" | "B" | "C" | "D";
  text: string;
  is_correct: boolean;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { question, correct_answer, subject, topic }: RequestBody = await req.json();

    if (!question || !correct_answer) {
      return new Response(
        JSON.stringify({ error: "question and correct_answer are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

    // Fallback if no Gemini key configured in Supabase secrets
    if (!GEMINI_API_KEY) {
      const fallbackDistractors = [
        `Option B (Review: alternative to ${correct_answer})`,
        `Option C (Review: alternative to ${correct_answer})`,
        `Option D (Review: alternative to ${correct_answer})`,
      ];
      const options = buildShuffledOptions(correct_answer, fallbackDistractors);

      return new Response(
        JSON.stringify({
          question,
          correct_answer,
          distractors: fallbackDistractors,
          options,
          explanation: `Correct answer is ${correct_answer}. Set GEMINI_API_KEY in Supabase secrets for AI distractors.`,
          confidence: 0.5,
          source: "fallback",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Call Gemini 1.5 Flash via REST API
    const subjectContext = subject ? `Subject: ${subject}. ` : "";
    const topicContext = topic ? `Topic: ${topic}. ` : "";

    const prompt = `
You are an expert medical examination board question designer for Indian NEET-PG and INI-CET exams.

${subjectContext}${topicContext}
Question: "${question}"
Correct Answer: "${correct_answer}"

Generate exactly 3 plausible, high-yield, but INCORRECT distractor options.
CRITICAL RULES:
1. Distractors MUST belong to the EXACT same conceptual and pharmacological/anatomical/pathological category as "${correct_answer}".
2. All options must have roughly similar length and grammatical phrasing so none stands out as obvious.
3. NEVER duplicate or use synonyms of "${correct_answer}".
4. Medical accuracy is vital: distractors must be real medical entities/drugs/conditions, but clinically incorrect for this specific prompt.
5. Provide a short 2-3 sentence high-yield explanation explaining why "${correct_answer}" is correct and why the distractors are wrong.

Return ONLY this JSON structure:
{
    "distractors": ["Distractor 1", "Distractor 2", "Distractor 3"],
    "explanation": "High-yield explanation..."
}
`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;

    const geminiRes = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          response_mime_type: "application/json",
          temperature: 0.3,
        },
      }),
    });

    if (!geminiRes.ok) {
      throw new Error(`Gemini API returned status ${geminiRes.status}`);
    }

    const geminiData = await geminiRes.json();
    const rawText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
    const parsed = JSON.parse(rawText);

    const distractors = parsed.distractors || [];
    const explanation = parsed.explanation || "";

    const options = buildShuffledOptions(correct_answer, distractors);

    return new Response(
      JSON.stringify({
        question,
        correct_answer,
        distractors,
        options,
        explanation,
        confidence: 0.95,
        source: "gemini",
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

function buildShuffledOptions(correct: string, distractors: string[]): DistractorOption[] {
  const labels: ("A" | "B" | "C" | "D")[] = ["A", "B", "C", "D"];
  const allItems = [
    { text: correct, is_correct: true },
    ...distractors.map((d) => ({ text: d, is_correct: false })),
  ];

  // Fisher-Yates shuffle
  for (let i = allItems.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [allItems[i], allItems[j]] = [allItems[j], allItems[i]];
  }

  return allItems.map((item, idx) => ({
    label: labels[idx],
    text: item.text,
    is_correct: item.is_correct,
  }));
}
