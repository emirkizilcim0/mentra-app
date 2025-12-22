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
        1. FIRST, analyze the language of the diary entries. Respond in the SAME language as the diary.
        2. THEN, analyze the user's diary entries to determine their overall emotional mood
        3. Choose ONE mood ONLY from this list: Happy, Sad, Anxious, Angry, Calm, Confused
        4. Your mood classification should be based SOLELY on the user's expressed emotions in their diary
        5. Provide psychological advice that matches their mood and is in the same language

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

        Write in a warm, empathetic tone. If the user is angry, acknowledge their anger and provide anger management strategies.
        If the user is sad, provide comfort and support.
        Match your advice to their actual emotional state.
        Keep response between 300-400 words.
        """

    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str = None) -> Dict[str, Any]:
            """Analyze user diaries and provide psychological advice"""
            try:
                if not diaries:
                    return self._provide_general_advice(character_type, sign)

                # Prepare diary text (limit length to avoid token limits)
                combined_diaries = self._prepare_diary_text(diaries)
                
                # FIRST, analyze the mood directly from the diary content
                mood = self._analyze_mood_from_diaries(diaries)

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
                        "system_instruction": "You are a compassionate psychologist. You MUST start your response with 'MOOD: [mood]' where mood is chosen from: Happy, Sad, Anxious, Angry, Calm, Confused. The mood should reflect the user's diary content, not general advice.",
                        "temperature": 0.7,
                        "top_p": 0.9
                    }
                )

                # Extract mood from the AI's response
                ai_mood = self._extract_mood_from_response(response.text)
                
                # Use the AI's mood if it makes sense, otherwise use our diary analysis
                final_mood = self._validate_mood(ai_mood, mood, response.text)
                
                advice_text = response.text

                return {
                    "mood": final_mood,
                    "advice": advice_text,
                    "analysis_date": datetime.utcnow().isoformat(),
                    "diaries_analyzed": len(diaries),
                    "model_used": self.model_name,
                    "status": "success"
                }

            except Exception as e:
                logger.error(f"Error analyzing diaries: {str(e)}")
                return {
                    "mood": "Calm",
                    "advice": self._get_fallback_advice(character_type, sign),
                    "analysis_date": datetime.utcnow().isoformat(),
                    "diaries_analyzed": len(diaries) if diaries else 0,
                    "status": "error",
                    "error": str(e)
                }

    def _analyze_mood_from_diaries(self, diaries: List[str]) -> str:
        """Analyze mood directly from diary content"""
        if not diaries:
            return "Calm"
        
        # Use the most recent diary for mood analysis
        latest_diary = diaries[-1].lower()
        
        # Define emotion keywords with weights
        emotion_keywords = {
            "angry": ["angry", "mad", "furious", "rage", "pissed", "irritated", "annoyed", "hate", "frustrated"],
            "sad": ["sad", "depressed", "unhappy", "miserable", "cry", "tears", "lonely", "heartbroken"],
            "anxious": ["anxious", "worried", "nervous", "stressed", "panic", "afraid", "scared", "fear"],
            "happy": ["happy", "joy", "excited", "glad", "pleased", "content", "delighted", "great"],
            "confused": ["confused", "uncertain", "unsure", "doubt", "question", "perplexed", "bewildered"],
            "calm": ["calm", "peaceful", "relaxed", "serene", "tranquil", "chill", "content"]
        }
        
        # Count occurrences of each emotion
        mood_scores = {mood: 0 for mood in emotion_keywords}
        
        for mood, keywords in emotion_keywords.items():
            for keyword in keywords:
                if keyword in latest_diary:
                    mood_scores[mood] += 1
        
        # Also check for stronger emotional words
        strong_indicators = {
            "angry": ["furious", "rage", "hate", "pissed"],
            "sad": ["depressed", "heartbroken", "miserable"],
            "anxious": ["panic", "terrified", "fearful"]
        }
        
        for mood, strong_words in strong_indicators.items():
            for word in strong_words:
                if word in latest_diary:
                    mood_scores[mood] += 3  # Extra weight for strong emotions
        
        # Get the mood with highest score
        if max(mood_scores.values()) > 0:
            return max(mood_scores, key=mood_scores.get)
        
        return "Calm"

    def _extract_mood_from_response(self, response_text: str) -> str:
        """Extract mood label from the AI response"""
        # Mood labels to look for
        mood_labels = ["Happy", "Sad", "Anxious", "Angry", "Calm", "Confused"]
        
        # Check for structured mood format at the beginning
        lines = response_text.strip().split('\n')
        if lines and lines[0].startswith('MOOD:'):
            mood_part = lines[0].replace('MOOD:', '').strip()
            for mood in mood_labels:
                if mood.lower() == mood_part.lower():
                    return mood
        
        # Check for mood in the first few lines
        for line in lines[:3]:
            line_lower = line.lower()
            for mood in mood_labels:
                if mood.lower() in line_lower and f"mood: {mood.lower()}" in line_lower:
                    return mood
        
        # Default to "Calm" if no clear mood found
        return "Calm"
    
    def _validate_mood(self, ai_mood: str, diary_mood: str, response_text: str) -> str:
        """Validate that the AI's mood matches the diary content"""
        # If AI says calm but diary analysis says angry, trust the diary
        if diary_mood == "Angry" and ai_mood == "Calm":
            logger.warning(f"AI returned Calm but diary analysis says Angry. Using Angry.")
            return "Angry"
        
        # Similarly for other strong emotions
        strong_emotions = ["Angry", "Sad", "Anxious"]
        if diary_mood in strong_emotions and ai_mood == "Calm":
            logger.warning(f"AI returned Calm but diary analysis says {diary_mood}. Using {diary_mood}.")
            return diary_mood
        
        # Otherwise, use AI's mood
        return ai_mood
    
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
            
            This person hasn't written any diaries yet. 
            Start your response with: MOOD: Calm
            
            Then provide:
            - Encouragement to start journaling and its benefits
            - General insights about their {character_type} personality type
            - Motivational guidance for self-reflection
            - Keep it positive, supportive, and around 150-200 words
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
            return {
                "mood": "Calm",
                "advice": self._get_fallback_advice(character_type, sign),
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