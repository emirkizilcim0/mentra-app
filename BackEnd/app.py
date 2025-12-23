from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import asyncpg
import os
import uuid
from datetime import datetime
import logging
from diary_service import DiaryPsychologistAdvisor

psychologist = None

def get_psychologist():
    global psychologist
    if psychologist is None:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY not set")
        psychologist = DiaryPsychologistAdvisor(api_key=api_key)
    return psychologist

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection pool
connection_pool = None

async def create_db_pool():
    global connection_pool
    DATABASE_URL = os.getenv("DATABASE_URL")
    if not DATABASE_URL:
        logger.warning("DATABASE_URL not set, running without database")
        return
    
    connection_pool = await asyncpg.create_pool(
        DATABASE_URL,
        min_size=5,
        max_size=20,
        max_inactive_connection_lifetime=300,
    )
    
    async with connection_pool.acquire() as conn:
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS user_diaries (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                mood VARCHAR(100),
                mood_confidence VARCHAR(20),
                advice_preview TEXT,
                tags JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS user_analyses (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                analysis_type VARCHAR(100) NOT NULL,
                advice_text TEXT NOT NULL,
                diaries_analyzed INTEGER,
                analysis_data JSONB,
                has_advice BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS analyses (
                id SERIAL PRIMARY KEY,
                analysis_key VARCHAR(255) NOT NULL UNIQUE,
                diary_id INTEGER NOT NULL,
                user_id VARCHAR(255) NOT NULL,
                advice TEXT NOT NULL,
                mood VARCHAR(100),
                mood_source VARCHAR(50),
                character_type VARCHAR(100),
                sign VARCHAR(100),
                has_advice BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        # Create indexes
        await conn.execute('''
            CREATE INDEX IF NOT EXISTS idx_user_diaries_user_id ON user_diaries(user_id);
            CREATE INDEX IF NOT EXISTS idx_analyses_diary_id ON analyses(diary_id);
            CREATE INDEX IF NOT EXISTS idx_analyses_user_id ON analyses(user_id);
            CREATE INDEX IF NOT EXISTS idx_user_diaries_mood ON user_diaries(mood);
        ''')
        
        logger.info("Database setup completed")

@app.on_event("startup")
async def startup_event():
    try:
        await create_db_pool()
    except Exception as e:
        logger.error(f"Failed to create database pool: {e}")
        connection_pool = None

@app.on_event("shutdown")
async def shutdown_event():
    if connection_pool:
        await connection_pool.close()

# ============== MODELS ==============
class DiaryEntry(BaseModel):
    content: str
    mood: Optional[str] = None
    tags: Optional[List[str]] = None

class DiaryAnalysisRequest(BaseModel):
    user_id: str
    character_type: str
    sign: str
    birth_map: str
    diary_count: Optional[int] = 10
    diaries: Optional[List[str]] = None
    diary_ids: Optional[List[int]] = None

class IndividualDiaryAnalysis(BaseModel):
    diary_index: int
    source_diary_id: int
    mood: str
    mood_source: str
    advice: str
    analysis_date: str
    status: str
    analysis_key: str

class MultipleDiaryAnalysisResponse(BaseModel):
    entries_analyzed: int
    results: List[IndividualDiaryAnalysis]

# ============== HELPER FUNCTIONS ==============

def detect_mood_from_content(content: str, ai_mood: str = None) -> tuple[str, str]:
    """
    Detect mood from content with rule-based overrides.
    Returns: (final_mood, mood_source)
    """
    content_lower = content.lower()
    
    # 🎭 Rule-based mood detection (takes priority)
    angry_keywords = ["angry", "mad", "furious", "rage", "irritated", "annoyed", 
                     "upset", "hate", "frustrated", "cant stand", "pissed"]
    sad_keywords = ["sad", "depressed", "unhappy", "down", "miserable", "hopeless"]
    anxious_keywords = ["anxious", "anxiety", "worried", "nervous", "stressed", "tense"]
    happy_keywords = ["happy", "joy", "excited", "great", "wonderful", "positive"]
    calm_keywords = ["calm", "peaceful", "relaxed", "serene", "tranquil"]
    
    # Check rules in priority order
    for keyword in angry_keywords:
        if keyword in content_lower:
            return "Angry", "content_override"
    
    for keyword in sad_keywords:
        if keyword in content_lower:
            return "Sad", "content_override"
    
    for keyword in anxious_keywords:
        if keyword in content_lower:
            return "Anxious", "content_override"
    
    for keyword in happy_keywords:
        if keyword in content_lower:
            return "Happy", "content_override"
    
    for keyword in calm_keywords:
        if keyword in content_lower:
            return "Calm", "content_override"
    
    # If no rule matches, use AI mood with fallback
    if ai_mood and ai_mood != "Neutral":
        return ai_mood, "ai_detected"
    
    return "Neutral", "default"

def create_analysis_key(user_id: str, diary_id: int = 0) -> str:
    """Create a guaranteed unique analysis key"""
    unique_id = uuid.uuid4().hex
    if diary_id > 0:
        return f"diary_{diary_id}_{unique_id}"
    else:
        return f"user_{user_id}_{unique_id}"

# ============== ENDPOINTS ==============

@app.get("/")
async def home():
    return {
        "message": "Mentra Backend is running!", 
        "timestamp": datetime.utcnow().isoformat(),
        "status": "healthy"
    }

@app.post("/diaries/save")
async def save_diary(entry: DiaryEntry, user_id: str):
    """Save a new diary entry for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        diary_id = await connection_pool.fetchval('''
            INSERT INTO user_diaries (user_id, content, mood, tags)
            VALUES ($1, $2, $3, $4)
            RETURNING id
        ''', user_id, entry.content, entry.mood, entry.tags if entry.tags else None)
        
        return {
            "message": "Diary saved successfully",
            "diary_id": diary_id,
            "status": "success"
        }
        
    except Exception as e:
        logger.error(f"Error saving diary: {e}")
        raise HTTPException(status_code=500, detail="Failed to save diary")

@app.get("/diaries/{user_id}")
async def get_user_diaries(user_id: str, limit: int = 20):
    """Get recent diary entries for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        diaries = await connection_pool.fetch('''
            SELECT id, content, mood, mood_confidence, advice_preview, tags, created_at
            FROM user_diaries 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT $2
        ''', user_id, limit)
        
        return {
            "diaries": [
                {
                    "id": diary["id"],
                    "content": diary["content"],
                    "mood": diary["mood"],
                    "mood_confidence": diary["mood_confidence"],
                    "advice_preview": diary["advice_preview"],
                    "tags": diary["tags"],
                    "date": diary["created_at"].isoformat()
                }
                for diary in diaries
            ],
            "total": len(diaries)
        }
        
    except Exception as e:
        logger.error(f"Error fetching diaries: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch diaries")

@app.post("/analyze/diaries")
async def analyze_diaries(request: DiaryAnalysisRequest):
    """Analyze user diaries and provide psychological advice"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        diary_contents = []
        diary_records = []
        source = "unknown"
        
        # Determine source of diaries
        if request.diaries and len(request.diaries) > 0:
            diary_contents = request.diaries
            source = "request_content"
            for i, content in enumerate(diary_contents):
                diary_records.append({
                    "id": f"request_{i}",
                    "content": content,
                    "mood": None,
                    "tags": None,
                    "created_at": datetime.utcnow()
                })
                
        elif request.diary_ids and len(request.diary_ids) > 0:
            diary_ids_int = [int(did) for did in request.diary_ids if str(did).isdigit()]
            if not diary_ids_int:
                raise HTTPException(
                    status_code=400,
                    detail={
                        "error": "INVALID_DIARY_IDS",
                        "message": "Invalid diary IDs provided.",
                        "provided_ids": request.diary_ids
                    }
                )
            
            diary_records = await connection_pool.fetch('''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 AND id = ANY($2)
                ORDER BY created_at DESC
            ''', request.user_id, diary_ids_int)
            
            diary_contents = [d["content"] for d in diary_records]
            source = "specific_ids"
            
        else:
            diary_records = await connection_pool.fetch('''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 
                ORDER BY created_at DESC 
                LIMIT $2
            ''', request.user_id, request.diary_count)
            
            diary_contents = [d["content"] for d in diary_records]
            source = "recent_db"
        
        # Validate we have diaries to analyze
        if not diary_contents:
            raise HTTPException(
                status_code=400,
                detail={
                    "error": "NO_DIARIES_FOUND",
                    "message": "No diaries found to analyze.",
                    "user_id": request.user_id,
                    "source": source
                }
            )
        
        logger.info(f"Analyzing {len(diary_contents)} diaries from source: {source}")
        
        # Get analysis from AI
        advisor = get_psychologist()
        analysis_result = advisor.analyze_diaries(
            diaries=diary_contents,
            character_type=request.character_type,
            sign=request.sign,
            birth_map=request.birth_map
        )

        # Process results
        if "results" in analysis_result:
            results = analysis_result.get("results", [])
            
            # 🔥 CRITICAL FIX #1: Ensure result count matches
            if len(results) != len(diary_records):
                logger.error(f"Result mismatch: {len(results)} results for {len(diary_records)} diaries")
                # Pad or truncate to match
                if len(results) > len(diary_records):
                    results = results[:len(diary_records)]
                else:
                    # Extend with empty results
                    while len(results) < len(diary_records):
                        results.append({"mood": "Neutral", "advice": "", "analysis_date": datetime.utcnow().isoformat()})
            
            analysis_responses = []
            
            for idx in range(len(diary_records)):
                diary_record = diary_records[idx]
                result = results[idx]
                
                # Generate analysis key
                analysis_key = create_analysis_key(
                    request.user_id, 
                    diary_record["id"] if source != "request_content" else 0
                )
                
                # Get AI mood from result
                ai_mood = result.get("mood", "Neutral")
                
                # 🔥 CRITICAL FIX #2: Apply rule-based mood override
                final_mood, mood_source = detect_mood_from_content(
                    diary_record["content"], 
                    ai_mood
                )
                
                # Log mood correction if needed
                if ai_mood != final_mood:
                    logger.info(f"⚠️ Mood corrected: '{ai_mood}' → '{final_mood}' for diary {diary_record.get('id', 'unknown')}")
                    logger.info(f"  Content snippet: '{diary_record['content'][:50]}...'")
                    logger.info(f"  Source: {mood_source}")
                
                advice_text = result["advice"]
                
                # Save to PostgreSQL ONLY for real diaries
                if connection_pool and source != "request_content":
                    diary_id = diary_record["id"]
                    
                    # 1. Save to analyses table
                    await connection_pool.execute('''
                        INSERT INTO analyses (analysis_key, diary_id, user_id, advice, mood, mood_source, character_type, sign, has_advice)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                    ''', analysis_key, diary_id, request.user_id, advice_text, 
                         final_mood, mood_source, request.character_type, 
                         request.sign, True)
                    
                    # 2. Update the original diary with mood and advice preview
                    advice_preview = advice_text[:200] + "..." if len(advice_text) > 200 else advice_text
                    mood_confidence = "high" if mood_source == "content_override" else "medium"
                    
                    await connection_pool.execute('''
                        UPDATE user_diaries 
                        SET mood = $1, 
                            mood_confidence = $2,
                            advice_preview = $3,
                            updated_at = CURRENT_TIMESTAMP 
                        WHERE id = $4 AND user_id = $5
                    ''', final_mood, mood_confidence, advice_preview, diary_id, request.user_id)
                    
                    logger.info(f"✅ Updated diary {diary_id}: mood='{final_mood}' source='{mood_source}'")
                
                analysis_responses.append({
                    "diary_index": idx + 1,
                    "source_diary_id": diary_record["id"] if source != "request_content" else 0,
                    "mood": final_mood,
                    "mood_source": mood_source,
                    "advice": advice_text,
                    "analysis_date": result.get("analysis_date", datetime.utcnow().isoformat()),
                    "status": result.get("status", "success"),
                    "analysis_key": analysis_key,
                    "source": source,
                    "advice_saved": source != "request_content"
                })
            
            # Save summary to user_analyses
            if results and connection_pool and source != "request_content":
                summary_result = results[0]
                
                analysis_data = {
                    "character_type": request.character_type,
                    "sign": request.sign,
                    "birth_map": request.birth_map,
                    "moods": [resp["mood"] for resp in analysis_responses],
                    "mood_sources": [resp["mood_source"] for resp in analysis_responses],
                    "has_advice": True,
                    "individual_analyses": len(results),
                    "source_diary_ids": [d["id"] for d in diary_records],
                    "analysis_keys": [resp["analysis_key"] for resp in analysis_responses],
                    "source": source
                }
                
                await connection_pool.fetchval('''
                    INSERT INTO user_analyses (user_id, analysis_type, advice_text, diaries_analyzed, analysis_data, has_advice)
                    VALUES ($1, $2, $3, $4, $5, $6)
                    RETURNING id
                ''', request.user_id, f"diary_analysis_{source}", summary_result["advice"], 
                     len(diary_contents), analysis_data, True)
            
            return {
                "entries_analyzed": len(results),
                "results": analysis_responses,
                "status": "success",
                "diaries_analyzed": len(diary_contents),
                "source": source,
                "advice_saved": source != "request_content",
                "message": f"Successfully analyzed {len(diary_contents)} diaries",
                "mood_corrections": sum(1 for r in analysis_responses if r["mood_source"] == "content_override")
            }
        
        # Fallback for single analysis structure
        else:
            ai_mood = analysis_result.get("mood", "Neutral")
            advice_text = analysis_result["advice"]
            
            # Apply rule-based mood detection to each diary
            analysis_responses = []
            for idx, diary_record in enumerate(diary_records):
                final_mood, mood_source = detect_mood_from_content(
                    diary_record["content"], 
                    ai_mood
                )
                
                # Create analysis key
                analysis_key = create_analysis_key(
                    request.user_id, 
                    diary_record["id"] if source != "request_content" else 0
                )
                
                analysis_responses.append({
                    "diary_index": idx + 1,
                    "source_diary_id": diary_record["id"] if source != "request_content" else 0,
                    "mood": final_mood,
                    "mood_source": mood_source,
                    "advice": advice_text,
                    "analysis_date": analysis_result.get("analysis_date", datetime.utcnow().isoformat()),
                    "status": analysis_result.get("status", "success"),
                    "analysis_key": analysis_key,
                    "source": source,
                    "advice_saved": source != "request_content"
                })
            
            # Save to PostgreSQL if from database
            if connection_pool and source != "request_content":
                for resp in analysis_responses:
                    if resp["source_diary_id"] > 0:
                        # Save individual analysis
                        await connection_pool.execute('''
                            INSERT INTO analyses (analysis_key, diary_id, user_id, advice, mood, mood_source, character_type, sign, has_advice)
                            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                        ''', resp["analysis_key"], resp["source_diary_id"], request.user_id, 
                             advice_text, resp["mood"], resp["mood_source"], 
                             request.character_type, request.sign, True)
                        
                        # Update diary
                        advice_preview = advice_text[:200] + "..." if len(advice_text) > 200 else advice_text
                        mood_confidence = "high" if resp["mood_source"] == "content_override" else "medium"
                        
                        await connection_pool.execute('''
                            UPDATE user_diaries 
                            SET mood = $1, 
                                mood_confidence = $2,
                                advice_preview = $3,
                                updated_at = CURRENT_TIMESTAMP 
                            WHERE id = $4 AND user_id = $5
                        ''', resp["mood"], mood_confidence, advice_preview, 
                             resp["source_diary_id"], request.user_id)
            
            return {
                "advice": advice_text,
                "mood": analysis_responses[0]["mood"] if analysis_responses else ai_mood,
                "status": analysis_result.get("status", "success"),
                "analysis_date": analysis_result.get("analysis_date", datetime.utcnow().isoformat()),
                "diaries_analyzed": analysis_result.get("diaries_analyzed", len(diary_contents)),
                "has_advice": True,
                "source": source,
                "advice_saved": source != "request_content",
                "individual_results": analysis_responses if len(analysis_responses) > 1 else None
            }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing diaries: {e}", exc_info=True)
        
        advisor = get_psychologist()
        fallback_advice = advisor._get_fallback_advice(
            request.character_type, request.sign
        )
        fallback_mood = advisor._extract_mood_from_response(fallback_advice)
        
        return {
            "advice": fallback_advice,
            "mood": fallback_mood,
            "status": "success",
            "analysis_date": datetime.utcnow().isoformat(),
            "diaries_analyzed": 0,
            "has_advice": True,
            "warning": "Used fallback analysis"
        }

# ============== OTHER ENDPOINTS ==============

@app.get("/diaries/{diary_id}/advice")
async def get_diary_advice(diary_id: int, user_id: str):
    """Get the latest advice for a specific diary"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        analysis = await connection_pool.fetchrow('''
            SELECT id, analysis_key, advice, mood, mood_source, character_type, sign, created_at
            FROM analyses 
            WHERE diary_id = $1 AND user_id = $2
            ORDER BY created_at DESC 
            LIMIT 1
        ''', diary_id, user_id)
        
        if analysis:
            return {
                "diary_id": diary_id,
                "advice": analysis["advice"],
                "mood": analysis["mood"],
                "mood_source": analysis["mood_source"],
                "character_type": analysis["character_type"],
                "sign": analysis["sign"],
                "analysis_date": analysis["created_at"].isoformat(),
                "analysis_key": analysis["analysis_key"],
                "has_advice": True
            }
        
        # Check diary for preview
        diary = await connection_pool.fetchrow('''
            SELECT id, content, mood, mood_confidence, advice_preview, created_at
            FROM user_diaries 
            WHERE id = $1 AND user_id = $2
        ''', diary_id, user_id)
        
        if diary and diary["advice_preview"]:
            return {
                "diary_id": diary_id,
                "advice": diary["advice_preview"],
                "mood": diary["mood"],
                "mood_confidence": diary["mood_confidence"],
                "analysis_date": diary["created_at"].isoformat(),
                "has_advice": True,
                "note": "Advice preview"
            }
        
        return {
            "diary_id": diary_id,
            "advice": "",
            "mood": None,
            "has_advice": False,
            "message": "No analysis found"
        }
        
    except Exception as e:
        logger.error(f"Error fetching diary advice: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch advice")

@app.get("/analysis/history/{user_id}")
async def get_analysis_history(user_id: str, limit: int = 10):
    """Get previous analysis results for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        analyses = await connection_pool.fetch('''
            SELECT id, analysis_type, advice_text, diaries_analyzed, created_at, analysis_data, has_advice
            FROM user_analyses 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT $2
        ''', user_id, limit)
        
        result_analyses = []
        for analysis in analyses:
            analysis_data = analysis["analysis_data"] or {}
            
            result_analyses.append({
                "id": analysis["id"],
                "type": analysis["analysis_type"],
                "advice": analysis["advice_text"],
                "diaries_analyzed": analysis["diaries_analyzed"],
                "date": analysis["created_at"].isoformat(),
                "analysis_date": analysis["created_at"].isoformat(),
                "mood": analysis_data.get("moods", [None])[0] if analysis_data.get("moods") else None,
                "character_type": analysis_data.get("character_type"),
                "sign": analysis_data.get("sign"),
                "has_advice": analysis["has_advice"] if analysis["has_advice"] is not None else True
            })
        
        return {
            "analyses": result_analyses,
            "total": len(result_analyses)
        }
        
    except Exception as e:
        logger.error(f"Error fetching analysis history: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analysis history")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        if connection_pool:
            async with connection_pool.acquire() as conn:
                await conn.fetchval('SELECT 1')
                diary_count = await conn.fetchval('SELECT COUNT(*) FROM user_diaries')
                analysis_count = await conn.fetchval('SELECT COUNT(*) FROM analyses')
                
                # Check mood distribution
                mood_stats = await conn.fetch('''
                    SELECT mood, COUNT(*) as count 
                    FROM user_diaries 
                    WHERE mood IS NOT NULL 
                    GROUP BY mood 
                    ORDER BY count DESC
                ''')
                
            return {
                "status": "healthy",
                "timestamp": datetime.utcnow().isoformat(),
                "database": "connected",
                "table_counts": {
                    "user_diaries": diary_count,
                    "analyses": analysis_count
                },
                "mood_stats": {row["mood"]: row["count"] for row in mood_stats},
                "message": "Mentra Backend is running"
            }
        else:
            return {
                "status": "healthy",
                "timestamp": datetime.utcnow().isoformat(),
                "database": "disconnected",
                "message": "Mentra Backend is running (no database)"
            }
    except Exception as e:
        return {
            "status": "unhealthy",
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e),
            "message": "Service is experiencing issues"
        }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=port,
        workers=2  # Reduced for better Gemini API usage
    )