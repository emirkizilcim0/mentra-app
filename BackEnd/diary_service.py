from google import genai
from typing import List, Dict, Any
import logging
from datetime import datetime
import os
import asyncio
from concurrent.futures import ThreadPoolExecutor

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
        You are a compassionate psychologist and life coach. Based on the user's diary entry and their personality profile, provide personalized advice and motivational guidance.

        **IMPORTANT INSTRUCTIONS:**
        1. Analyze THIS diary entry ONLY
        2. Identify the emotional mood from THIS entry
        3. Choose ONE mood ONLY from this list: Happy, Sad, Anxious, Angry, Calm, Confused, Neutral
        4. Your mood classification should be based on the user's expressed emotions in THIS diary
        5. If the user mentions feeling "anxious", "worried", or "nervous", the mood should be ANXIOUS
        6. If the user mentions feeling "angry", "mad", or "furious", the mood should be ANGRY
        7. If the user mentions feeling "sad", "depressed", or "unhappy", the mood should be SAD
        8. If the user mentions feeling "happy", "joyful", or "excited", the mood should be HAPPY
        9. If the user mentions feeling "confused" or "uncertain", the mood should be CONFUSED
        10. If the user mentions feeling "calm", "peaceful", or "relaxed", the mood should be CALM
        11. Only use NEUTRAL if no clear emotion is expressed in THIS diary

        USER PROFILE:
        - MBTI Personality: {character_type}
        - Zodiac Sign: {sign}

        USER'S DIARY ENTRY:
        {diary_text}

        **YOUR RESPONSE MUST START WITH THIS EXACT FORMAT:**
        MOOD: [Your chosen mood from the list]

        **THEN PROVIDE ADVICE WITH THESE SECTIONS:**

        **Emotional Analysis:**
        [Analyze what the user is feeling based on THIS diary]

        **Understanding Your Emotions:**
        [Explain why they might be feeling this way based on THIS content]

        **Coping Strategies:**
        [Suggest specific actions for THIS mood]

        **Positive Perspective:**
        [Offer encouraging words for THIS situation]

        **Long-term Growth:**
        [Suggest how to work with these emotions]

        Write in a warm, empathetic tone. Match your advice to the emotional state expressed in THIS diary.
        Keep response between 200-300 words. Focus only on THIS diary entry.
        """

    def analyze_diaries(self, diaries: List[str], character_type: str, sign: str, birth_map: str = None) -> Dict[str, Any]:
        """Analyze each diary separately and return individual results"""
        try:
            if not diaries:
                return self._provide_general_advice(character_type, sign)

            # Log what we're analyzing
            logger.info(f"=== DEBUG: Analyzing {len(diaries)} diary entries separately ===")
            for i, diary in enumerate(diaries):
                logger.info(f"Diary {i+1} length: {len(diary)} chars, preview: {diary[:50]}...")
            logger.info(f"=== END DEBUG ===")

            results = []
            
            # Analyze each diary separately
            for idx, diary_content in enumerate(diaries, start=1):
                try:
                    # Prepare this diary for analysis
                    cleaned_diary = diary_content.strip()
                    if len(cleaned_diary) > 800:
                        cleaned_diary = cleaned_diary[:800] + "..."
                    
                    logger.info(f"Analyzing diary #{idx} (length: {len(cleaned_diary)} chars)")
                    
                    prompt = self.advice_prompt.format(
                        diary_text=f"DIARY ENTRY:\n{cleaned_diary}",
                        character_type=character_type,
                        sign=sign
                    )

                    # Generate content with system instruction
                    response = self.client.models.generate_content(
                        model=self.model_name,
                        contents=prompt,
                        config={
                            "system_instruction": """You are a compassionate psychologist. 
                            You MUST start your response with 'MOOD: [mood]' where mood is chosen from: Happy, Sad, Anxious, Angry, Calm, Confused, Neutral.
                            
                            **MOOD DETECTION RULES for THIS diary:**
                            1. Look for emotional words in THIS diary only
                            2. Choose mood based only on THIS entry's content
                            3. Ignore previous or future diaries
                            4. The mood should match THIS diary's words""",
                            "temperature": 0.7,
                            "top_p": 0.9
                        }
                    )

                    # Log the raw AI response
                    logger.info(f"Diary #{idx} raw response (first 150 chars): {response.text[:150]}")
                    
                    # Extract mood from the response
                    mood = self._extract_mood_from_response(response.text)
                    logger.info(f"Diary #{idx} extracted mood: {mood}")

                    results.append({
                        "diary_index": idx,
                        "mood": mood,
                        "advice": response.text,
                        "analysis_date": datetime.utcnow().isoformat(),
                        "model_used": self.model_name,
                        "status": "success"
                    })
                    
                    # Small delay to avoid rate limiting
                    import time
                    time.sleep(0.5)

                except Exception as e:
                    logger.error(f"Error analyzing diary #{idx}: {str(e)}")
                    # Provide fallback for this specific diary
                    fallback_advice = self._get_fallback_advice_for_diary(character_type, sign, idx)
                    fallback_mood = self._extract_mood_from_response(fallback_advice)
                    
                    results.append({
                        "diary_index": idx,
                        "mood": fallback_mood,
                        "advice": fallback_advice,
                        "analysis_date": datetime.utcnow().isoformat(),
                        "status": "error",
                        "error": str(e)
                    })

            # Also provide a summary if there are multiple diaries
            summary = None
            if len(results) > 1:
                summary = self._create_summary_analysis(results, character_type, sign)
            
            return {
                "entries_analyzed": len(diaries),
                "results": results,
                "summary": summary,
                "status": "success" if any(r.get("status") == "success" for r in results) else "error"
            }

        except Exception as e:
            logger.error(f"Error analyzing diaries: {str(e)}")
            # Return fallback with single result structure for backward compatibility
            fallback_advice = self._get_fallback_advice(character_type, sign)
            fallback_mood = self._extract_mood_from_response(fallback_advice)
            
            return {
                "mood": fallback_mood,
                "advice": fallback_advice,
                "analysis_date": datetime.utcnow().isoformat(),
                "diaries_analyzed": len(diaries) if diaries else 0,
                "status": "error",
                "error": str(e)
            }

    def _create_summary_analysis(self, results: List[Dict[str, Any]], character_type: str, sign: str) -> Dict[str, Any]:
        """Create a summary analysis for multiple diaries"""
        try:
            # Calculate most frequent mood
            moods = [r.get("mood", "Neutral") for r in results]
            from collections import Counter
            mood_counter = Counter(moods)
            most_common_mood = mood_counter.most_common(1)[0][0] if moods else "Neutral"
            
            # Create summary prompt
            summary_prompt = f"""
            Create a psychological summary for a user with these diary analyses:
            
            USER PROFILE:
            - Personality: {character_type}
            - Zodiac: {sign}
            
            DIARY ANALYSES SUMMARY:
            Total diaries: {len(results)}
            Moods detected: {', '.join(moods)}
            Most frequent mood: {most_common_mood}
            
            Provide an overall insight about:
            1. Emotional patterns across these diaries
            2. Growth opportunities
            3. General well-being assessment
            4. Recommendations for continued journaling
            
            Keep it concise and encouraging (150-200 words).
            Start with: SUMMARY:
            """
            
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=summary_prompt,
                config={
                    "temperature": 0.5,
                    "top_p": 0.8
                }
            )
            
            return {
                "mood": most_common_mood,
                "summary": response.text,
                "mood_distribution": dict(mood_counter),
                "total_diaries": len(results)
            }
            
        except Exception as e:
            logger.error(f"Error creating summary: {e}")
            return None

    def _extract_mood_from_response(self, response_text: str) -> str:
        """Extract mood label from the AI response"""
        # Mood labels to look for
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
        
        # ⚠️ FIXED: Default to "Neutral" instead of "Calm"
        logger.warning("No mood found in response, defaulting to 'Neutral'")
        return "Neutral"
    
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
        
        # ⚠️ FIXED: Better formatting
        return ("\n\n" + "-" * 50 + "\n\n").join(prepared_entries)

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
        return f"""MOOD: Neutral

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

    def _get_fallback_advice_for_diary(self, character_type: str, sign: str, diary_index: int) -> str:
        """Provide fallback advice for a specific diary"""
        return f"""MOOD: Neutral

**Diary #{diary_index} Analysis:**
This diary entry contains personal reflections that deserve attention.

**Understanding Your Emotions:**
As a {character_type}, your unique perspective shapes how you process experiences. Your {sign} traits may influence how you express emotions.

**Coping Strategies:**
Consider reflecting on:
- The specific events mentioned in this diary
- How they made you feel in the moment
- What insights you gained from writing about them

**Positive Perspective:**
Every diary entry is a step toward greater self-understanding.

**Long-term Growth:**
Regular writing helps track emotional patterns and personal growth over time."""