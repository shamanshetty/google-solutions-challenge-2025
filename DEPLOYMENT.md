# Deployment Guide

This application can be deployed in several ways. Here are detailed instructions for two popular options:

## Option 1: Render (Recommended for easy deployment)

1. Create a [Render](https://render.com/) account if you don't have one.

2. Connect your GitHub repository to Render:
   - From your Render dashboard, click "New" and select "Web Service"
   - Connect your GitHub repository
   - Select the repository containing this application

3. Configure the web service:
   - **Name**: Choose a name for your service (e.g., flask-agricultural-app)
   - **Environment**: Select "Python"
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app`

4. Add environment variables:
   - Click on the "Environment" tab
   - Add the following variables from your `.env` file:
     - `SECRET_KEY` (use a secure random string)
     - `SUPABASE_URL`
     - `SUPABASE_KEY`
     - Any other environment variables needed by your app

5. Click "Create Web Service" to deploy your application.

Render will automatically deploy your application and provide you with a URL to access it.

## Option 2: Heroku

1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

2. Log in to Heroku:
   ```
   heroku login
   ```

3. Create a new Heroku app:
   ```
   heroku create your-app-name
   ```

4. Set environment variables:
   ```
   heroku config:set SECRET_KEY=your_secret_key
   heroku config:set SUPABASE_URL=your_supabase_url
   heroku config:set SUPABASE_KEY=your_supabase_key
   ```
   Add any other environment variables your application needs.

5. Push your code to Heroku:
   ```
   git push heroku main
   ```

## Option 3: PythonAnywhere (Alternative)

1. Sign up for a [PythonAnywhere](https://www.pythonanywhere.com/) account

2. From your dashboard, create a new web app:
   - Select "Web" tab and click "Add a new web app"
   - Choose "Flask" and the Python version (3.9)
   - Set the path to your Flask app (usually `/home/yourusername/myapp/app.py`)

3. Upload your code:
   - Use the "Files" tab to upload your files or
   - Clone your Git repository: `git clone https://github.com/yourusername/your-repo.git`

4. Set up a virtual environment and install dependencies:
   ```
   mkvirtualenv --python=/usr/bin/python3.9 myenv
   pip install -r requirements.txt
   ```

5. Configure environment variables through the web interface

6. Reload your web app

## Important Notes for Any Deployment

1. Make sure all environment variables in `.env.example` are set in your deployment platform.
2. Ensure `DEBUG` is set to `False` in production.
3. Use a strong, random `SECRET_KEY` in production.
4. Set up proper database configurations for production if you're using one. 