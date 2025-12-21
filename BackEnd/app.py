from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import asyncpg
import os
from datetime import datetime
import logging
import json  
from diary_service import DiaryPsychologistAdvisor

psychologist = None

def get_psychologist():
    global psychologist

    if psychologist is None:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY not set")

        psychologist = DiaryPsychologistAdvisor(
            api_key=api_key
        )

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
    
    # Create tables for diaries and analyses
    async with connection_pool.acquire() as conn:
        # Create user_diaries table
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS user_diaries (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                mood VARCHAR(100),
                tags JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        # Create user_analyses table
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS user_analyses (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                analysis_type VARCHAR(100) NOT NULL,
                advice_text TEXT NOT NULL,
                diaries_analyzed INTEGER,
                analysis_data JSONB,
                has_advice BOOLEAN DEFAULT TRUE,  -- NEW COLUMN
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        # Create the separate analyses table for Flutter app
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS analyses (
                id SERIAL PRIMARY KEY,
                diary_id VARCHAR(255) NOT NULL UNIQUE,
                advice TEXT NOT NULL,
                analysis TEXT NOT NULL,
                mood VARCHAR(100) DEFAULT 'Calm',
                character_type VARCHAR(100),
                sign VARCHAR(100),
                has_advice BOOLEAN DEFAULT TRUE,  -- NEW COLUMN
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        
        # Create indexes
        await conn.execute('''
            CREATE INDEX IF NOT EXISTS idx_user_diaries_user_id ON user_diaries(user_id);
            CREATE INDEX IF NOT EXISTS idx_user_diaries_created_at ON user_diaries(created_at);
            CREATE INDEX IF NOT EXISTS idx_analyses_diary_id ON analyses(diary_id);
            CREATE INDEX IF NOT EXISTS idx_analyses_has_advice ON analyses(has_advice);
        ''')
        
        # Update existing records in analyses table to have has_advice = TRUE
        await conn.execute('''
            UPDATE analyses 
            SET has_advice = TRUE 
            WHERE has_advice IS NULL OR has_advice = FALSE;
        ''')
        
        # Update existing records in user_analyses to have mood in analysis_data
        await conn.execute('''
            UPDATE user_analyses 
            SET analysis_data = jsonb_set(
                COALESCE(analysis_data, '{}'::jsonb),
                '{mood}',
                CASE
                    WHEN advice_text ILIKE '%anxious%' OR advice_text ILIKE '%anxiety%' OR advice_text ILIKE '%stress%' OR advice_text ILIKE '%worried%' OR advice_text ILIKE '%nervous%' THEN '"Anxious"'
                    WHEN advice_text ILIKE '%happy%' OR advice_text ILIKE '%joy%' OR advice_text ILIKE '%excited%' OR advice_text ILIKE '%great%' OR advice_text ILIKE '%wonderful%' THEN '"Happy"'
                    WHEN advice_text ILIKE '%sad%' OR advice_text ILIKE '%depressed%' OR advice_text ILIKE '%down%' OR advice_text ILIKE '%unhappy%' OR advice_text ILIKE '%grieving%' THEN '"Sad"'
                    WHEN advice_text ILIKE '%angry%' OR advice_text ILIKE '%anger%' OR advice_text ILIKE '%frustrated%' OR advice_text ILIKE '%irritated%' OR advice_text ILIKE '%upset%' THEN '"Angry"'
                    WHEN advice_text ILIKE '%calm%' OR advice_text ILIKE '%peaceful%' OR advice_text ILIKE '%relaxed%' OR advice_text ILIKE '%serene%' OR advice_text ILIKE '%tranquil%' THEN '"Calm"'
                    WHEN advice_text ILIKE '%confused%' OR advice_text ILIKE '%uncertain%' OR advice_text ILIKE '%unsure%' OR advice_text ILIKE '%indecisive%' THEN '"Confused"'
                    ELSE '"Calm"'
                END::jsonb
            )
            WHERE analysis_data IS NULL OR analysis_data->>'mood' IS NULL OR analysis_data->>'mood' = '';
        ''')
        
        # Also add character_type, sign, and birth_map if missing in user_analyses
        await conn.execute('''
            UPDATE user_analyses 
            SET analysis_data = jsonb_set(
                analysis_data,
                '{character_type}',
                '"Unknown"'
            )
            WHERE analysis_data->>'character_type' IS NULL;
            
            UPDATE user_analyses 
            SET analysis_data = jsonb_set(
                analysis_data,
                '{sign}',
                '"Unknown"'
            )
            WHERE analysis_data->>'sign' IS NULL;
            
            UPDATE user_analyses 
            SET analysis_data = jsonb_set(
                analysis_data,
                '{birth_map}',
                '"Unknown"'
            )
            WHERE analysis_data->>'birth_map' IS NULL;
        ''')
        
    logger.info("Database tables created and existing data updated with has_advice column")

@app.on_event("startup")
async def startup_event():
    await create_db_pool()

@app.on_event("shutdown")
async def shutdown_event():
    if connection_pool:
        await connection_pool.close()

# Pydantic models
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

class AnalysisResponse(BaseModel):
    advice: str
    mood: str = "Calm" 
    status: str
    analysis_date: str
    diaries_analyzed: int

# NEW: Pydantic model for Flutter analyses
class FlutterAnalysis(BaseModel):
    diary_id: str
    advice: str
    analysis: str
    mood: Optional[str] = "Calm"
    character_type: Optional[str] = None
    sign: Optional[str] = None
    has_advice: Optional[bool] = True  # NEW field

@app.get("/")
async def home():
    return {
        "message": "Mentra Backend is running!", 
        "timestamp": datetime.utcnow().isoformat(),
        "status": "healthy",
        "features": ["diary_analysis", "personality_advice", "flutter_analyses"]
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
            SELECT id, content, mood, tags, created_at
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
        
        # Get recent diaries for the user
        diaries = await connection_pool.fetch('''
            SELECT content, mood, tags, created_at
            FROM user_diaries 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT $2
        ''', request.user_id, request.diary_count)
        
        # Prepare diary contents for analysis
        diary_contents = [diary["content"] for diary in diaries]
        
        # Get psychological advice (this will handle empty diaries gracefully)
        advisor = get_psychologist()

        analysis_result = advisor.analyze_diaries(
            diaries=diary_contents,
            character_type=request.character_type,
            sign=request.sign,
            birth_map=request.birth_map
        )

        if analysis_result["status"] == "error":
            # Even if there's an error, we return the fallback advice
            logger.error(f"Analysis error: {analysis_result.get('error')}")
        
        # Save the mood in analysis_data - use json.dumps
        analysis_data = json.dumps({
            "character_type": request.character_type,
            "sign": request.sign,
            "birth_map": request.birth_map,
            "mood": analysis_result.get("mood", "Calm"),
            "has_advice": True  # NEW: Always true
        })
        
        # Save the analysis result
        analysis_id = await connection_pool.fetchval('''
            INSERT INTO user_analyses (user_id, analysis_type, advice_text, diaries_analyzed, analysis_data, has_advice)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id
        ''', request.user_id, "diary_analysis", analysis_result["advice"], 
             len(diaries), analysis_data, True)
        
        # Also return the mood in the response
        return {
            "advice": analysis_result["advice"],
            "mood": analysis_result.get("mood", "Calm"),
            "status": "success",
            "analysis_date": analysis_result["analysis_date"],
            "diaries_analyzed": analysis_result["diaries_analyzed"],
            "has_advice": True  # NEW: Always return true
        }
        
    except Exception as e:
        logger.error(f"Error analyzing diaries: {e}")
        # Provide a basic fallback response
        return {
            "advice": "I'm here to help you with psychological insights! Start by writing your first diary entry to get personalized advice.",
            "mood": "Calm",
            "status": "success",
            "analysis_date": datetime.utcnow().isoformat(),
            "diaries_analyzed": 0,
            "has_advice": True  # NEW: Even fallback has advice
        }
    
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
            # Parse analysis_data - it might be a string or dict
            analysis_data_raw = analysis["analysis_data"]
            analysis_data = {}
            
            if analysis_data_raw:
                try:
                    if isinstance(analysis_data_raw, str):
                        # Parse JSON string
                        analysis_data = json.loads(analysis_data_raw)
                    elif isinstance(analysis_data_raw, dict):
                        # Already a dict
                        analysis_data = analysis_data_raw
                    else:
                        # Try to convert whatever it is
                        analysis_data = dict(analysis_data_raw)
                except Exception as e:
                    logger.warning(f"Could not parse analysis_data: {e}, type: {type(analysis_data_raw)}")
                    analysis_data = {}
            
            # Extract fields with defaults
            mood = analysis_data.get("mood", "Calm")
            character_type = analysis_data.get("character_type", "Unknown")
            sign = analysis_data.get("sign", "Unknown")
            birth_map = analysis_data.get("birth_map", "Unknown")
            has_advice = analysis["has_advice"] if analysis["has_advice"] is not None else True
            
            result_analyses.append({
                "id": analysis["id"],
                "type": analysis["analysis_type"],
                "advice": analysis["advice_text"],
                "diaries_analyzed": analysis["diaries_analyzed"],
                "date": analysis["created_at"].isoformat(),
                "analysis_data": analysis_data,
                "mood": mood,
                "character_type": character_type,
                "sign": sign,
                "birth_map": birth_map,
                "has_advice": has_advice  # NEW: Include has_advice
            })
        
        return {
            "analyses": result_analyses
        }
        
    except Exception as e:
        logger.error(f"Error fetching analysis history: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analysis history")

@app.delete("/diaries/{diary_id}")
async def delete_diary(diary_id: int, user_id: str):
    """Delete a diary entry"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        result = await connection_pool.execute('''
            DELETE FROM user_diaries 
            WHERE id = $1 AND user_id = $2
        ''', diary_id, user_id)
        
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Diary not found")
        
        return {
            "message": "Diary deleted successfully",
            "status": "success"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting diary: $e")
        raise HTTPException(status_code=500, detail="Failed to delete diary")

# ==================== FLUTTER ANALYSES ENDPOINTS ====================

@app.get("/analyses")
async def get_all_analyses():
    """Get all analyses for Flutter app"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        analyses = await connection_pool.fetch('''
            SELECT id, diary_id, advice, analysis, mood, character_type, sign, has_advice, created_at
            FROM analyses 
            ORDER BY created_at DESC
        ''')
        
        return [
            {
                "id": analysis["id"],
                "diary_id": analysis["diary_id"],
                "advice": analysis["advice"],
                "analysis": analysis["analysis"],
                "mood": analysis["mood"] or "Calm",
                "character_type": analysis["character_type"],
                "sign": analysis["sign"],
                "has_advice": bool(analysis["has_advice"]) if analysis["has_advice"] is not None else True,  # Ensure boolean
                "created_at": analysis["created_at"].isoformat()
            }
            for analysis in analyses
        ]
        
    except Exception as e:
        logger.error(f"Error fetching analyses: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analyses")

@app.post("/analyses")
async def create_analysis(analysis: FlutterAnalysis):
    """Create a new analysis for Flutter app"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        # Ensure has_advice is always True
        has_advice = analysis.has_advice if analysis.has_advice is not None else True
        
        # Upsert: Insert or update if diary_id already exists
        analysis_id = await connection_pool.fetchval('''
            INSERT INTO analyses (diary_id, advice, analysis, mood, character_type, sign, has_advice)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (diary_id) 
            DO UPDATE SET 
                advice = EXCLUDED.advice,
                analysis = EXCLUDED.analysis,
                mood = EXCLUDED.mood,
                character_type = EXCLUDED.character_type,
                sign = EXCLUDED.sign,
                has_advice = EXCLUDED.has_advice,
                created_at = CURRENT_TIMESTAMP
            RETURNING id
        ''', analysis.diary_id, analysis.advice, analysis.analysis, 
             analysis.mood, analysis.character_type, analysis.sign, has_advice)
        
        return {
            "message": "Analysis saved successfully",
            "analysis_id": analysis_id,
            "has_advice": has_advice,
            "status": "success"
        }
        
    except Exception as e:
        logger.error(f"Error saving analysis: {e}")
        raise HTTPException(status_code=500, detail="Failed to save analysis")

@app.get("/analyses/{diary_id}")
async def get_analysis_by_diary_id(diary_id: str):
    """Get analysis by diary ID"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        analysis = await connection_pool.fetchrow('''
            SELECT id, diary_id, advice, analysis, mood, character_type, sign, has_advice, created_at
            FROM analyses 
            WHERE diary_id = $1
        ''', diary_id)
        
        if not analysis:
            raise HTTPException(status_code=404, detail="Analysis not found")
        
        return {
            "id": analysis["id"],
            "diary_id": analysis["diary_id"],
            "advice": analysis["advice"],
            "analysis": analysis["analysis"],
            "mood": analysis["mood"] or "Calm",
            "character_type": analysis["character_type"],
            "sign": analysis["sign"],
            "has_advice": bool(analysis["has_advice"]) if analysis["has_advice"] is not None else True,
            "created_at": analysis["created_at"].isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching analysis: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analysis")

@app.delete("/analyses/{diary_id}")
async def delete_analysis(diary_id: str):
    """Delete analysis by diary ID"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        result = await connection_pool.execute('''
            DELETE FROM analyses 
            WHERE diary_id = $1
        ''', diary_id)
        
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Analysis not found")
        
        return {
            "message": "Analysis deleted successfully",
            "status": "success"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting analysis: {e}")
        raise HTTPException(status_code=500, detail="Failed to delete analysis")

# Test endpoint to verify JSONB works
@app.get("/test-jsonb")
async def test_jsonb():
    """Test JSONB insertion and retrieval"""
    try:
        if not connection_pool:
            return {"error": "No database connection"}
        
        test_data = {
            "character_type": "ISTJ", 
            "sign": "Aquarius", 
            "birth_map": "Test",
            "mood": "Calm",
            "has_advice": True,
            "test_timestamp": datetime.utcnow().isoformat()
        }
        
        # Test insertion with json.dumps
        analysis_id = await connection_pool.fetchval('''
            INSERT INTO user_analyses (user_id, analysis_type, advice_text, diaries_analyzed, analysis_data, has_advice)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id
        ''', "test_user", "test_analysis", "This is a test advice", 1, json.dumps(test_data), True)
        
        # Test retrieval
        result = await connection_pool.fetchrow('''
            SELECT analysis_data, has_advice FROM user_analyses WHERE id = $1
        ''', analysis_id)
        
        return {
            "success": True,
            "inserted_id": analysis_id,
            "retrieved_data": result["analysis_data"],
            "retrieved_has_advice": result["has_advice"],
            "message": "JSONB test completed successfully"
        }
        
    except Exception as e:
        return {"error": str(e), "success": False}

# Endpoint to check database schema
@app.get("/check-schema")
async def check_schema():
    """Check if analyses table has has_advice column"""
    try:
        if not connection_pool:
            return {"error": "No database connection"}
        
        # Check if analyses table exists and has has_advice column
        result = await connection_pool.fetchrow('''
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'analyses' AND column_name = 'has_advice'
        ''')
        
        if result:
            return {
                "success": True,
                "has_advice_column_exists": True,
                "column_type": result["data_type"],
                "message": "analyses table has has_advice column"
            }
        else:
            return {
                "success": False,
                "has_advice_column_exists": False,
                "message": "analyses table does not have has_advice column"
            }
        
    except Exception as e:
        return {"error": str(e), "success": False}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=port,
        workers=4
    )