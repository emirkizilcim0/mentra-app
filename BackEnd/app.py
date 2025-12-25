from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import asyncpg
import os
import uuid
import json
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
        # Create tables if they don't exist
        await create_tables(conn)
        logger.info("Database setup completed")

async def create_tables(conn):
    """Create all necessary tables with correct schema"""
    
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
    
    # Create analyses table - FIXED: Remove analysis column, use advice for both
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS analyses (
            id SERIAL PRIMARY KEY,
            analysis_key VARCHAR(255) NOT NULL UNIQUE,
            diary_id INTEGER NOT NULL DEFAULT 0,
            user_id VARCHAR(255) NOT NULL,
            advice TEXT NOT NULL,
            mood VARCHAR(100),
            mood_source VARCHAR(50),
            character_type VARCHAR(100),
            sign VARCHAR(100),
            has_advice BOOLEAN DEFAULT TRUE,
            seen BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ''')
    
    # Create indexes
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_user_diaries_user_id ON user_diaries(user_id);')
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_user_diaries_created_at ON user_diaries(created_at);')
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_analyses_user_id ON analyses(user_id);')
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_analyses_diary_id ON analyses(diary_id);')
    
    # Drop the analysis column if it exists (legacy schema)
    try:
        await conn.execute('ALTER TABLE analyses DROP COLUMN IF EXISTS analysis;')
        logger.info("✅ Dropped legacy 'analysis' column")
    except Exception as e:
        logger.info(f"ℹ️ 'analysis' column already removed or doesn't exist: {e}")

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
    character_type: str
    sign: str
    birth_map: str
    diary_count: Optional[int] = 10
    diaries: Optional[List[str]] = None
    diary_ids: Optional[List[int]] = None

class SaveAnalysisRequest(BaseModel):
    diary_id: Optional[int] = 0
    advice: str
    mood: str = "Neutral"
    mood_source: str = "ai_detected"
    character_type: str
    sign: str
    has_advice: bool = True
    seen: bool = False

def create_analysis_key(user_id: str, diary_id=0) -> str:
    """Create a guaranteed unique analysis key"""
    unique_id = uuid.uuid4().hex
    try:
        diary_id_int = int(diary_id)
    except (TypeError, ValueError):
        diary_id_int = 0

    if diary_id_int > 0:
        return f"diary_{diary_id_int}_{unique_id}"
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
            "status": "success",
            "user_id": user_id
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
        
        limit = int(limit)
        diaries = await connection_pool.fetch(f'''
            SELECT id, content, mood, tags, created_at
            FROM user_diaries 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT {limit}
        ''', user_id)
        
        # Fetch analyses for each diary
        diary_list = []
        for diary in diaries:
            diary_id = diary["id"]
            
            # Get the latest analysis for this diary
            analysis = await connection_pool.fetchrow('''
                SELECT mood, mood_source, advice, seen
                FROM analyses 
                WHERE user_id = $1 AND diary_id = $2
                ORDER BY created_at DESC 
                LIMIT 1
            ''', user_id, diary_id)
            
            # Use analysis mood if available
            display_mood = diary["mood"]
            if analysis and analysis["mood"]:
                display_mood = analysis["mood"]
            
            diary_list.append({
                "id": diary_id,
                "content": diary["content"],
                "mood": display_mood,
                "tags": diary["tags"],
                "date": diary["created_at"].isoformat(),
                "has_advice": analysis is not None,
                "advice": analysis["advice"] if analysis else "",
                "analysis": analysis["advice"] if analysis else "",  # Use advice for both
                "seen": analysis["seen"] if analysis else False
            })
        
        return {
            "diaries": diary_list,
            "total": len(diary_list),
            "user_id": user_id
        }
        
    except Exception as e:
        logger.error(f"Error fetching diaries: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch diaries")

@app.post("/analyze/diaries")
async def analyze_diaries(request: DiaryAnalysisRequest, user_id: str):
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
                    detail="Invalid diary IDs provided."
                )
            
            # Get specific diaries by IDs for this user
            diary_records = await connection_pool.fetch('''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 AND id = ANY($2)
                ORDER BY created_at DESC
            ''', user_id, diary_ids_int)
            
            diary_contents = [d["content"] for d in diary_records]
            source = "specific_ids"
            
        else:
            limit = int(request.diary_count)
            # Get recent diaries for this user
            diary_records = await connection_pool.fetch(f'''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 
                ORDER BY created_at DESC 
                LIMIT {limit}
            ''', user_id)
            
            diary_contents = [d["content"] for d in diary_records]
            source = "recent_db"
        
        # Validate we have diaries to analyze
        if not diary_contents:
            raise HTTPException(
                status_code=400,
                detail="No diaries found to analyze."
            )
        
        logger.info(f"Analyzing {len(diary_contents)} diaries for user {user_id}")
        
        # Get analysis from AI
        advisor = get_psychologist()
        analysis_result = advisor.analyze_diaries(
            diaries=diary_contents,
            character_type=request.character_type,
            sign=request.sign,
            birth_map=request.birth_map
        )

        # Process results
        analysis_responses = []
        
        if "results" in analysis_result:
            # NEW FORMAT: Individual diary results
            results = analysis_result.get("results", [])
            
            for idx in range(len(diary_records)):
                diary_record = diary_records[idx]
                
                # Get result for this diary (or fallback)
                result = results[idx] if idx < len(results) else {
                    "mood": "Neutral",
                    "advice": "",
                    "analysis_date": datetime.utcnow().isoformat()
                }
                
                final_mood = result.get("mood") or "Neutral"
                mood_source = "ai_detected"

                
                # Create analysis key
                analysis_key = create_analysis_key(user_id, diary_record["id"] if source != "request_content" else 0)
                
                advice_text = result.get("advice", "")
                
                # Save to database for real diaries
                if connection_pool and source != "request_content":
                    diary_id = diary_record["id"]
                    
                    # Insert into analyses table
                    await connection_pool.execute('''
                        INSERT INTO analyses (
                            analysis_key, diary_id, user_id, advice,
                            mood, mood_source, character_type, sign, has_advice, seen
                        )
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                    ''', analysis_key, diary_id, user_id, advice_text,
                         final_mood, mood_source, request.character_type, 
                         request.sign, True, False)
                    
                    logger.info(f"✅ Saved analysis for diary {diary_id}")
                
                analysis_responses.append({
                    "diary_index": idx + 1,
                    "source_diary_id": diary_record["id"] if source != "request_content" else 0,
                    "mood": final_mood,
                    "mood_source": mood_source,
                    "advice": advice_text,
                    "analysis_date": result.get("analysis_date", datetime.utcnow().isoformat()),
                    "status": "success",
                    "analysis_key": analysis_key
                })
        else:
            # OLD FORMAT: Single analysis for all diaries
            ai_mood = analysis_result.get("mood", "Neutral")
            advice_text = analysis_result.get("advice", "")
            
            for idx, diary_record in enumerate(diary_records):
                final_mood = analysis_result.get("mood") or "Neutral"
                mood_source = "ai_detected"
                
                analysis_key = create_analysis_key(user_id, diary_record["id"] if source != "request_content" else 0)
                
                analysis_responses.append({
                    "diary_index": idx + 1,
                    "source_diary_id": diary_record["id"] if source != "request_content" else 0,
                    "mood": final_mood,
                    "mood_source": mood_source,
                    "advice": advice_text,
                    "analysis_date": analysis_result.get("analysis_date", datetime.utcnow().isoformat()),
                    "status": "success",
                    "analysis_key": analysis_key
                })
                
                # Save to database for real diaries
                if connection_pool and source != "request_content":
                    diary_id = diary_record["id"]
                    
                    await connection_pool.execute('''
                        INSERT INTO analyses (
                            analysis_key, diary_id, user_id, advice,
                            mood, mood_source, character_type, sign, has_advice, seen
                        )
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                    ''', analysis_key, diary_id, user_id, advice_text,
                         final_mood, mood_source, request.character_type, 
                         request.sign, True, False)
        
        return {
            "entries_analyzed": len(diary_contents),
            "results": analysis_responses,
            "status": "success",
            "diaries_analyzed": len(diary_contents),
            "message": f"Successfully analyzed {len(diary_contents)} diaries",
            "user_id": user_id
        }
        
    except Exception as e:
        logger.error(f"Error analyzing diaries: {e}", exc_info=True)
        
        advisor = get_psychologist()
        fallback_advice = advisor._get_fallback_advice(
            request.character_type, request.sign
        )
        
        return {
            "advice": fallback_advice,
            "mood": "Neutral",
            "status": "success",
            "analysis_date": datetime.utcnow().isoformat(),
            "diaries_analyzed": 0,
            "has_advice": True,
            "warning": "Used fallback analysis",
            "user_id": user_id
        }

@app.get("/analysis/history/{user_id}")
async def get_analysis_history(user_id: str, limit: int = 10):
    """Get previous analysis results for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        limit = int(limit)
        analyses = await connection_pool.fetch(f'''
            SELECT id, analysis_key, diary_id, user_id, advice,
                   mood, mood_source, character_type, sign, has_advice, seen, created_at
            FROM analyses 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT {limit}
        ''', user_id)
        
        result_analyses = []
        for analysis in analyses:
            result_analyses.append({
                "id": analysis["id"],
                "analysis_key": analysis["analysis_key"],
                "diary_id": analysis["diary_id"],
                "user_id": analysis["user_id"],
                "advice": analysis["advice"],
                "analysis": analysis["advice"],  # Duplicate advice as analysis
                "mood": analysis["mood"],
                "mood_source": analysis["mood_source"],
                "character_type": analysis["character_type"],
                "sign": analysis["sign"],
                "has_advice": analysis["has_advice"],
                "seen": analysis["seen"],
                "date": analysis["created_at"].isoformat(),
                "created_at": analysis["created_at"].isoformat()
            })
        
        return {
            "analyses": result_analyses,
            "user_id": user_id
        }
        
    except Exception as e:
        logger.error(f"Error fetching analysis history: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analysis history")

@app.get("/analyses")
async def get_user_analyses(
    user_id: Optional[str] = None,
    diary_id: Optional[int] = None,
    limit: int = 10
):
    """Get analyses for users"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")

        limit = int(limit)

        if user_id:
            if diary_id:
                analyses = await connection_pool.fetch(f'''
                    SELECT id, analysis_key, diary_id, user_id, advice,
                           mood, mood_source, character_type, sign, has_advice, seen, created_at
                    FROM analyses
                    WHERE user_id = $1 AND diary_id = $2
                    ORDER BY created_at DESC
                    LIMIT {limit}
                ''', user_id, diary_id)
            else:
                analyses = await connection_pool.fetch(f'''
                    SELECT id, analysis_key, diary_id, user_id, advice,
                           mood, mood_source, character_type, sign, has_advice, seen, created_at
                    FROM analyses
                    WHERE user_id = $1
                    ORDER BY created_at DESC
                    LIMIT {limit}
                ''', user_id)
        else:
            # Get all analyses
            analyses = await connection_pool.fetch(f'''
                SELECT id, analysis_key, diary_id, user_id, advice,
                       mood, mood_source, character_type, sign, has_advice, seen, created_at
                FROM analyses
                ORDER BY created_at DESC
                LIMIT {limit}
            ''')

        return [
            {
                "id": a["id"],
                "analysis_key": a["analysis_key"],
                "diary_id": a["diary_id"],
                "user_id": a["user_id"],
                "advice": a["advice"],
                "analysis": a["advice"],  # Duplicate advice as analysis
                "mood": a["mood"],
                "mood_source": a["mood_source"],
                "character_type": a["character_type"],
                "sign": a["sign"],
                "has_advice": a["has_advice"],
                "seen": a["seen"],
                "created_at": a["created_at"].isoformat()
            }
            for a in analyses
        ]

    except Exception as e:
        logger.error(f"Error fetching analyses: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analyses")

@app.post("/analyses")
async def save_analysis(payload: SaveAnalysisRequest, user_id: str):
    """Save an analysis for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")

        analysis_key = create_analysis_key(user_id, payload.diary_id)

        await connection_pool.execute(
            '''
            INSERT INTO analyses (
                analysis_key, diary_id, user_id, advice,
                mood, mood_source, character_type, sign, has_advice, seen
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            ON CONFLICT (analysis_key) DO UPDATE SET
                advice = EXCLUDED.advice,
                mood = EXCLUDED.mood,
                mood_source = EXCLUDED.mood_source,
                character_type = EXCLUDED.character_type,
                sign = EXCLUDED.sign,
                has_advice = EXCLUDED.has_advice,
                seen = EXCLUDED.seen,
                updated_at = CURRENT_TIMESTAMP
            ''',
            analysis_key,
            payload.diary_id or 0,
            user_id,
            payload.advice,
            payload.mood,
            payload.mood_source,
            payload.character_type,
            payload.sign,
            payload.has_advice,
            payload.seen
        )

        return {
            "status": "success",
            "analysis_key": analysis_key,
            "user_id": user_id
        }

    except Exception as e:
        logger.error(f"Failed to save analysis: {e}")
        raise HTTPException(status_code=500, detail="Failed to save analysis")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        if connection_pool:
            async with connection_pool.acquire() as conn:
                await conn.fetchval('SELECT 1')
                
                # Get table info
                table_info = {}
                tables = ["user_diaries", "analyses"]
                for table in tables:
                    try:
                        count = await conn.fetchval(f'SELECT COUNT(*) FROM {table}')
                        table_info[table] = count
                    except:
                        table_info[table] = "table not found"
            
            return {
                "status": "healthy",
                "timestamp": datetime.utcnow().isoformat(),
                "database": "connected",
                "table_counts": table_info,
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
        workers=1
    )