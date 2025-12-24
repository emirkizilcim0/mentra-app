from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import asyncpg
import os
import uuid
import json  # IMPORT ADDED
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
        # FIRST: Check and migrate existing tables
        await migrate_database_schema(conn)
        
        # SECOND: Create any missing tables
        await create_missing_tables(conn)
        
        # THIRD: Create indexes
        await create_indexes(conn)
        
        logger.info("Database setup completed")


@app.get("/analysis/history/{user_id}")
async def get_analysis_history(user_id: str, limit: int = 10):
    """Get previous analysis results for a user"""
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")
        
        limit = int(limit)
        analyses = await connection_pool.fetch(f'''
            SELECT id, analysis_type, advice_text, diaries_analyzed, created_at, analysis_data, has_advice
            FROM user_analyses 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT {limit}
        ''', user_id)
        
        result_analyses = []
        for analysis in analyses:
            analysis_data_raw = analysis["analysis_data"]
            analysis_data = {}
            
            if analysis_data_raw:
                try:
                    if isinstance(analysis_data_raw, str):
                        analysis_data = json.loads(analysis_data_raw)
                    elif isinstance(analysis_data_raw, dict):
                        analysis_data = analysis_data_raw
                    else:
                        analysis_data = dict(analysis_data_raw)
                except Exception as e:
                    logger.warning(f"Could not parse analysis_data: {e}")
                    analysis_data = {}
            
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
                "has_advice": has_advice
            })
        
        return {
            "analyses": result_analyses
        }
        
    except Exception as e:
        logger.error(f"Error fetching analysis history: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch analysis history")


async def migrate_database_schema(conn):
    """Migrate existing database schema to new version"""
    try:
        # Check if analyses table exists
        analyses_exists = await conn.fetchval('''
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'analyses'
            )
        ''')
        if analyses_exists:
            await conn.execute("""
        ALTER TABLE analyses
        ADD COLUMN IF NOT EXISTS seen BOOLEAN DEFAULT FALSE,
        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
        """)
            # Check if user_id column exists
            user_id_exists = await conn.fetchval('''
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'analyses' AND column_name = 'user_id'
                )
            ''')
            
            if not user_id_exists:
                logger.info("Migrating analyses table: adding user_id and diary_id columns")
                
                # Add new columns
                await conn.execute('ALTER TABLE analyses ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);')
                await conn.execute('ALTER TABLE analyses ADD COLUMN IF NOT EXISTS diary_id INTEGER;')
                await conn.execute('ALTER TABLE analyses ADD COLUMN IF NOT EXISTS mood_source VARCHAR(50);')
                
                # Try to parse user_id from existing diary_id field (if it contains user info)
                # This is a best-effort migration
                try:
                    analyses = await conn.fetch('SELECT id, diary_id FROM analyses WHERE user_id IS NULL')
                    for analysis in analyses:
                        diary_id_str = analysis["diary_id"]
                        # Try to extract user_id from old diary_id format
                        if diary_id_str and '_' in diary_id_str:
                            parts = diary_id_str.split('_')
                            if len(parts) >= 2:
                                user_id_part = parts[0]
                                diary_id_part = parts[1] if len(parts) > 1 else None
                                
                                # Update with extracted user_id and diary_id
                                await conn.execute('''
                                    UPDATE analyses 
                                    SET user_id = $1, 
                                        diary_id = CASE WHEN $2 ~ '^[0-9]+$' THEN $2::INTEGER ELSE 0 END
                                    WHERE id = $3
                                ''', user_id_part, diary_id_part, analysis["id"])
                    
                    logger.info(f"Migrated {len(analyses)} existing analyses records")
                except Exception as e:
                    logger.warning(f"Could not migrate existing analyses: {e}")
                    # Set default values for unmigrated records
                    await conn.execute('UPDATE analyses SET user_id = \'unknown\', diary_id = 0 WHERE user_id IS NULL')
            
            # Check for other missing columns
            column_checks = [
                ("analysis_key", "VARCHAR(255)"),
                ("mood_source", "VARCHAR(50)"),
            ]
            
            for column_name, column_type in column_checks:
                exists = await conn.fetchval(f'''
                    SELECT EXISTS (
                        SELECT FROM information_schema.columns 
                        WHERE table_name = 'analyses' AND column_name = '{column_name}'
                    )
                ''')
                
                if not exists:
                    await conn.execute(f'ALTER TABLE analyses ADD COLUMN IF NOT EXISTS {column_name} {column_type};')
                    logger.info(f"Added {column_name} column to analyses table")
        
        # Check user_diaries table for new columns
        user_diaries_exists = await conn.fetchval('''
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'user_diaries'
            )
        ''')
        
        if user_diaries_exists:
            # Add mood_confidence if missing
            mood_confidence_exists = await conn.fetchval('''
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'user_diaries' AND column_name = 'mood_confidence'
                )
            ''')
            
            if not mood_confidence_exists:
                await conn.execute('ALTER TABLE user_diaries ADD COLUMN IF NOT EXISTS mood_confidence VARCHAR(20);')
                logger.info("Added mood_confidence column to user_diaries table")
            
            # Add advice_preview if missing
            advice_preview_exists = await conn.fetchval('''
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'user_diaries' AND column_name = 'advice_preview'
                )
            ''')
            
            if not advice_preview_exists:
                await conn.execute('ALTER TABLE user_diaries ADD COLUMN IF NOT EXISTS advice_preview TEXT;')
                logger.info("Added advice_preview column to user_diaries table")
        
    except Exception as e:
        logger.error(f"Error during database migration: {e}")
        # Don't crash if migration fails, but log it

async def create_missing_tables(conn):
    """Create any tables that don't exist"""
    
    # Create user_diaries table if it doesn't exist
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
    
    # Create user_analyses table if it doesn't exist
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
    
    # Create analyses table if it doesn't exist (with new schema)
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
    
    logger.info("Ensured all tables exist")

async def create_indexes(conn):
    """Create indexes if they don't exist"""
    indexes = [
        ("idx_user_diaries_user_id", "user_diaries", "user_id"),
        ("idx_user_diaries_created_at", "user_diaries", "created_at"),
        ("idx_analyses_diary_id", "analyses", "diary_id"),
        ("idx_analyses_user_id", "analyses", "user_id"),
        ("idx_analyses_analysis_key", "analyses", "analysis_key"),
        ("idx_user_diaries_mood", "user_diaries", "mood"),
    ]
    
    for index_name, table_name, column_name in indexes:
        try:
            await conn.execute(f'''
                CREATE INDEX IF NOT EXISTS {index_name} 
                ON {table_name} ({column_name});
            ''')
        except Exception as e:
            logger.warning(f"Could not create index {index_name}: {e}")

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
    """Detect mood from content with rule-based overrides."""
    content_lower = content.lower()
    
    # Rule-based mood detection (takes priority)
    # Add Turkish keywords for "bugun cok sinirliyim"
    angry_keywords = ["angry", "mad", "furious", "rage", "irritated", "annoyed", 
                     "upset", "hate", "frustrated", "cant stand", "pissed",
                     "sinir", "kızgın", "öfke", "sinirliyim", "kızgınım"]
    sad_keywords = ["sad", "depressed", "unhappy", "down", "miserable", "hopeless",
                   "üzgün", "mutsuz", "depresif", "hüzünlü"]
    anxious_keywords = ["anxious", "anxiety", "worried", "nervous", "stressed", "tense",
                       "endişeli", "kaygılı", "stresli", "gergin"]
    happy_keywords = ["happy", "joy", "excited", "great", "wonderful", "positive",
                     "mutlu", "neşeli", "heyecanlı", "harika"]
    calm_keywords = ["calm", "peaceful", "relaxed", "serene", "tranquil",
                    "sakin", "huzurlu", "rahat"]
    
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

def create_analysis_key(user_id: str, diary_id=0) -> str:
    """Create a guaranteed unique analysis key"""
    unique_id = uuid.uuid4().hex

    # ✅ Ensure diary_id is an int
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
        
        limit = int(limit)
        # ✅ CORRECT: No cast for LIMIT parameter with asyncpg
        diaries = await connection_pool.fetch(f'''
            SELECT id, content, mood, mood_confidence, advice_preview, tags, created_at
            FROM user_diaries 
            WHERE user_id = $1 
            ORDER BY created_at DESC 
            LIMIT {limit}
        ''', user_id)  # asyncpg will handle int→appropriate type
        
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
                "mood_confidence": diary["mood_confidence"],
                "advice_preview": diary["advice_preview"],
                "tags": diary["tags"],
                "date": diary["created_at"].isoformat(),
                "has_advice": analysis is not None,
                "seen": analysis["seen"] if analysis else False
            })
        
        return {
            "diaries": diary_list,
            "total": len(diary_list),
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
            
            # FIXED: Add type cast for array
            diary_records = await connection_pool.fetch('''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 AND id = ANY(cast($2 as integer[]))
                ORDER BY created_at DESC
            ''', request.user_id, diary_ids_int)
            
            diary_contents = [d["content"] for d in diary_records]
            source = "specific_ids"
            
        else:
            limit = int(request.diary_count)
            # FIXED: Add type cast for limit
            diary_records = await connection_pool.fetch(f'''
                SELECT id, content, mood, tags, created_at
                FROM user_diaries 
                WHERE user_id = $1 
                ORDER BY created_at DESC 
                LIMIT {limit}
            ''', request.user_id)
            
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

        # Process results - handle both old and new response formats
        analysis_responses = []
        
        if "results" in analysis_result:
            # NEW FORMAT: Individual diary results
            results = analysis_result.get("results", [])
            
            if len(results) != len(diary_records):
                logger.warning(f"Result count mismatch: {len(results)} != {len(diary_records)}")
            
            for idx in range(len(diary_records)):
                diary_record = diary_records[idx]
                
                # Get result for this diary (or fallback)
                result = results[idx] if idx < len(results) else {
                    "mood": "Neutral",
                    "advice": "",
                    "analysis_date": datetime.utcnow().isoformat()
                }
                
                ai_mood = result.get("mood", "Neutral")
                final_mood, mood_source = detect_mood_from_content(diary_record["content"], ai_mood)
                
                # Create analysis key
                analysis_key = create_analysis_key(
                    request.user_id, 
                    diary_record["id"] if source != "request_content" else 0
                )
                
                advice_text = result["advice"]
                
                # Save to database for real diaries
                if connection_pool and source != "request_content":
                    diary_id = diary_record["id"]
                    
                    # Insert into analyses table
                    await connection_pool.execute('''
                        INSERT INTO analyses (
    analysis_key,
    diary_id,
    user_id,
    advice,
    mood,
    mood_source,
    character_type,
    sign,
    has_advice,
    seen
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)

                    ''', analysis_key, diary_id, request.user_id, advice_text, 
                         final_mood, mood_source, request.character_type, 
                         request.sign, True, False)
                    
                    # Update the diary
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
                    
                    logger.info(f"✅ Updated diary {diary_id} with mood: {final_mood}")
                
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
        else:
            # OLD FORMAT: Single analysis for all diaries
            ai_mood = analysis_result.get("mood", "Neutral")
            advice_text = analysis_result["advice"]
            
            # Apply rule-based detection to each diary
            for idx, diary_record in enumerate(diary_records):
                final_mood, mood_source = detect_mood_from_content(diary_record["content"], ai_mood)
                
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
                
                # Save to database for real diaries
                if connection_pool and source != "request_content" and diary_record["id"] != "request_0":
                    diary_id = diary_record["id"]
                    
                    # Insert analysis
                    await connection_pool.execute('''
INSERT INTO analyses (
    analysis_key,
    diary_id,
    user_id,
    advice,
    mood,
    mood_source,
    character_type,
    sign,
    has_advice,
    seen
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
                    ''', analysis_key, diary_id, request.user_id, advice_text, 
                         final_mood, mood_source, request.character_type, 
                         request.sign, True, False)
                    
                    # Update diary
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
        
        # Save summary to user_analyses for real diaries
        if connection_pool and source != "request_content" and analysis_responses:
            summary_result = analysis_responses[0]
            
            analysis_data = {
                "character_type": request.character_type,
                "sign": request.sign,
                "birth_map": request.birth_map,
                "moods": [resp["mood"] for resp in analysis_responses],
                "mood_sources": [resp["mood_source"] for resp in analysis_responses],
                "has_advice": True,
                "individual_analyses": len(analysis_responses),
                "source_diary_ids": [d["id"] for d in diary_records if isinstance(d["id"], int)],
                "analysis_keys": [resp["analysis_key"] for resp in analysis_responses],
                "source": source
            }
                        
            analysis_data_json = json.dumps(analysis_data)
            
            await connection_pool.fetchval('''
                INSERT INTO user_analyses (
                    user_id, analysis_type, advice_text, diaries_analyzed, analysis_data, has_advice
                )
                VALUES ($1, $2, $3, $4, $5::jsonb, $6)
                RETURNING id
            ''', request.user_id,
                 f"diary_analysis_{source}",
                 advice_text,
                 len(diary_contents),
                 analysis_data_json,
                 True)
            
        
        return {
            "entries_analyzed": len(diary_contents),
            "results": analysis_responses,
            "status": "success",
            "diaries_analyzed": len(diary_contents),
            "source": source,
            "advice_saved": source != "request_content",
            "message": f"Successfully analyzed {len(diary_contents)} diaries",
            "mood_corrections": sum(1 for r in analysis_responses if r["mood_source"] == "content_override")
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

@app.get("/user/current")
async def get_current_user(user_id: Optional[str] = None):
    """
    Get or create a user. Since there's no auth, we use the provided user_id
    or create a new one.
    """
    try:
        if not user_id:
            # Create a new user ID
            user_id = f"user_{datetime.utcnow().timestamp()}"
        
        # Check if user exists in any table
        user_exists = False
        if connection_pool:
            # Check in analyses table
            analysis_count = await connection_pool.fetchval(
                'SELECT COUNT(*) FROM analyses WHERE user_id = $1',
                user_id
            )
            
            # Check in user_diaries table
            diary_count = await connection_pool.fetchval(
                'SELECT COUNT(*) FROM user_diaries WHERE user_id = $1',
                user_id
            )
            
            user_exists = (analysis_count > 0) or (diary_count > 0)
        
        return {
            "id": user_id,
            "user_id": user_id,
            "name": "User",
            "type": "User",
            "sign": "Unknown",
            "birth_map": "Unknown",
            "exists": user_exists,
            "created_at": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error in get_current_user: {e}")
        raise HTTPException(status_code=500, detail="Failed to get user info")
@app.get("/analyses")
async def get_user_analyses(
    user_id: Optional[str] = None,
    diary_id: Optional[int] = None,
    limit: int = 10
):
    try:
        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")

        limit = int(limit)

        if user_id:
            if diary_id:
                analyses = await connection_pool.fetch(f'''
                    SELECT *
                    FROM analyses
                    WHERE user_id = $1 AND diary_id = $2
                    ORDER BY created_at DESC
                    LIMIT {limit}
                ''', user_id, diary_id)
            else:
                analyses = await connection_pool.fetch(f'''
                    SELECT *
                    FROM analyses
                    WHERE user_id = $1
                    ORDER BY created_at DESC
                    LIMIT {limit}
                ''', user_id)
        else:
            # ✅ allow fetching all (for now)
            analyses = await connection_pool.fetch(f'''
                SELECT *
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
                    "analysis": a["advice"],
                    "advice": a["advice"],
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
        logger.error(f"Error fetching analyses: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to fetch analyses")

def safe_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default

from pydantic import BaseModel
from typing import Optional

# Add this model for the POST /analyses endpoint
class SaveAnalysisRequest(BaseModel):
    user_id: str
    diary_id: Optional[int] = 0
    analysis_key: Optional[str] = None
    advice: str
    mood: str = "Neutral"
    mood_source: str = "ai_detected"
    character_type: str = "default"
    sign: str = "unknown"
    has_advice: bool = True
    seen: bool = False   # ✅ ADD


@app.post("/analyses")
async def save_analysis(payload: SaveAnalysisRequest):
    try:
        if not payload.user_id:
            raise HTTPException(
                status_code=400,
                detail="user_id is required"
            )

        if not connection_pool:
            raise HTTPException(status_code=500, detail="Database not configured")

        analysis_key = payload.analysis_key or create_analysis_key(
            payload.user_id, payload.diary_id
        )

        await connection_pool.execute(
            '''
INSERT INTO analyses (
    analysis_key,
    diary_id,
    user_id,
    advice,
    mood,
    mood_source,
    character_type,
    sign,
    has_advice,
    seen
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
ON CONFLICT (analysis_key) DO NOTHING
            ''',
            analysis_key,
            payload.diary_id or 0,
            payload.user_id,
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
            "analysis_key": analysis_key
        }

    except Exception as e:
        logger.error(f"❌ Failed to save analysis: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to save analysis")


# ============== OTHER ENDPOINTS ==============

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        if connection_pool:
            async with connection_pool.acquire() as conn:
                await conn.fetchval('SELECT 1')
                
                # Get table info
                table_info = {}
                tables = ["user_diaries", "analyses", "user_analyses"]
                for table in tables:
                    try:
                        count = await conn.fetchval(f'SELECT COUNT(*) FROM {table}')
                        table_info[table] = count
                    except:
                        table_info[table] = "table not found"
                
                # Try to get column info for analyses table
                try:
                    columns = await conn.fetch('''
                        SELECT column_name, data_type 
                        FROM information_schema.columns 
                        WHERE table_name = 'analyses'
                    ''')
                    column_list = [f"{col['column_name']} ({col['data_type']})" for col in columns]
                except:
                    column_list = ["unknown"]
            
            return {
                "status": "healthy",
                "timestamp": datetime.utcnow().isoformat(),
                "database": "connected",
                "table_counts": table_info,
                "analyses_columns": column_list,
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