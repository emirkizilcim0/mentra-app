import google.generativeai as genai
from typing import List, Dict, Any
import logging
from datetime import datetime
import os

logger = logging.getLogger(__name__)

class DiaryPsychologistAdvisor:
    """Psychologist class to provide advice based on user diaries"""
    
    def __init__(self, api_key: str, model: str = "gemini-pro"):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model)
        
        self.advice_prompt = """
        You are a compassionate psychologist and life coach. Based on the user's diary entries and their personality profile, provide personalized advice and motivational guidance.

        USER PROFILE:
        - MBTI Personality: {character_type}
        - Zodiac Sign: {sign}
        - Birth Chart: {birth_map}

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
        """

    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str) -> Dict[str, Any]:
        """Analyze user diaries and provide psychological advice"""
        try:
            combined_diaries = "\n\n---\n\n".join(diaries)
            
            response = self.model.generate_content(
                self.advice_prompt.format(
                    diary_text=combined_diaries,
                    character_type=character_type,
                    sign=sign,
                    birth_map=birth_map
                )
            )
            
            return {
                "advice": response.text,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": len(diaries),
                "status": "success"
            }
            
        except Exception as e:
            logger.error(f"Error analyzing diaries: {str(e)}")
            return {
                "error": str(e),
                "status": "error"
            }