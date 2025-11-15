from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

# Allow Flutter to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this later to your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def home():
    return {"message": "Backend is running!"}

# Define expected POST body using Pydantic model
class AnalyzeRequest(BaseModel):
    name: str = "Unknown"

@app.post("/analyze")
async def analyze(data: AnalyzeRequest):
    name = data.name
    score = len(name) * 7  # same test calculation
    return {
        "message": f"Hello {name}, your analysis score is {score}",
        "status": "success"
    }


"""
This is a simple FastAPI backend that listens for POST requests at the /analyze endpoint.
Uvicorn is ASGI server, can handle thousands of requests concurrently.
Need to run this command for the server to start:

uvicorn main:app --host 0.0.0.0 --port 5000

We should write this instead of hardcoding part 5000 because of render.com:

uvicorn main:app --host 0.0.0.0 --port $PORT


"""