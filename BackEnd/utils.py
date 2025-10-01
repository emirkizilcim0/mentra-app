# Eski Data'cılardan kim kaldı beeee..

from pathlib import Path
import os
import json

"""
# openAI - DeepSeek
API_KEY = "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"

from openai import OpenAI

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key="<OPENROUTER_API_KEY>",
)

completion = client.chat.completions.create(
  extra_headers={
    "HTTP-Referer": "<YOUR_SITE_URL>", # Optional. Site URL for rankings on openrouter.ai.
    "X-Title": "<YOUR_SITE_NAME>", # Optional. Site title for rankings on openrouter.ai.
  },
  model="openai/gpt-4o",
  messages=[
    {
      "role": "user",
      "content": "What is the meaning of life?"
    }
  ]
)
print(completion.choices[0].message.content)
"""


# Emir bey buradaydı.

from pathlib import Path
import os
import json

def get_config():
    """Load configuration from environment or defaults, using current working directory"""
    base_dir = Path.cwd()  # <-- ensures paths are relative to where script is run
    return {
        'API_KEY': os.getenv('TUTOR_API_KEY', 'AIzaSyDqEJV1p1WAqlVbcHhxN3K-KAzZNBh1-o4'),   # User yours please...
        'CHAT_MODEL': os.getenv('TUTOR_MODEL', 'models/gemini-2.0-flash'),
        'EMBEDDING_MODEL': os.getenv('EMBEDDING_MODEL', 'models/embedding-001'),
        'DATA_DIR': base_dir / 'data',                                              # file path as args in ingest.py
        'SAVE_DATA_DIR': base_dir / 'saved_data',
        'CHROMA_PATH': base_dir / 'chroma'                                            
    }

def save_json(data, filename, subdir=None):
    """Save JSON data to file with consistent path handling"""
    config = get_config()
    output_dir = Path(config['SAVE_DATA_DIR'])
    if subdir:
        output_dir = output_dir / subdir
    output_dir.mkdir(parents=True, exist_ok=True)
    
    with open(output_dir / filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def load_json(filename, subdir=None):
    """Load JSON data from file"""
    config = get_config()
    input_dir = Path(config['SAVE_DATA_DIR'])
    if subdir:
        input_dir = input_dir / subdir
    
    with open(input_dir / filename, 'r', encoding='utf-8') as f:
        return json.load(f)
