from datetime import datetime
import sys

from langchain_community.document_loaders import TextLoader # Text integration for user's text.
from langchain_experimental.text_splitter import SemanticChunker    # Advanced chunker for deep search, so 
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document
from langchain_community.embeddings import HuggingFaceEmbeddings        # Local embedding instead of Google
from langchain_community.vectorstores import Chroma
import os
import shutil
import re
from langchain.embeddings.base import Embeddings
import logging

from utils import get_config, save_json
import json


from clean import clean_documents

config = get_config()
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stderr  # Log to stderr to avoid interfering with JSON stdout
)

logger = logging.getLogger(__name__)



class LocalEmbedding(Embeddings):
    def __init__(self):
        self.model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2") # Google model reached its limit. :(

    def embed_documents(self, texts):
        return self.model.embed_documents(texts)

    def embed_query(self, text):
        return self.model.embed_query(text)


def save_to_chroma(chunks):
    """Save document chunks to ChromaDB with error handling"""
    try:
        if os.path.exists(config['CHROMA_PATH']):
            shutil.rmtree(config['CHROMA_PATH'])

        embedding_model = LocalEmbedding()

        if not chunks:
            raise ValueError("No chunks to save to Chroma.")

        db = Chroma.from_documents(
            documents=chunks,
            embedding=embedding_model,
            persist_directory=str(config['CHROMA_PATH'])
        )
        
        if hasattr(db, 'persist'):
            db.persist()
        
        logger.info(f"Successfully saved {len(chunks)} chunks to Chroma")
        return db
        
    except Exception as e:
        logger.error(f"Error saving to Chroma: {str(e)}")
        raise

def is_structured_text(text):
    """Check if text appears to be a structured list/document"""
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if len(lines) < 2:
        return False
    
    # Count lines that look like list items (numbered or bulleted)
    list_items = sum(
        1 for line in lines 
        if re.match(r'^(\d+[\.\)]|[-*+])\s', line)  # matches: 1., 1), -, *, +
    )
    return list_items / len(lines) > 0.5  # >50% of lines are list items

# If it is an structrued document, then we split the lines and 
def smart_postprocess_document(doc):
    """Split structured documents into individual list items"""
    if is_structured_text(doc.page_content):
        logger.warning("Structured document detected — splitting line by line.")
        lines = [
            line.strip() 
            for line in doc.page_content.splitlines() 
            if line.strip()
        ]
        return [
            Document(
                page_content=line,
                metadata=doc.metadata
            )
            for line in lines
        ]
    return [doc]


import magic
import mimetypes  # Add this at the top with other imports

def detect_file_type(filepath):
    """Improved file type detection with fallbacks"""
    try:
        # Protection from malwares
        mime = magic.from_file(filepath, mime=True)
        if mime != 'application/octet-stream':
            return mime
        
        # Fallback to mimetypes
        mime, _ = mimetypes.guess_type(filepath)
        if mime:
            return mime
            
        # Check file extension as last resort
        if filepath.lower().endswith('.pdf'):
            return 'application/pdf'
            
        return None
    except:
        # If all fails, check extension
        if filepath.lower().endswith('.pdf'):
            return 'application/pdf'
        return None


from pathlib import Path

LOADER_MAPPING = {"text/plain": TextLoader}

def load_documents(args):
    """Load documents from various sources"""
    documents = []

    if args.file:
        filepath = Path(args.file).absolute()
        if not filepath.exists():
            logger.error(f"File not found: {filepath}")
            return []

        filename = filepath.name
        mime_type = detect_file_type(str(filepath))
        loader_class = LOADER_MAPPING.get(mime_type)

        if not loader_class:
            logger.warning(f"Skipping unsupported MIME type: {mime_type} ({filename})")
            return []

        logger.info(f"Loading {filename} (MIME: {mime_type})")

        try:  
            loader = loader_class(str(filepath), encoding='utf-8')
            
            docs = loader.load()
            for doc in docs:
                doc.metadata["source"] = str(filepath)
                doc.metadata["mime_type"] = mime_type
                processed_docs = smart_postprocess_document(doc)
                documents.extend(processed_docs)

            logger.warning(f"Loaded {len(docs)} doc(s) from {filename}")
            return documents

        except Exception as e:
            logger.error(f"Failed to load {filename}: {e}")
            return []

    return documents

def semantic_chunker_need(doc, wants_deep_search: bool) -> bool:
    """Determine if semantic chunking should be used"""
    content_length = len(doc.page_content)
    if wants_deep_search:
        return True
    return 5000 < content_length < 35000

def get_text_splitter(text_length, wants_deep_search: bool):
    """Get appropriate text splitter based on content length"""
    if wants_deep_search or 5000 <= text_length < 30000:
        return SemanticChunker(LocalEmbedding())
    elif text_length < 1000:
        return RecursiveCharacterTextSplitter(chunk_size=100*3, chunk_overlap=50)       # high chunk_size and lower overlap will yield better results.
    elif 1000 <= text_length < 5000:
        return RecursiveCharacterTextSplitter(chunk_size=300*3, chunk_overlap=100)
    else:
        return RecursiveCharacterTextSplitter(chunk_size=750*3, chunk_overlap=250)

def split_text(documents):
    """Split documents into chunks"""
    if not documents:
        logger.warning("No documents provided for splitting")
        return []

    all_chunks = []
    for doc in documents:
        try:
            use_semantic = semantic_chunker_need(doc, True) # Always true for deep search to understand user's feelings and expressions better.   
            splitter = get_text_splitter(len(doc.page_content), use_semantic)
            chunks = splitter.split_documents([doc])
            all_chunks.extend(chunks)
        except Exception as e:
            logger.error(f"Error splitting document {doc.metadata.get('source', 'unknown')}: {str(e)}")
            continue

    logger.info(f"Split {len(documents)} documents into {len(all_chunks)} chunks")
    if all_chunks:
        logger.debug(f"Sample chunk: {all_chunks[0].page_content[:200]}...")
    return all_chunks

def save(context_dict, chunks):
    """Ensure output is valid JSON for the backend"""
    result = {
        "context": context_dict,
        "sources": list({c.metadata.get("source", "unknown") for c in chunks}),
        "status": "success"
    }

    save_json(result, "context_language.json")

    # Force stdout to UTF-8
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False))  # Only JSON goes to stdout

    return result


import argparse
def main():
    """Main pipeline"""
    parser = argparse.ArgumentParser(description="Document Ingestion Pipeline")
    parser.add_argument('--youtube', type=str, help='YouTube video URL to process')
    parser.add_argument('--file', type=str, help='Path to a file to process')
    args = parser.parse_args()

    if not args.youtube and not args.file:
        error_result = {
            "status": "error",
            "message": "You must specify either --youtube or --file"
        }
        print(json.dumps(error_result))
        return

    try:
        logger.info("=== Document Ingestion Pipeline ===")

        logger.info("1. Loading documents...")
        documents = load_documents(args=args)
        if not documents:
            error_result = {"status": "error", "message": "No documents loaded"}
            print(json.dumps(error_result))
            return

        logger.info("2. Cleaning documents...")
        cleaned_docs = clean_documents(documents)

        logger.info("3. Splitting documents...")
        chunks = split_text(cleaned_docs)

        logger.info("4. Saving to ChromaDB...")
        save_to_chroma(chunks)

        logger.info("5. Generating output...")
        context_dict = {
            f"chunk-{i+1:03d}": chunk.page_content
            for i, chunk in enumerate(chunks)
        }
        return save(context_dict, chunks)

    except Exception as e:
        error_result = {
            "status": "error",
            "message": str(e)
        }
        print(json.dumps(error_result))
        logger.exception("Pipeline failed")
        raise


if __name__ == "__main__":
    main()