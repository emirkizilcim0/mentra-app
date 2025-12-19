from typing import List
from langchain.schema import Document
import google.generativeai as genai
from utils import get_config, save_json
from pathlib import Path
import json

import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stderr
)
logger = logging.getLogger(__name__)

# This class provides advices based on user input according to
# one's character anaylsis(MBTI test, signs, birth map(sun, moon, rising signs))
# and gives a detailed advice and motivational speech.
class PsychologistAdvisor:
    """Psychologist class to provide advice based on user input"""
    
    def __init__(self, config):
        self.config = config or get_config()
        genai.configure(api_key=self.config['API_KEY'])
        model_name = self.config['CHAT_MODEL']

        if not model_name.endswith("-latest"):
            logger.warning(f"Model '{model_name}' is not -latest, falling back")
            model_name = "models/gemini-1.5-flash-latest"
        
        self.model = genai.GenerativeModel(model_name)
        
        
        self.summary_prompt = """
        Please provide a detailed advice and motivational speech according to user's character type, sign and birth map.
        Character type: {character_type}
        Sign: {sign}
        Birth map: {birth_map}
        
        Focus on:
        - Character strengths and weaknesses, make user feel you understand them
        - Emotional texts and needs, what user complains about
        - What would be good for user to do as activitys, hobbies, career etc.
        - Overall conclusions/recommendations
        
        Structure your summary with clear sections if appropriate.
        Return the summary in what user's text language.

        Combined Document Content:
        {text}
        """

    def give_advice(self, documents: List[Document]):
        """Summarize all documents combined into one summary"""
        combined_text = "\n\n".join([doc.page_content for doc in documents])
        
        try:
            response = self.model.generate_content(
                self.summary_prompt.format(text=combined_text,
                                           character_type="INTP",                                               # It will be user inputs.
                                           sign="Scorpion",                                                     # It will be user inputs. 
                                           birth_map="Sun in Scorpio, Moon in Cancer, Rising in Virgo"))        # It will be user inputs.
                
            
            sources = list()
            for doc in documents:
                if doc.metadata.get("source", "unknown") not in sources:
                    sources.append(str(doc.metadata.get("source", "unknown")))
                
            return {
                "summary": response.text,
                "sources": sources,
                "total_chunks": len(documents)
            }
        except Exception as e:
            logger.error(f"Error summarizing combined documents: {str(e)}")
            return {
                "error": str(e),
                "sources": [str(doc.metadata.get("source", "unknown")) for doc in documents]
            }

def load_context_chunks(path: str):
    """Load chunks from a given JSON path (default: context_language.json) and convert to Document objects"""
    try:
        config = get_config()
        context_path = Path(path)
        
        if not context_path.exists():
            raise FileNotFoundError(f"Context file not found at {context_path}")
        
        with open(context_path, 'r', encoding='utf-8') as f:
            context_data = json.load(f)
        
        chunks = []
        for chunk_id, content in context_data['context'].items():
            chunks.append(Document(
                page_content=content,
                metadata={
                    "source": context_data['sources'][0] if context_data['sources'] else "unknown",
                    "chunk_id": chunk_id
                }
            ))
        
        return chunks
    
    except Exception as e:
        logger.error(f"Error loading context chunks: {str(e)}")
        raise

def get_combined_summary(path: str):
    summarizer = PsychologistAdvisor(config=get_config())

    logger.info(f"Loading chunks from {path or 'default context_language.json'}...")
    chunks = load_context_chunks(path)
    
    logger.info(f"\nGenerating advise of {len(chunks)} chunks...")
    advise = summarizer.give_advice(chunks)
    logger.info(advise['summary'])
    
    results = {
        "advise": advise,
        "total_chunks": len(chunks)
    }

    save_json(results, "advise.json")
    logger.info(f"Saved advise to {get_config()['SAVE_DATA_DIR']}/advise.json")
    
    return results


import argparse
def main():
    """Automated summarization pipeline for context JSON"""
    parser = argparse.ArgumentParser(description="Summarize document chunks")
    parser.add_argument("--path", type=str, help="Path to context JSON file", default=None)
    args = parser.parse_args()

    try:
        logger.info("=== Starting Document Summarization ===")
        results = get_combined_summary(args.path)
    except Exception as e:
        logger.error(f"\nError in summarization pipeline: {str(e)}")
        raise
    
    return results

if __name__ == "__main__":
    main()