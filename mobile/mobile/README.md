# KisanSaathi

> Empowering Indian Farmers with AI

KisanSaathi is a mobile application designed to assist smallholder farmers in India with AI-powered tools for financial management, crop guidance, and agricultural resources.

## Branding Implementation Instructions

### 1. Logo and Assets

1. Add the KisanSaathi logo image to `/assets/images/logo.png` 
   - The logo should be high resolution (at least 1024x1024px) with transparent background
   - Use the provided logo from the design inspiration (1.jpg)

2. Add the required font files to `/assets/fonts/`:
   - Poppins: Regular, Medium, SemiBold, Bold
   - Roboto: Regular, Medium, Bold

### 2. Color Scheme

The KisanSaathi app uses an earthy color palette inspired by agriculture:

- **Primary Color (Brown)**: `#5E3B15`
- **Accent Color (Gold/Orange)**: `#E09F45`
- **Primary Green**: `#4A8A3B`
- **Secondary Green**: `#A0D06C`
- **Text Color (Dark Brown)**: `#3E2723`
- **Background Color (Cream)**: `#FFF8E1`
- **Card Color (Off-white)**: `#FFFBF0`

### 3. Brand Guidelines

- App Name: Always write as "KisanSaathi" (one word, capital K and S)
- Tagline: "Empowering Indian Farmers with AI"
- Typography: 
  - Headings: Poppins (Bold/SemiBold)
  - Body: Roboto (Regular)
  - Use appropriate font sizes for readability

### 4. Implementation Status

The following components have been updated to match the KisanSaathi branding:

- [x] App theme (colors, typography, component styles)
- [x] Splash screen
- [x] Wallet screen and transaction items
- [ ] Home screen
- [ ] Profile screen
- [ ] Settings screen
- [ ] Login/Registration screens
- [ ] Chat screens
- [ ] Market information screens
- [ ] Weather screens

### 5. Further Implementation Required

1. Replace all instances of the old app name "ShetkarAI" with "KisanSaathi" in:
   - UI text
   - Code comments
   - Resource IDs
   - File names (where applicable)

2. Update all screens to follow the new design language, including:
   - Component styling
   - Card layouts
   - Button styles
   - Form field designs

3. Package renaming:
   - Consider updating the package name from `shetkar_ai` to `kisan_saathi` in a future release

## Development Setup

### Prerequisites
- Flutter SDK (2.19.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Features

- Multi-language support (English and Hindi)
- Wallet management for tracking farm finances
- AI-powered chatbot for agricultural queries
- Weather forecasts and alerts
- Crop recommendations and management
- Market prices and trends
- Community support and resources

## License

[Specify license information]
