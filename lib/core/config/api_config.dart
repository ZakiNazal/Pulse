/// Configuration file for API keys and endpoints.
///
/// Add your actual API keys here for real sports data integration.
/// This file is not tracked by git (add to .gitignore if needed).
class ApiConfig {
  // ── API Keys ────────────────────────────────────────────────────────
  // Add your API keys here
  
  /// Football API key (API-Football)
  static const String footballApiKey = 'c717106cf185743d9cf2c6b78d81091d';
  
  /// Basketball API key (NBA API)
  static const String basketballApiKey = 'c717106cf185743d9cf2c6b78d81091d';
  
  /// F1 API key (F1 API)
  static const String f1ApiKey = 'c717106cf185743d9cf2c6b78d81091d';
  
  /// MMA API key (MMA-Data.org)
  static const String mmaApiKey = 'c717106cf185743d9cf2c6b78d81091d';

  // ── Base URLs ──────────────────────────────────────────────────────
  /// Base URL for football API (API-Football)
  static const String footballBaseUrl = 'https://v3.football.api-sports.io';
  
  /// Base URL for basketball API
  static const String basketballBaseUrl = 'https://v1.basketball.api-sports.io';
  
  /// Base URL for F1 API
  static const String f1BaseUrl = 'https://v1.formula-1.api-sports.io';
  
  /// Base URL for MMA API
  static const String mmaBaseUrl = 'https://v1.mma.api-sports.io';

  // ── Configuration ────────────────────────────────────────────────────
  /// Enable/disable real API calls (set to false for mock data)
  static const bool useRealApi = false;
  
  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Number of retry attempts for failed requests
  static const int maxRetries = 3;
}
