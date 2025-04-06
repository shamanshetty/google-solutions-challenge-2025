# ShetkarAI: Empowering Indian Farmers with AI (MVP Version)

ShetkarAI is an AI-powered mobile application designed to empower Indian smallholder farmers through accessible technology. This project aims to improve agricultural productivity, sustainability, and economic outcomes for farmers.

## About This MVP Version

This is a simplified MVP (Minimum Viable Product) version of ShetkarAI that demonstrates the app's core features and user interface without requiring actual machine learning models. This version is ideal for:

- Demonstrating the concept and user flows
- Testing the UI/UX with potential users
- Presenting to stakeholders and investors

The demo uses simulated predictions instead of actual ML models to avoid heavy dependencies while still showcasing the app's functionality.

## Features

- **Simulated crop monitoring and diagnosis** via image-based plant disease detection
- **Basic soil health analysis** through smartphone photos (simulated)
- **Weather-based recommendations** for farmers
- **Simple, voice-first multilingual interface** (supporting Hindi and English)
- **Offline functionality** for core features

## Project Structure

The project consists of two main components:

1. **Flutter Mobile App** - Cross-platform mobile application (Android/iOS)
2. **Python Backend** - RESTful API server with simulated ML capabilities

```
ShetkarAI/
├── backend/
│   ├── api/
│   ├── models/
│   ├── utils/
│   ├── static/
│   └── templates/
├── mobile/
│   └── shetkar_ai/
│       ├── lib/
│       │   ├── config/
│       │   ├── models/
│       │   ├── screens/
│       │   ├── services/
│       │   ├── utils/
│       │   ├── widgets/
│       │   └── main.dart
├── tests/
├── requirements.txt
├── app.py
└── README.md
```

## UN Sustainable Development Goals Alignment

ShetkarAI aligns with the following UN Sustainable Development Goals:

- **Goal 1: No Poverty** - Helping farmers increase productivity and income
- **Goal 2: Zero Hunger** - Improving crop yields and reducing losses due to disease
- **Goal 8: Decent Work and Economic Growth** - Creating economic opportunities for farmers
- **Goal 13: Climate Action** - Enabling climate-smart farming practices through recommendations

## Setup Instructions

### Backend Setup

1. Navigate to the project root directory:
   ```
   cd ShetkarAI
   ```

2. Create and activate a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Run the development server:
   ```
   python app.py
   ```

The server will start at http://localhost:5000

### Mobile App Setup

1. Make sure you have Flutter installed: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. Navigate to the mobile app directory:
   ```
   cd mobile/shetkar_ai
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Update the API endpoint in `lib/config/api_config.dart` to point to your backend server

5. Run the app:
   ```
   flutter run
   ```

## API Documentation

The backend exposes a RESTful API that the mobile app interacts with. When the server is running, you can access the API documentation by visiting:

```
http://localhost:5000/
```

Key endpoints include:
- `GET /api/health` - API health check
- `POST /api/detect-disease` - Plant disease detection (simulated)
- `POST /api/analyze-soil` - Soil analysis (simulated)
- `GET /api/weather` - Weather data and recommendations

## Technologies Used

### Backend
- Flask (Python web framework)
- NumPy (for simulated predictions)
- OpenCV (basic image handling)
- MongoDB (Data storage, future implementation)

### Mobile App
- Flutter (Cross-platform framework)
- Provider (State management)
- HTTP package (API communication)
- Image Picker (Camera and gallery integration)
- Geolocator (Location services)

## Moving Beyond the MVP

To evolve this MVP into a production-ready application with real AI capabilities:

1. Integrate actual ML models for disease detection and soil analysis
2. Add TensorFlow/PyTorch dependencies back to requirements.txt
3. Modify the model files to use actual model inference instead of simulations
4. Train models on relevant datasets for Indian agriculture

## Contributing

Contributions to ShetkarAI are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to all the farmers who provided feedback during the conception of this app
- Special thanks to all contributors to this open-source project