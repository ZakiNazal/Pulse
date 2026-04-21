import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Real HTTP implementation of [ApiService] for Formula 1.
///
/// This class integrates with Ergast F1 API to provide real F1 data.
class RealF1Service implements ApiService {
  late final Dio _dio;

  RealF1Service() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.f1BaseUrl,
      connectTimeout: ApiConfig.requestTimeout,
      receiveTimeout: ApiConfig.requestTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  // ── ApiService Implementation ───────────────────────────────────────

  @override
  Future<List<Match>> getLiveMatches() async {
    try {
      // F1 doesn't have "live" matches in the same way, but we can get current session
      final response = await _dio.get('/current.json');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> getUpcomingMatches({DateTime? date}) async {
    try {
      final dateString = date != null 
          ? '${date.year}/${date.month.toString().padLeft(2, '0')}'
          : 'current';
      final response = await _dio.get('/$dateString.json');
      return _parseMatches(response.data)
          .where((match) => match.isUpcoming)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> getFinishedMatches({DateTime? date}) async {
    try {
      final dateString = date != null 
          ? '${date.year}/${date.month.toString().padLeft(2, '0')}'
          : 'current';
      final response = await _dio.get('/$dateString.json');
      return _parseMatches(response.data)
          .where((match) => match.isFinished)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Match?> getMatchDetails(String matchId) async {
    try {
      final response = await _dio.get('/current/$matchId/results.json');
      return _parseMatch(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> searchMatches(String query) async {
    try {
      // F1 API doesn't have search, so we return current season races
      final response = await _dio.get('/current.json');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<League>> getPopularLeagues() async {
    try {
      final response = await _dio.get('/current/constructorStandings.json');
      return _parseLeagues(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Helper Methods ───────────────────────────────────────────────────

  List<Match> _parseMatches(dynamic data) {
    if (data is! Map) return [];
    
    final racesData = data['MRData']?['RaceTable']?['Races'] as List? ?? [];
    return racesData.map((race) => _parseMatch(race)).whereType<Match>().toList();
  }

  Match? _parseMatch(dynamic data) {
    try {
      if (data is! Map) return null;
      
      final raceData = data as Map<String, dynamic>;
      
      // Parse teams (constructors)
      final homeTeam = Team(
        id: raceData['Circuit']?['circuitId'] ?? '',
        name: raceData['Circuit']?['circuitName'] ?? 'Unknown Circuit',
        logo: '',
        shortName: raceData['Circuit']?['Location']?['locality'] ?? '',
      );
      
      final awayTeam = Team(
        id: 'f1-season',
        name: 'F1 Season ${raceData['season'] ?? ''}',
        logo: '',
        shortName: 'F1',
      );

      // Parse match status
      final dateStr = raceData['date'] ?? '';
      final timeStr = raceData['time'] ?? '';
      final raceDateTime = DateTime.tryParse('$dateStr${timeStr.isNotEmpty ? 'T$timeStr' : ''}');
      
      final status = _parseMatchStatus(raceDateTime);

      // Parse scores (positions)
      final results = raceData['Results'] as List? ?? [];
      String? homeScore, awayScore;
      
      if (results.isNotEmpty) {
        // For F1, we'll use the winner's position as "score"
        final winner = results.first;
        homeScore = 'P${winner['position'] ?? '1'}';
        awayScore = results.length.toString();
      }

      // Parse league
      final league = League(
        id: raceData['season']?.toString() ?? '',
        name: 'Formula 1 ${raceData['season'] ?? ''}',
        logo: '',
        country: raceData['Circuit']?['Location']?['country'] ?? '',
        sportType: SportType.f1,
      );

      return Match(
        id: raceData['raceName']?.toString() ?? '',
        sportType: SportType.f1,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: int.tryParse(homeScore ?? '0'),
        awayScore: int.tryParse(awayScore ?? '0'),
        status: status,
        startTime: raceDateTime ?? DateTime.now(),
        venue: raceData['Circuit']?['circuitName'],
      );
    } catch (e) {
      debugPrint('Error parsing F1 match: $e');
      return null;
    }
  }

  MatchStatus _parseMatchStatus(DateTime? raceDateTime) {
    if (raceDateTime == null) return MatchStatus.upcoming;
    
    final now = DateTime.now();
    final raceEnd = raceDateTime.add(const Duration(hours: 3)); // F1 races typically last ~3 hours
    
    if (now.isBefore(raceDateTime)) {
      return MatchStatus.upcoming;
    } else if (now.isAfter(raceDateTime) && now.isBefore(raceEnd)) {
      return MatchStatus.live;
    } else {
      return MatchStatus.finished;
    }
  }

  List<League> _parseLeagues(dynamic data) {
    if (data is! Map) return [];
    
    final standingsData = data['MRData']?['StandingsTable']?['StandingsLists'] as List? ?? [];
    if (standingsData.isEmpty) return [];
    
    final constructors = standingsData.first['ConstructorStandings'] as List? ?? [];
    
    return constructors.map((standing) {
      if (standing is! Map) return null;
      
      final constructor = standing['Constructor'] as Map? ?? {};
      
      return League(
        id: constructor['constructorId']?.toString() ?? '',
        name: constructor['name'] ?? 'Unknown',
        logo: '',
        country: constructor['nationality'] ?? '',
        sportType: SportType.f1,
      );
    }).whereType<League>().toList();
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Request timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        return Exception('API error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
