from google import genai
from typing import List, Dict, Any
import logging
from datetime import datetime
import os

logger = logging.getLogger(__name__)

class DiaryPsychologistAdvisor:
    """Psychologist class to provide advice based on user diaries"""
    
    def __init__(self, api_key: str = None, model: str = "gemini-2.5-flash"):
        if api_key is None:
            api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            raise ValueError("Gemini API key is required")

        self.client = genai.Client(api_key=api_key)
        self.model_name = model
        
        self.advice_prompt = """
        You are a compassionate psychologist and life coach. Based on the user's diary entries and their personality profile, provide personalized advice and motivational guidance.

        Analyze the user's diary entries and do TWO things:
        1) FIRST, classify the user's overall emotional mood (choose ONLY ONE from: Happy, Sad, Anxious, Angry, Calm, Confused)
        2) THEN, provide comprehensive psychological advice

        USER PROFILE:
        - MBTI Personality: {character_type}
        - Zodiac Sign: {sign}

        USER'S DIARY ENTRIES:
        {diary_text}

        **YOUR RESPONSE MUST START WITH THE MOOD LABEL ON ITS OWN LINE:**
        [Mood: Your chosen mood label]

        **THEN PROVIDE ADVICE WITH THESE EXACT SECTIONS:**

        **Emotional Patterns:**
        [Analyze recurring emotions, concerns, and mental states from the diaries]

        **Strengths & Challenges:**
        [Connect diary content with their personality traits]

        **Practical Recommendations:**
        [Suggest specific activities, coping strategies, or mindset shifts]

        **Motivational Guidance:**
        [Offer encouraging words and perspective]

        **Growth Opportunities:**
        [Areas for personal development based on diary patterns]

        Write in a warm, empathetic tone. Use the same language as the diary entries.
        Keep your response between 300-400 words.
        Follow this structure exactly.
        """

    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str = None) -> Dict[str, Any]:
            """Analyze user diaries and provide psychological advice"""
            try:
                if not diaries:
                    return self._provide_general_advice(character_type, sign)

                # Prepare diary text (limit length to avoid token limits)
                combined_diaries = self._prepare_diary_text(diaries)

                prompt = self.advice_prompt.format(
                    diary_text=combined_diaries,
                    character_type=character_type,
                    sign=sign
                )

                # Generate content using the new SDK with system instruction
                response = self.client.models.generate_content(
                    model=self.model_name,
                    contents=prompt,
                    config={
                        "system_instruction": "You are a compassionate psychologist and life coach. You MUST follow the response structure exactly as specified in the prompt.",
                        "temperature": 0.7,
                        "top_p": 0.9
                    }
                )

                # Extract mood from the response
                mood = self._extract_mood_from_response(response.text)
                
                # If response doesn't follow structure, enforce it
                advice_text = response.text
                if not advice_text.strip().startswith("[Mood:"):
                    advice_text = self._enforce_response_structure(advice_text, mood, character_type, sign)

                return {
                    "mood": mood,
                    "advice": advice_text,
                    "analysis_date": datetime.utcnow().isoformat(),
                    "diaries_analyzed": len(diaries),
                    "model_used": self.model_name,
                    "status": "success"
                }

            except Exception as e:
                logger.error(f"Error analyzing diaries: {str(e)}")
                return {
                    "advice": self._get_fallback_advice(character_type, sign),
                    "analysis_date": datetime.utcnow().isoformat(),
                    "diaries_analyzed": len(diaries) if diaries else 0,
                    "status": "error",
                    "error": str(e)
                }

    def _extract_mood_from_response(self, response_text: str) -> str:
        """Extract mood label from the AI response"""
        # Mood labels to look for
        mood_labels = ["Happy", "Sad", "Anxious", "Angry", "Calm", "Confused"]
        
        # First check for structured mood label
        lines = response_text.split('\n')
        for line in lines:
            line = line.strip()
            if line.startswith("[Mood:"):
                for mood in mood_labels:
                    if mood.lower() in line.lower():
                        return mood
        
        # Fallback: Check for each mood label in the response
        response_lower = response_text.lower()
        for mood in mood_labels:
            if mood.lower() in response_lower:
                return mood
        
        # Default to "Calm" if no mood found
        return "Calm"
    
    def _enforce_response_structure(self, response_text: str, mood: str, character_type: str, sign: str) -> str:
        """Enforce the response structure if AI doesn't follow it"""
        structured_response = f"[Mood: {mood}]\n\n"
        
        # Check if response already has sections
        sections = [
            "**Emotional Patterns:**",
            "**Strengths & Challenges:**",
            "**Practical Recommendations:**",
            "**Motivational Guidance:**",
            "**Growth Opportunities:**"
        ]
        
        has_sections = any(section in response_text for section in sections)
        
        if has_sections:
            # If it has some structure, use it as is
            structured_response += response_text
        else:
            # If completely unstructured, create a structured version
            structured_response += f"""**Emotional Patterns:**
Based on your diary entries, I notice {mood.lower()} emotions are prominent. Your entries reveal...

**Strengths & Challenges:**
As a {character_type}, you bring specific strengths to these situations. Your {sign} nature suggests...

**Practical Recommendations:**
1. Try journaling about...
2. Consider implementing...
3. Practice...

**Motivational Guidance:**
Remember that every emotion serves a purpose. Your journey of self-discovery is valuable and shows great courage.

**Growth Opportunities:**
This experience provides an opportunity to develop deeper emotional awareness and resilience."""
        
        return structured_response
    
    def _prepare_diary_text(self, diaries: List[str]) -> str:
        """Prepare diary text for analysis, limiting total length"""
        # Take only recent diaries and limit each entry length
        recent_diaries = diaries[:5]  # Last 5 diaries
        prepared_entries = []
        
        for i, diary in enumerate(recent_diaries, 1):
            # Clean and truncate if too long
            clean_diary = diary.strip()
            if len(clean_diary) > 500:
                clean_diary = clean_diary[:500] + "..."
            prepared_entries.append(f"Entry {i}: {clean_diary}")
        
        return "\n\n".join(prepared_entries)
    
    def _provide_general_advice(self, character_type: str, sign: str) -> Dict[str, Any]:
        """Provide general advice when no diaries are available"""
        try:
            prompt = f"""
            Provide warm, encouraging psychological advice for someone with:
            - Personality type: {character_type}
            - Zodiac sign: {sign}
            
            This person hasn't written any diaries yet. Please provide:
            - Encouragement to start journaling and its benefits
            - General insights about their {character_type} personality type
            - Motivational guidance for self-reflection
            - Keep it positive, supportive, and around 150-200 words
            
            **Start your response with:** [Mood: Calm]
            """
            
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            
            return {
                "mood": "Calm",
                "advice": response.text,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "model_used": self.model_name,
                "status": "success"
            }
        except Exception as e:
            logger.error(f"Error providing general advice: {e}")
            return {
                "mood": "Calm",
                "advice": self._get_fallback_advice(character_type, sign),
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "status": "success"
            }
    
    def _get_fallback_advice(self, character_type: str, sign: str) -> str:
        """Provide fallback advice when AI service is unavailable"""
        return f"""[Mood: Calm]

**Emotional Patterns:**
Starting a journaling practice is the first step toward greater emotional awareness.

**Strengths & Challenges:**
As a {character_type}, you likely have rich inner thoughts that deserve expression. Your {sign} nature suggests you may benefit from regular emotional check-ins.

**Practical Recommendations:**
Start by writing about:
- Your current feelings and experiences
- Things you're grateful for today
- Challenges you're facing and how you're handling them
- Goals and aspirations that motivate you

**Motivational Guidance:**
I'm here to support your emotional well-being journey! Journaling can be a powerful tool for self-discovery.

**Growth Opportunities:**
Regular reflection can help you develop greater self-awareness and emotional intelligence. This is your safe space for honest self-expression."""