from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import logging
import asyncpg
import asyncio
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Simple in-memory storage for testing (replace with PostgreSQL later)
diaries_storage = []

class DiaryService:
    @staticmethod
    async def get_db_pool():
        DATABASE_URL = os.getenv("DATABASE_URL")
        if not DATABASE_URL:
            return None
        return await asyncpg.create_pool(DATABASE_URL)

@app.route('/')
def home():
    return jsonify({"message": "Mentra Backend is running!", "status": "healthy"})

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "database": "not_configured"})

@app.route('/diaries/save', methods=['POST'])
def save_diary():
    try:
        data = request.get_json()
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({"error": "user_id is required"}), 400
        
        diary_entry = {
            'id': len(diaries_storage) + 1,
            'user_id': user_id,
            'content': data.get('content', ''),
            'mood': data.get('mood', ''),
            'tags': data.get('tags', []),
            'date': '2024-01-01'  # Simplified for now
        }
        
        diaries_storage.append(diary_entry)
        
        return jsonify({
            "message": "Diary saved successfully",
            "diary_id": diary_entry['id'],
            "status": "success"
        })
        
    except Exception as e:
        logger.error(f"Error saving diary: {e}")
        return jsonify({"error": "Failed to save diary"}), 500

@app.route('/diaries/<user_id>', methods=['GET'])
def get_user_diaries(user_id):
    try:
        limit = request.args.get('limit', 20, type=int)
        
        user_diaries = [d for d in diaries_storage if d['user_id'] == user_id]
        user_diaries = user_diaries[:limit]
        
        return jsonify({
            "diaries": user_diaries,
            "total": len(user_diaries)
        })
        
    except Exception as e:
        logger.error(f"Error fetching diaries: {e}")
        return jsonify({"error": "Failed to fetch diaries"}), 500

@app.route('/analyze/diaries', methods=['POST'])
def analyze_diaries():
    return jsonify({
        "message": "AI features will be added after successful deployment",
        "status": "disabled"
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)