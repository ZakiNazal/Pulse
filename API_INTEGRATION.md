# SportSync - API Integration Guide

## Overview
SportSync supports both mock data and real API integration. The app is designed to easily switch between mock services for development and real APIs for production.

## API Configuration

### 1. Add Your API Keys
Edit `lib/core/config/api_config.dart` and add your actual API keys:

```dart
class ApiConfig {
  // Add your API keys here
  static const String footballApiKey = 'YOUR_FOOTBALL_API_KEY';
  static const String basketballApiKey = 'YOUR_BASKETBALL_API_KEY';
  static const String tennisApiKey = 'YOUR_TENNIS_API_KEY';
  static const String cricketApiKey = 'YOUR_CRICKET_API_KEY';
  static const String esportsApiKey = 'YOUR_ESPORTS_API_KEY';
  
  // Enable real API calls
  static const bool useRealApi = true;
}
```

### 2. Supported APIs
- **Football**: API-Football, Football-Data.org
- **Basketball**: NBA API, ESPN API
- **Tennis**: Tennis-Data.org
- **Cricket**: CricAPI
- **Esports**: PandaScore, Riot Games

### 3. Real Service Implementation
The app includes `RealFootballService` as an example implementation. Similar services can be created for other sports following the same pattern.

## Navigation

### Fixed Bottom Navigation
The app now uses a shared `FixedBottomNavBar` component that provides consistent navigation across all screens. The navigation bar:

- Shows on all main screens (Home, Explore, Search, Favorites, Profile)
- Hidden on splash, auth, and match detail screens
- Automatically highlights the current route
- Uses glassmorphism design with smooth animations

### Screens Without Bottom Navigation
- `/splash` - Splash screen
- `/auth` - Authentication screen  
- `/match/:id` - Match details screen

## Usage

### Development (Mock Data)
Set `useRealApi = false` in `ApiConfig` to use mock data for development.

### Production (Real APIs)
Set `useRealApi = true` and add your API keys to use real sports data.

## Architecture

The app follows a clean architecture:
- **UI Layer**: Features (home, explore, etc.)
- **Provider Layer**: Riverpod state management
- **Service Layer**: API services (mock/real)
- **Model Layer**: Data models (Match, League, Team)

All API calls are abstracted through the `ApiService` interface, making it easy to swap implementations.
