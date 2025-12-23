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

        **IMPORTANT INSTRUCTIONS:**
        1. Read ALL the diary entries provided
        2. Identify the OVERALL emotional mood from ALL entries
        3. Choose ONE mood ONLY from this list: Happy, Sad, Anxious, Angry, Calm, Confused, Neutral
        4. Your mood classification should be based on the user's expressed emotions in their diaries
        5. If the user mentions feeling "anxious", "worried", or "nervous", the mood should be ANXIOUS
        6. If the user mentions feeling "angry", "mad", or "furious", the mood should be ANGRY
        7. If the user mentions feeling "sad", "depressed", or "unhappy", the mood should be SAD
        8. If the user mentions feeling "happy", "joyful", or "excited", the mood should be HAPPY
        9. If the user mentions feeling "confused" or "uncertain", the mood should be CONFUSED
        10. If the user mentions feeling "calm", "peaceful", or "relaxed", the mood should be CALM
        11. Only use NEUTRAL if no clear emotion is expressed

        USER PROFILE:
        - MBTI Personality: {character_type}
        - Zodiac Sign: {sign}

        USER'S DIARY ENTRIES:
        {diary_text}

        **YOUR RESPONSE MUST START WITH THIS EXACT FORMAT:**
        MOOD: [Your chosen mood from the list]

        **THEN PROVIDE ADVICE WITH THESE SECTIONS:**

        **Emotional Analysis:**
        [Analyze what the user is feeling based on their diary]

        **Understanding Your Emotions:**
        [Explain why they might be feeling this way]

        **Coping Strategies:**
        [Suggest specific actions for their current mood]

        **Positive Perspective:**
        [Offer encouraging words]

        **Long-term Growth:**
        [Suggest how to work with these emotions]

        Write in a warm, empathetic tone. If the user is anxious, acknowledge their anxiety and provide anxiety management strategies.
        If the user is sad, provide comfort and support.
        If the user is angry, acknowledge their anger and provide anger management strategies.
        Match your advice to their actual emotional state.
        Keep response between 300-400 words.
        """

    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str = None) -> Dict[str, Any]:
        """
        Analyze each diary entry separately and return individual results
        """

        # If no diaries exist, return general advice
        if not diaries:
            return self._provide_general_advice(character_type, sign)

        results = []

        for idx, diary in enumerate(diaries, start=1):
            try:
                # Clean & limit diary text
                diary_text = diary.strip()
                if len(diary_text) > 800:
                    diary_text = diary_text[:800] + "..."

                # Build prompt for THIS diary only
                prompt = self.advice_prompt.format(
                    diary_text=f"DIARY ENTRY:\n{diary_text}",
                    character_type=character_type,
                    sign=sign
                )

                logger.info(f"Analyzing diary #{idx}")

                # Call Gemini
                response = self.client.models.generate_content(
                    model=self.model_name,
                    contents=prompt,
                    config={
                        "system_instruction": (
                            "You are a compassionate psychologist.\n"
                            "You MUST start your response with 'MOOD: [mood]'\n"
                            "Mood must be one of: Happy, Sad, Anxious, Angry, Calm, Confused, Neutral."
                        ),
                        "temperature": 0.7,
                        "top_p": 0.9
                    }
                )

                # Extract mood
                mood = self._extract_mood_from_response(response.text)

                # Store result for this diary
                results.append({
                    "diary_index": idx,
                    "mood": mood,
                    "advice": response.text,
                    "analysis_date": datetime.utcnow().isoformat(),
                    "model_used": self.model_name,
                    "status": "success"
                })

            except Exception as e:
                logger.error(f"Error analyzing diary #{idx}: {e}")

                fallback_advice = self._get_fallback_advice(character_type, sign)
                fallback_mood = self._extract_mood_from_response(fallback_advice)

                results.append({
                    "diary_index": idx,
                    "mood": fallback_mood,
                    "advice": fallback_advice,
                    "analysis_date": datetime.utcnow().isoformat(),
                    "status": "error",
                    "error": str(e)
                })

        return {
            "entries_analyzed": len(diaries),
            "results": results
        }

    def _extract_mood_from_response(self, response_text: str) -> str:
        """Extract mood label from the AI response"""
        # Mood labels to look for - ADD "Neutral" to the list!
        mood_labels = ["Happy", "Sad", "Anxious", "Angry", "Calm", "Confused", "Neutral"]
        
        logger.info(f"Extracting mood from response (first 150 chars): {response_text[:150]}")
        
        # First, check for structured "MOOD: X" format at the beginning
        lines = response_text.strip().split('\n')
        
        # Look in the first 3 lines for "MOOD:" pattern
        for line in lines[:3]:
            line = line.strip()
            if line.startswith('MOOD:'):
                mood_part = line.replace('MOOD:', '').strip()
                logger.info(f"Found MOOD: pattern, mood part: '{mood_part}'")
                
                # Try exact match
                for mood in mood_labels:
                    if mood.lower() == mood_part.lower():
                        logger.info(f"Exact match found: {mood}")
                        return mood
                
                # Try partial match
                for mood in mood_labels:
                    if mood.lower() in mood_part.lower():
                        logger.info(f"Partial match found: {mood}")
                        return mood
        
        # If no structured format, search for mood words in the text
        response_lower = response_text.lower()
        for mood in mood_labels:
            if mood.lower() in response_lower:
                # Check if it's in the beginning (more likely to be the classification)
                if mood.lower() in response_text[:300].lower():
                    logger.info(f"Found mood '{mood}' in response")
                    return mood
        
        # If still not found, default to "Calm" for backward compatibility
        logger.warning("No mood found in response, defaulting to 'Calm'")
        return "Calm"
    
    def _prepare_diary_text(self, diaries: List[str]) -> str:
        """Prepare diary text for analysis, limiting total length"""
        if not diaries:
            return "No diary entries provided."
        
        # If only one diary, just return it
        if len(diaries) == 1:
            diary = diaries[0].strip()
            if len(diary) > 800:
                diary = diary[:800] + "..."
            return f"DIARY ENTRY:\n{diary}"
        
        # For multiple diaries, format them nicely
        prepared_entries = []
        for i, diary in enumerate(diaries, 1):
            # Clean and truncate if too long
            clean_diary = diary.strip()
            if len(clean_diary) > 400:
                clean_diary = clean_diary[:400] + "..."
            prepared_entries.append(f"Entry {i}:\n{clean_diary}")
        
        return "\n\n" + "\n" + "-"*50 + "\n\n".join(prepared_entries)

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
            
            Start your response with: MOOD: Calm
            """
            
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            
            mood = self._extract_mood_from_response(response.text)
            
            return {
                "mood": mood,
                "advice": response.text,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "model_used": self.model_name,
                "status": "success"
            }
        except Exception as e:
            logger.error(f"Error providing general advice: {e}")
            fallback_advice = self._get_fallback_advice(character_type, sign)
            fallback_mood = self._extract_mood_from_response(fallback_advice)
            
            return {
                "mood": fallback_mood,
                "advice": fallback_advice,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": 0,
                "status": "success"
            }

    def _get_fallback_advice(self, character_type: str, sign: str) -> str:
        """Provide fallback advice when AI service is unavailable"""
        return f"""MOOD: Calm

**Emotional Analysis:**
Starting a journaling practice is the first step toward greater emotional awareness.

**Understanding Your Emotions:**
As a {character_type}, you likely have rich inner thoughts that deserve expression. Your {sign} nature suggests you may benefit from regular emotional check-ins.

**Coping Strategies:**
Start by writing about:
- Your current feelings and experiences
- Things you're grateful for today
- Challenges you're facing and how you're handling them

**Positive Perspective:**
I'm here to support your emotional well-being journey! Journaling can be a powerful tool for self-discovery.

**Long-term Growth:**
Regular reflection can help you develop greater self-awareness and emotional intelligence."""