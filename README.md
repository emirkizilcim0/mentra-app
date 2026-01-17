# Mentra – AI-Powered Mental Health & Diary Application


![Logo](/App/assets/logo.png)

Mentra is a modern **mental health journaling application** that helps users understand their emotional well-being through **daily diary entries, mood tracking, and AI-powered psychological insights**.  
By combining mobile technologies, cloud-based backend services, and large language models (LLMs), Mentra provides a **safe, private, and intelligent space for self-reflection and emotional growth**.

---

## 🌟 Motivation

Many people struggle with overthinking, emotional overload, and loneliness, especially during quiet moments. Access to professional mental health support is often limited, expensive, or intimidating.

**Mentra bridges the gap** between traditional diary writing and intelligent mental health assistance by:

- Letting users freely express their thoughts
    
- Analyzing emotional patterns using AI
    
- Offering empathetic, human-like psychological feedback
    
- Visualizing long-term mood trends
    

> _You are not alone. Mentra listens._

---

## 🎯 Project Objectives

- Provide a **secure digital diary** platform
    
- Enable **daily, weekly, and monthly mood tracking**
    
- Analyze diary entries using **AI-powered emotion detection**
    
- Generate **personalized psychological advice**
    
- Maintain a **scalable, modular, and production-ready architecture**
    
- Ensure **privacy-first mental health data handling**
    

---

## 🏗️ System Architecture

Mentra follows a **modern client–server architecture** with clear separation of concerns.

### High-Level Architecture

- **Frontend:** Flutter (Android & iOS)
    
- **Backend:** FastAPI (Python)
    
- **Authentication:** Firebase Authentication
    
- **Database:** PostgreSQL (Render-hosted)
    
- **AI Engine:** Google Gemini (LLM)
    

All components communicate through **secure RESTful APIs**, ensuring maintainability and scalability.

---

## 📱 Frontend (Flutter)

### Technologies

- Flutter & Dart
    
- Provider-based State Management
    
- REST API integration
    
- Material UI components
    

### Architecture Pattern

- **UI Layer:** Screens & widgets
    
- **State Layer:** Providers
    
- **Repository Layer:** API & data handling
    
- **Service Layer:** Authentication & configuration
    

### Key Features

- Firebase-based user authentication
    
- Diary creation, editing, and deletion
    
- Mood trend visualization (daily, weekly, monthly)
    
- AI analysis result display
    
- Secure API communication
    

---

## ⚙️ Backend (FastAPI)

### Why FastAPI?

- High performance with async support
    
- Automatic OpenAPI documentation
    
- Strong typing with Pydantic
    
- Clean RESTful API design
    

### Backend Responsibilities

- Handle authenticated API requests
    
- Manage diary CRUD operations
    
- Store and retrieve diary data
    
- Communicate with the AI analysis service
    
- Enforce data validation and integrity
    

### Core API Endpoints

```http
POST   /diaries        # Create diary entry
GET    /diaries        # Retrieve user diaries
DELETE /diaries/{id}  # Delete diary entry
POST   /analyze        # AI-based diary analysis
GET    /health        # Health check
```

All endpoints are **user-scoped** and linked to Firebase User IDs.

---

## 🔐 Authentication (Firebase)

Mentra uses **Firebase Authentication** for secure user management.

### Authentication Flow

1. User signs in via the Flutter app
    
2. Firebase issues a unique **UID**
    
3. UID is sent with each backend request
    
4. Backend links diaries to this UID
    

### Benefits

- No password handling on backend
    
- Strong security guarantees
    
- Easy scalability
    

---

## 🗄️ Database (PostgreSQL)

### Why PostgreSQL?

- Strong relational integrity
    
- JSON support
    
- High scalability
    
- Reliable cloud hosting (Render)
    

### Core Table: `diaries`

|Field|Description|
|---|---|
|`id`|Primary key|
|`user_id`|Firebase UID|
|`content`|Diary text|
|`mood`|Detected or user-provided mood|
|`tags`|Optional labels|
|`created_at`|Timestamp|

Each diary entry is **strictly isolated per user**.

---

## 🤖 AI-Powered Psychological Analysis

Mentra uses **Google Gemini** for advanced psychological insight generation.

### Capabilities

- Emotional tone detection (sadness, anxiety, anger, happiness, etc.)
    
- Empathetic psychological feedback
    
- Constructive, supportive advice
    
- Pattern recognition across multiple diary entries
    

### Analysis Modes

- **Single-entry analysis:** Immediate feedback
    
- **Multi-entry analysis:** Long-term emotional pattern detection
    

---

## 📊 Mood Tracking & Visualization

Mentra aggregates emotional data to generate:

- Daily mood trends
    
- Weekly emotional patterns
    
- Monthly mental health summaries
    

These insights help users:

- Recognize emotional cycles
    
- Identify long-term patterns
    
- Build emotional awareness
    

---

## 🔒 Security & Privacy

Mental health data is treated as **highly sensitive**.

- Firebase handles authentication securely
    
- Backend never stores passwords
    
- Data is isolated per user UID
    
- HTTPS-based API communication
    
- No diary data is shared between users
    

---

## 🚀 Deployment & Infrastructure

- **Backend:** Render (FastAPI service)
    
- **Database:** Render PostgreSQL
    
- **Frontend:** Android & iOS (Flutter)
    
- **Environment Management:**
    
    - Environment variables for secrets
        
    - Separate development and production configs
        

---

## 🧪 Stress Testing Summary

Mentra was stress-tested under increasing concurrency levels (up to **500 concurrent users** and **124,000+ requests**).

### Results

- Stable performance under light and heavy load
    
- Near-zero error rates (≤ 0.01%)
    
- Graceful performance degradation under high concurrency
    
- Reliable database integrity during write-heavy operations
    

These results confirm Mentra is **production-ready within free-tier constraints**.

---

## 🔮 Future Improvements

- 🎙️ Voice diary input
    
- 🎧 Emotion detection from audio
    
- 🔔 Push notifications for mental check-ins
    
- 🧑‍⚕️ Therapist-mode dashboards
    
- 📡 Offline diary support
    

---

## 🧾 Project Information

**Project Name:** Mentra  
**Domain:** Mental Health, AI, Mobile Applications

### Technologies

- Flutter, Dart
    
- FastAPI (Python)
    
- Firebase Authentication
    
- PostgreSQL
    
- Google Gemini (LLM)
    

### Team Members

- **Aysu Mutlu**
    
- **Anıl Aydın**
    
- **Emir Kızılçim**
    

---

## 🌐 Links & Contact

📧 Email: **[mentra83@gmail.com](mailto:mentra83@gmail.com)**  
🌍 Website: [https://mentra-ma.github.io/](https://mentra-ma.github.io/)

---

> **Mentra** is not just an application — it is a companion for self-discovery, emotional clarity, and mental well-being. 💙
