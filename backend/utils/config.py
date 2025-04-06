import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Configuration settings for the application"""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    SUPABASE_URL = os.environ.get('SUPABASE_URL', '')
    SUPABASE_KEY = os.environ.get('SUPABASE_KEY', '')
    DEBUG = os.environ.get('DEBUG', 'False').lower() == 'true'
    
    # Add other configuration variables as needed
    UPLOAD_FOLDER = os.path.join('backend', 'static', 'uploads')
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
    
    # Database settings (for future implementation)
    DB_URI = os.environ.get('DB_URI', 'mongodb://localhost:27017/shetkar_ai')
    
    # ML Model settings
    MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'models')
    
    # Supported languages
    SUPPORTED_LANGUAGES = ['en', 'hi']
    DEFAULT_LANGUAGE = 'en'
    
    # Weather API settings
    WEATHER_API_KEY = os.environ.get('WEATHER_API_KEY', '')
    WEATHER_API_URL = 'https://api.openweathermap.org/data/2.5/weather' 