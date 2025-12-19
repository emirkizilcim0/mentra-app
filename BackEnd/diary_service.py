import google.generativeai as genai
from typing import List, Dict, Any
import logging
from datetime import datetime
import os

logger = logging.getLogger(__name__)

class DiaryPsychologistAdvisor:
    """Psychologist class to provide advice based on user diaries"""
    
    def __init__(self, api_key: str = None, model: str = "models/gemini-1.5-flash-latest"):
        # Use environment variable for API key if not provided
        if api_key is None:
            api_key=os.getenv("GEMINI_API_KEY")
        
        if not api_key:
            raise ValueError("Gemini API key is required")
        
        genai.configure(api_key=api_key)
        
        # Try to initialize with the specified model, with fallbacks
        self.model = self._initialize_model(model)
        
        self.advice_prompt = """
        You are a compassionate psychologist and life coach. Based on the user's diary entries and their personality profile, provide personalized advice and motivational guidance.

        USER PROFILE:
        - MBTI Personality: {character_type}
        - Zodiac Sign: {sign}

        USER'S DIARY ENTRIES:
        {diary_text}

        Please provide a comprehensive analysis and advice focusing on:

        1. **Emotional Patterns**: Identify recurring emotions, concerns, and mental states from the diaries
        2. **Strengths & Challenges**: Connect diary content with their personality traits
        3. **Practical Recommendations**: Suggest specific activities, coping strategies, or mindset shifts
        4. **Motivational Guidance**: Offer encouraging words and perspective
        5. **Growth Opportunities**: Areas for personal development based on diary patterns

        Write in a warm, empathetic tone. Use the same language as the diary entries.
        Structure your response with clear sections but maintain a natural, conversational flow.
        Keep your response between 300-400 words.
        """
    def _initialize_model(self, model_name: str = None):
        models_to_try = [
            model_name,
            "models/gemini-1.5-flash-latest",
            "models/gemini-1.5-pro-latest",
        ]

    
        # Remove None values
        models_to_try = [m for m in models_to_try if m]
    
        for model in models_to_try:
            try:
                logger.info(f"Trying to initialize model: {model}")
                return genai.GenerativeModel(model)
            except Exception as e:
                logger.warning(f"Failed to initialize model {model}: {e}")
    
        raise Exception("No compatible Gemini model available")



    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str) -> Dict[str, Any]:
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
            
            response = self.model.generate_content(prompt)
            
            return {
                "advice": response.text,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": len(diaries),
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
            """
            
            response = self.model.generate_content(prompt)
            
            return {
                "advice": response.text,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "status": "success"
            }
        except Exception as e:
            logger.error(f"Error providing general advice: {e}")
            return {
                "advice": self._get_fallback_advice(character_type, sign),
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "status": "success"
            }

    def _get_fallback_advice(self, character_type: str, sign: str) -> str:
        """Provide fallback advice when AI service is unavailable"""
        return f"""
        I'm here to support your emotional well-being journey!

        Based on your {character_type} personality type and {sign} zodiac sign, journaling can be a powerful tool for self-discovery. 

        As a {character_type}, you likely have rich inner thoughts that deserve expression. Writing them down can provide clarity and help you understand your emotional patterns better. Your {sign} nature suggests you may benefit from regular emotional check-ins.

        Start by writing about:
        - Your current feelings and experiences
        - Things you're grateful for today
        - Challenges you're facing and how you're handling them
        - Goals and aspirations that motivate you

        Regular reflection can help you develop greater self-awareness and emotional intelligence. I'm looking forward to reading your thoughts and providing personalized insights!

        Remember, this is your safe space for honest self-expression. There's no right or wrong way to journal - just be yourself.
        """