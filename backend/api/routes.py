from flask import Blueprint, request, jsonify, session
import os
import json
from backend.utils.helpers import (
    save_uploaded_file, 
    preprocess_image, 
    get_weather_data,
    generate_weather_recommendations
)
from backend.models.disease_detection import predict_disease
from backend.models.soil_analysis import analyze_soil
from backend.utils.config import Config

# Create a Blueprint for the API routes
api_bp = Blueprint('api', __name__)

@api_bp.route('/health', methods=['GET'])
def health_check():
    """API health check endpoint"""
    return jsonify({"status": "ok", "message": "ShetkarAI API is running"}), 200

@api_bp.route('/detect-disease', methods=['POST'])
def detect_disease():
    """Endpoint for plant disease detection"""
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    file = request.files['image']
    # Get language from form or session
    language = request.form.get('language', session.get('language', 'en'))
    
    # Save the uploaded file
    image_path = save_uploaded_file(file)
    if not image_path:
        return jsonify({"error": "Invalid file format"}), 400
    
    # Preprocess the image
    processed_image = preprocess_image(image_path)
    if processed_image is None:
        return jsonify({"error": "Failed to process image"}), 500
    
    # Get the prediction
    try:
        result = predict_disease(processed_image, language)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@api_bp.route('/analyze-soil', methods=['POST'])
def soil_analysis():
    """Endpoint for soil analysis"""
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    file = request.files['image']
    # Get language from form or session
    language = request.form.get('language', session.get('language', 'en'))
    
    # Save the uploaded file
    image_path = save_uploaded_file(file)
    if not image_path:
        return jsonify({"error": "Invalid file format"}), 400
    
    # Preprocess the image
    processed_image = preprocess_image(image_path)
    if processed_image is None:
        return jsonify({"error": "Failed to process image"}), 500
    
    # Get the soil analysis
    try:
        result = analyze_soil(processed_image, language)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@api_bp.route('/weather', methods=['GET'])
def weather():
    """Endpoint for weather data and recommendations"""
    try:
        lat = request.args.get('lat')
        lon = request.args.get('lon')
        # Get language from query parameters or session
        language = request.args.get('language', session.get('language', 'en'))
        
        if not lat or not lon:
            return jsonify({"error": "Latitude and longitude parameters are required"}), 400
        
        weather_data = get_weather_data(lat, lon)
        if not weather_data:
            return jsonify({"error": "Failed to fetch weather data"}), 500
        
        recommendations = generate_weather_recommendations(weather_data, language)
        
        result = {
            "weather": weather_data,
            "recommendations": recommendations
        }
        
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500 