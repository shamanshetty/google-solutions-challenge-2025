"""
Translations utility for multi-language support in ShetkarAI.
Supports English (en) and Hindi (hi).
"""

# Dictionary of translations for the application
TRANSLATIONS = {
    # Language selection page
    "language_select_title": {
        "en": "Select Your Language",
        "hi": "अपनी भाषा चुनें"
    },
    "language_select_subtitle": {
        "en": "Choose your preferred language to use ShetkarAI",
        "hi": "ShetkarAI का उपयोग करने के लिए अपनी पसंदीदा भाषा चुनें"
    },
    "english": {
        "en": "English",
        "hi": "अंग्रेज़ी"
    },
    "hindi": {
        "en": "Hindi",
        "hi": "हिंदी"
    },
    "continue": {
        "en": "Continue",
        "hi": "जारी रखें"
    },
    
    # Login/Register Page
    "login_title": {
        "en": "Login to ShetkarAI",
        "hi": "ShetkarAI में लॉगिन करें"
    },
    "register_title": {
        "en": "Register for ShetkarAI",
        "hi": "ShetkarAI के लिए पंजीकरण करें"
    },
    "email": {
        "en": "Email",
        "hi": "ईमेल"
    },
    "password": {
        "en": "Password",
        "hi": "पासवर्ड"
    },
    "username": {
        "en": "Username",
        "hi": "उपयोगकर्ता नाम"
    },
    "login_button": {
        "en": "Login",
        "hi": "लॉगिन"
    },
    "register_button": {
        "en": "Register",
        "hi": "पंजीकरण करें"
    },
    "no_account": {
        "en": "Don't have an account?",
        "hi": "खाता नहीं है?"
    },
    "have_account": {
        "en": "Already have an account?",
        "hi": "पहले से ही एक खाता है?"
    },
    "register_link": {
        "en": "Register here",
        "hi": "यहां पंजीकरण करें"
    },
    "login_link": {
        "en": "Login here",
        "hi": "यहां लॉगिन करें"
    },
    
    # Main application
    "app_title": {
        "en": "ShetkarAI - AI for Indian Farmers",
        "hi": "ShetkarAI - भारतीय किसानों के लिए AI"
    },
    "welcome": {
        "en": "Welcome",
        "hi": "स्वागत है"
    },
    "detect_disease": {
        "en": "Detect Plant Disease",
        "hi": "पौधों के रोग का पता लगाएं"
    },
    "detect_disease_desc": {
        "en": "Upload a photo of your plant to identify diseases and get treatment recommendations.",
        "hi": "रोगों की पहचान करने और उपचार सुझाव प्राप्त करने के लिए अपने पौधे की एक तस्वीर अपलोड करें।"
    },
    "analyze_soil": {
        "en": "Analyze Soil",
        "hi": "मिट्टी का विश्लेषण करें"
    },
    "analyze_soil_desc": {
        "en": "Upload a photo of your soil to determine its type and properties for better crop selection.",
        "hi": "बेहतर फसल चयन के लिए अपनी मिट्टी के प्रकार और गुणों का निर्धारण करने के लिए अपनी मिट्टी की एक तस्वीर अपलोड करें।"
    },
    "weather": {
        "en": "Get Weather Recommendations",
        "hi": "मौसम की सिफारिशें प्राप्त करें"
    },
    "weather_desc": {
        "en": "Get weather forecasts and farming recommendations based on your location.",
        "hi": "अपने स्थान के आधार पर मौसम की भविष्यवाणी और कृषि सिफारिशें प्राप्त करें।"
    },
    "logout": {
        "en": "Logout",
        "hi": "लॉग आउट"
    },
    
    # Error messages
    "error_login": {
        "en": "Login failed. Please check your email and password.",
        "hi": "लॉगिन विफल। कृपया अपना ईमेल और पासवर्ड जांचें।"
    },
    "error_register": {
        "en": "Registration failed. Please try again.",
        "hi": "पंजीकरण विफल। कृपया पुन: प्रयास करें।"
    },
    "error_email_exists": {
        "en": "Email already exists. Please login or use a different email.",
        "hi": "ईमेल पहले से मौजूद है। कृपया लॉगिन करें या अलग ईमेल का उपयोग करें।"
    }
}

def get_text(key, language="en"):
    """
    Get the translated text for a given key and language.
    
    Args:
        key (str): The key to look up in the translations dictionary.
        language (str): The language code (en or hi). Defaults to English.
        
    Returns:
        str: The translated text or the key itself if not found.
    """
    if key not in TRANSLATIONS:
        return key
    
    if language not in TRANSLATIONS[key]:
        return TRANSLATIONS[key]["en"]  # Fallback to English
    
    return TRANSLATIONS[key][language] 