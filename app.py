from flask import Flask, request, jsonify, render_template, redirect, url_for, session, flash
from flask_cors import CORS
import os
from backend.api.routes import api_bp
from backend.utils.config import Config
from backend.utils.translations import get_text
from backend.utils.supabase import register_user, login_user, get_user_profile, update_language_preference


app = Flask(__name__, 
            static_folder='backend/static',
            template_folder='backend/templates')

app.config.from_object(Config)
# Set secret key for session management
app.secret_key = Config.SECRET_KEY
CORS(app)

# Register blueprints
app.register_blueprint(api_bp, url_prefix='/api')

@app.route('/')
def index():
    """Redirect to language selection or dashboard based on session"""
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    
    if 'language' in session:
        return redirect(url_for('login_page'))
    
    return redirect(url_for('language_select'))

@app.route('/language', methods=['GET'])
def language_select():
    """Show language selection page"""
    # Default to English for the language selection page
    translations = {
        'language_select_title': get_text('language_select_title', 'en'),
        'language_select_subtitle': get_text('language_select_subtitle', 'en'),
        'english': get_text('english', 'en'),
        'hindi': get_text('hindi', 'en'),
        'continue': get_text('continue', 'en')
    }
    
    return render_template('language_select.html', translations=translations)

@app.route('/set-language', methods=['POST'])
def set_language():
    """Set the selected language"""
    language = request.form.get('language', 'en')
    session['language'] = language
    
    if 'user_id' in session:
        # Update user's preference in database if logged in
        update_language_preference(session['user_id'], language)
    
    return redirect(url_for('login_page'))

@app.route('/login', methods=['GET'])
def login_page():
    """Show login page"""
    language = session.get('language', 'en')
    
    translations = {
        'login_title': get_text('login_title', language),
        'register_title': get_text('register_title', language),
        'email': get_text('email', language),
        'password': get_text('password', language),
        'username': get_text('username', language),
        'login_button': get_text('login_button', language),
        'register_button': get_text('register_button', language),
        'no_account': get_text('no_account', language),
        'have_account': get_text('have_account', language),
        'register_link': get_text('register_link', language),
        'login_link': get_text('login_link', language),
        'language_select_title': get_text('language_select_title', language)
    }
    
    error = session.pop('error', None)
    register_error = session.pop('register_error', None)
    
    return render_template('login.html', translations=translations, 
                          language=language, error=error, 
                          register_error=register_error)

@app.route('/login', methods=['POST'])
def login():
    """Process login form"""
    email = request.form.get('email')
    password = request.form.get('password')
    language = session.get('language', 'en')
    
    try:
        response = login_user(email, password)
        
        if response.user:
            # Store user info in session
            session['user_id'] = response.user.id
            
            # Get user profile for additional info
            profile = get_user_profile(response.user.id)
            if profile:
                session['username'] = profile.get('username', email.split('@')[0])
                # Update language preference from profile if available
                if profile.get('language_preference'):
                    session['language'] = profile.get('language_preference')
            else:
                session['username'] = email.split('@')[0]
            
            return redirect(url_for('dashboard'))
        else:
            session['error'] = get_text('error_login', language)
            return redirect(url_for('login_page'))
    except Exception as e:
        session['error'] = str(e)
        return redirect(url_for('login_page'))

@app.route('/register', methods=['POST'])
def register():
    """Process registration form"""
    email = request.form.get('email')
    password = request.form.get('password')
    username = request.form.get('username')
    language = session.get('language', 'en')
    
    try:
        response = register_user(email, password, username, language_preference=language)
        
        if response.user:
            # Automatically log the user in
            session['user_id'] = response.user.id
            session['username'] = username
            
            return redirect(url_for('dashboard'))
        else:
            session['register_error'] = get_text('error_register', language)
            return redirect(url_for('login_page'))
    except Exception as e:
        session['register_error'] = str(e)
        return redirect(url_for('login_page'))

@app.route('/dashboard')
def dashboard():
    """Show dashboard page"""
    # Check if user is logged in
    if 'user_id' not in session:
        return redirect(url_for('login_page'))
    
    language = session.get('language', 'en')
    username = session.get('username', 'User')
    
    # Get translations for dashboard
    translations = {
        'app_title': get_text('app_title', language),
        'welcome': get_text('welcome', language),
        'detect_disease': get_text('detect_disease', language),
        'detect_disease_desc': get_text('detect_disease_desc', language),
        'analyze_soil': get_text('analyze_soil', language),
        'analyze_soil_desc': get_text('analyze_soil_desc', language),
        'weather': get_text('weather', language),
        'weather_desc': get_text('weather_desc', language),
        'logout': get_text('logout', language),
        'english': get_text('english', language),
        'hindi': get_text('hindi', language)
    }
    
    return render_template('dashboard.html', translations=translations, 
                          language=language, username=username)

@app.route('/change-language', methods=['POST'])
def change_language():
    """Change language preference"""
    language = request.form.get('language', 'en')
    session['language'] = language
    
    if 'user_id' in session:
        # Update user's preference in database
        update_language_preference(session['user_id'], language)
    
    return redirect(url_for('dashboard'))

@app.route('/logout', methods=['POST'])
def logout():
    """Log out user"""
    # Keep language preference
    language = session.get('language', 'en')
    
    # Clear session
    session.clear()
    
    # Restore language preference
    session['language'] = language
    
    return redirect(url_for('login_page'))

# Additional routes for the features
@app.route('/detect-disease')
def detect_disease_page():
    if 'user_id' not in session:
        return redirect(url_for('login_page'))
    # Implementation for disease detection page would go here
    return "Disease Detection Page (To be implemented)"

@app.route('/analyze-soil')
def analyze_soil_page():
    if 'user_id' not in session:
        return redirect(url_for('login_page'))
    # Implementation for soil analysis page would go here
    return "Soil Analysis Page (To be implemented)"

@app.route('/weather')
def weather_page():
    if 'user_id' not in session:
        return redirect(url_for('login_page'))
    # Implementation for weather page would go here
    return "Weather Page (To be implemented)"

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=True) 
