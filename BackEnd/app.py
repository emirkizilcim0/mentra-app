from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # allow Flutter to call this API

@app.route('/')
def home():
    return jsonify({"message": "Backend is running!"})

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.get_json()
    name = data.get('name', 'Unknown')
    score = len(name) * 7  # just a test calculation
    return jsonify({
        "message": f"Hello {name}, your analysis score is {score}",
        "status": "success"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)