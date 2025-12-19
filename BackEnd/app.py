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
            api_key=api_key,
            model="models/gemini-1.5-flash"
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
    
    # Create tables for diaries
    async with connection_pool.acquire() as conn:
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
            
            CREATE TABLE IF NOT EXISTS user_analyses (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                analysis_type VARCHAR(100) NOT NULL,
                advice_text TEXT NOT NULL,
                diaries_analyzed INTEGER,
                analysis_data JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            
            CREATE INDEX IF NOT EXISTS idx_user_diaries_user_id ON user_diaries(user_id);
            CREATE INDEX IF NOT EXISTS idx_user_diaries_created_at ON user_diaries(created_at);
        ''')
    logger.info("Database tables created")

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
    diary_count: Optional[int] = 10  # Number of recent diaries to analyze

class AnalysisResponse(BaseModel):
    advice: str
    status: str
    analysis_date: str
    diaries_analyzed: int

@app.get("/")
async def home():
    return {
        "message": "Mentra Backend is running!", 
        "timestamp": datetime.utcnow().isoformat(),
        "status": "healthy",
        "features": ["diary_analysis", "personality_advice"]
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
        
        # FIX: Convert the analysis_data to JSON string using json.dumps()
        analysis_data = json.dumps({
            "character_type": request.character_type,
            "sign": request.sign,
            "birth_map": request.birth_map
        })
        
        # Save the analysis result
        analysis_id = await connection_pool.fetchval('''
            INSERT INTO user_analyses (user_id, analysis_type, advice_text, diaries_analyzed, analysis_data)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id
        ''', request.user_id, "diary_analysis", analysis_result["advice"], 
             len(diaries), analysis_data)  # Now passing JSON string instead of dict
        
        return AnalysisResponse(
            advice=analysis_result["advice"],
            status="success",
            analysis_date=analysis_result["analysis_date"],
            diaries_analyzed=analysis_result["diaries_analyzed"]
        )
        
    except Exception as e:
        logger.error(f"Error analyzing diaries: {e}")
        # Provide a basic fallback response
        return AnalysisResponse(
            advice="I'm here to help you with psychological insights! Start by writing your first diary entry to get personalized advice.",
            status="success",
            analysis_date=datetime.utcnow().isoformat(),
            diaries_analyzed=0
        )

@app.get("/analysis/history/{user_id}")
async def get_analysis_history(user_id: str, limit: int = 10):
    """Get previous analysis results for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        analyses = await connection_pool.fetch('''
            SELECT id, analysis_type, advice_text, diaries_analyzed, created_at, analysis_data
            FROM user_analyses 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT $2
        ''', user_id, limit)
        
        return {
            "analyses": [
                {
                    "id": analysis["id"],
                    "type": analysis["analysis_type"],
                    "advice": analysis["advice_text"],
                    "diaries_analyzed": analysis["diaries_analyzed"],
                    "date": analysis["created_at"].isoformat(),
                    "analysis_data": analysis["analysis_data"]  # This will be automatically converted from JSONB
                }
                for analysis in analyses
            ]
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

# Add a test endpoint to verify JSONB works
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
            "test_timestamp": datetime.utcnow().isoformat()
        }
        
        # Test insertion with json.dumps
        analysis_id = await connection_pool.fetchval('''
            INSERT INTO user_analyses (user_id, analysis_type, advice_text, diaries_analyzed, analysis_data)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id
        ''', "test_user", "test_analysis", "This is a test advice", 1, json.dumps(test_data))
        
        # Test retrieval
        result = await connection_pool.fetchrow('''
            SELECT analysis_data FROM user_analyses WHERE id = $1
        ''', analysis_id)
        
        return {
            "success": True,
            "inserted_id": analysis_id,
            "retrieved_data": result["analysis_data"],
            "message": "JSONB test completed successfully"
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