from supabase import create_client
from backend.utils.config import Config

def get_supabase_client():
    """
    Create and return a Supabase client instance.
    """
    url = Config.SUPABASE_URL
    key = Config.SUPABASE_KEY
    
    if not url or not key:
        raise ValueError("Supabase URL and key must be set in the environment variables")
    
    return create_client(url, key)

def register_user(email, password, username, language_preference='en'):
    """
    Register a new user in Supabase.
    
    Args:
        email (str): User's email address
        password (str): User's password
        username (str): User's username
        language_preference (str): User's preferred language (en or hi)
        
    Returns:
        dict: User data if successful
        
    Raises:
        Exception: If registration fails
    """
    supabase = get_supabase_client()
    
    # First, register the user in auth
    user_response = supabase.auth.sign_up({
        "email": email,
        "password": password,
    })
    
    # If successful, store additional user data in profiles table
    if user_response.user:
        user_id = user_response.user.id
        
        # Insert into profiles table
        profile_data = {
            "id": user_id,
            "username": username,
            "language_preference": language_preference
        }
        
        supabase.table("profiles").insert(profile_data).execute()
        
    return user_response

def login_user(email, password):
    """
    Log in a user with Supabase.
    
    Args:
        email (str): User's email address
        password (str): User's password
        
    Returns:
        dict: User data if successful
        
    Raises:
        Exception: If login fails
    """
    supabase = get_supabase_client()
    
    return supabase.auth.sign_in_with_password({
        "email": email,
        "password": password
    })

def get_user_profile(user_id):
    """
    Get a user's profile data from Supabase.
    
    Args:
        user_id (str): The user's ID
        
    Returns:
        dict: User profile data
    """
    supabase = get_supabase_client()
    
    response = supabase.table("profiles").select("*").eq("id", user_id).execute()
    
    if response.data and len(response.data) > 0:
        return response.data[0]
    
    return None

def update_language_preference(user_id, language):
    """
    Update a user's language preference.
    
    Args:
        user_id (str): The user's ID
        language (str): The preferred language (en or hi)
        
    Returns:
        dict: Updated user data
    """
    supabase = get_supabase_client()
    
    response = supabase.table("profiles").update(
        {"language_preference": language}
    ).eq("id", user_id).execute()
    
    return response 