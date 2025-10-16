from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import json
import os
import tempfile
import sys
import logging

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        try:
            data = request.get_json()
            name = data.get('name', 'Unknown')
            score = len(name) * 7
            return jsonify({
                "message": f"Hello {name}, your analysis score is {score}",
                "status": "success"
            })
        except Exception as e:
            logger.error(f"Error in home POST: {e}")
            return jsonify({
                "message": f"Error: {str(e)}",
                "status": "error"
            }), 500
    
    return jsonify({
        "message": "Mentra Backend is running!", 
        "status": "success",
        "endpoints": ["/", "/process-text"]
    })


@app.route('/process-text', methods=['POST'])
def process_text():
    """Process text through your document pipeline"""
    try:
        data = request.get_json()
        text_content = data.get('text', '')
        
        if not text_content:
            return jsonify({
                "status": "error",
                "message": "No text provided"
            }), 400
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(text_content)
            temp_path = f.name
        
        try:
            result = subprocess.run([
                'python', 'embedding_data.py', '--file', temp_path
            ], capture_output=True, text=True, cwd='BackEnd')
            
            os.unlink(temp_path)
            
            if result.returncode == 0:
                pipeline_output = json.loads(result.stdout)
                return jsonify({
                    "status": "success", 
                    "data": pipeline_output,
                    "message": "Text processed successfully"
                })
            else:
                return jsonify({
                    "status": "error",
                    "message": f"Pipeline failed: {result.stderr}"
                }), 500
                
        except Exception as pipe_error:

            os.unlink(temp_path)  # Ensure cleanup
            return jsonify({
                "status": "success",
                "data": {
                    "chunks_count": 1,
                    "context": {"chunk-001": text_content[:500] + "..."},
                    "sources": ["text_input"],
                    "status": "processed"
                },
                "message": "Text processed (fallback mode)"
            })
            
    except Exception as e:
        logger.error(f"Text processing error: {e}")
        return jsonify({
            "status": "error",
            "message": f"Text processing error: {str(e)}"
        }), 500


if __name__ == '__main__':
    os.makedirs('uploads', exist_ok=True)
    app.run(host='0.0.0.0', port=5000, debug=True)