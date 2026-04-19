# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CropDoc** - Hyper-Local AI Crop Disease Advisor (Flutter mobile app + Express.js backend)

- **Flutter app** (`lib/`): On-device TFLite disease detection, treatment recommendations, farm activity logging, community alerts
- **Backend** (`backend/`): Express.js API with Supabase integration for community features, weather, shops
- **ML model** (`modelStuff/`): EfficientNet-B0 training pipeline for plant disease classification

## Quick Commands

```bash
# Flutter app
flutter run                    # Run on device
flutter build apk              # Build Android APK
flutter test                   # Run tests

# Backend (Node.js 18+)
cd backend
npm install                    # Install dependencies
npm run dev                    # Start dev server (nodemon)
npm run seed                   # Seed database
npm start                      # Production start

# ML model training (Python 3.8+)
cd modelStuff
pip install -r requirements.txt
python scripts/03_train.py     # Train EfficientNet-B0
python scripts/05_export_tflite.py  # Export to TFLite
```

## Architecture

### Flutter App Structure

```
lib/
├── main.dart              # App entry, tab shell, language picker
├── config/
│   ├── theme.dart         # CropDocColors, light theme
│   ├── routes.dart        # Named route constants
│   └── app_language.dart  # i18n (EN/HI/MR/TE/TA), translation map
├── models/
│   ├── treatment.dart     # TreatmentStep, Product, Shop
│   ├── calendar_event.dart# Spray schedule events
│   ├── farm_log.dart      # User activity records
│   ├── scan_record.dart   # Scan history entries
│   └── disease.dart       # Disease metadata
├── services/
│   ├── model_service.dart # TFLite inference (assets/model/*.tflite)
│   ├── farm_log_service.dart# In-memory farm logs
│   └── scan_history_service.dart # Scan persistence
├── screens/
│   ├── home_screen.dart   # Scan + farm log card
│   ├── scan_result_screen.dart  # Disease details, confidence
│   ├── treatment_screen.dart    # Steps, products, calendar
│   ├── history_screen.dart      # Crop timeline, stats
│   └── community_screen.dart    # Disease reports, map
└── widgets/
    ├── treatment/         # spray_calendar.dart, step_card.dart, shop_card.dart
    ├── scan/              # scan_button.dart, overlay, confidence_meter
    ├── history/           # crop_timeline.dart, stat_card.dart
    ├── community/         # alert_card.dart, disease_map.dart
    └── common/            # weather_banner.dart, connectivity_banner.dart
```

### Key Patterns

- **State management**: `InheritedWidget` (LanguageScope) for i18n, `ChangeNotifier` for services
- **Offline-first**: TFLite model runs on-device; community features sync when online
- **Language**: 5 languages (English, Hindi, Marathi, Telugu, Tamil) via `t(context, key)` helper
- **Treatment database**: Disease name → treatment steps, products, spray calendar (`TreatmentDatabase.getSteps()`)

### Backend API

```
backend/
├── index.js               # Express app, rate limiting, CORS, Helmet
├── config/supabase.js     # Supabase client setup
├── middleware/
│   ├── errorHandler.js    # Global error handler
│   └── validate.js        # Request validation
├── routes/
│   ├── auth.js            # User registration, profile
│   ├── diseases.js        # Disease lookup
│   ├── treatments.js      # Treatment plans, schedules
│   ├── scans.js           # Scan CRUD
│   ├── community.js       # Alerts, trends
│   ├── weather.js         # Weather data
│   └── shops.js           # Product shops
└── seed/seed.js           # Database seeding
```

API runs on `PORT=3000`. Rate limit: 100 req/15min per IP.

### ML Pipeline

```
modelStuff/
├── scripts/
│   ├── 01_clean_dataset.py    # Remove corrupted/tiny images
│   ├── 02_split_dataset.py    # 70/20/10 train/val/test
│   ├── 03_train.py            # 2-phase transfer learning
│   ├── 04_evaluate.py         # Test metrics, confusion matrix
│   ├── 05_export_tflite.py    # Float16 TFLite export
│   └── 06_test_tflite.py      # Verify .tflite inference
└── README.md                  # Detailed training guide
```

**Output**: `models/model.tflite` (~15-20MB), `models/class_names.json`

## Data Flow

1. **Scan**: User captures leaf → TFLite inference → `ModelPrediction` (crop, disease, confidence)
2. **Treatment**: Disease name → `TreatmentDatabase.getSteps()` → actionable steps + product shops
3. **Calendar**: Disease + crop history → spray schedule (`CalendarEvent[]`) with harvest windows
4. **Community**: Disease reports → geospatial alerts → nearby farmers notified

## Key Files to Know

- `lib/services/model_service.dart`: TFLite config (input size 224, raw pixel preprocessing)
- `lib/data/treatment_database.dart`: 30+ disease treatments, product recommendations
- `lib/config/app_language.dart`: 150+ translation keys across 5 languages
- `backend/index.js`: API endpoint registry, middleware stack

## Model Assets

App expects these in `assets/model/`:
- `plant_disease.tflite` - TFLite model
- `labels.txt` - 38 class labels (format: `Crop___Disease`)

Fallback: Demo predictions if model not found.
