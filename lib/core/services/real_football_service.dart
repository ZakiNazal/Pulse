import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Real HTTP implementation of [ApiService] for football.
///
/// This class demonstrates how to integrate with a real sports API.
/// Replace the mock implementation in [MatchService] with this class
/// to use real data.
class RealFootballService implements ApiService {
  late final Dio _dio;

  RealFootballService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.footballBaseUrl,
      connectTimeout: ApiConfig.requestTimeout,
      receiveTimeout: ApiConfig.requestTimeout,
      headers: {
        'apikey': ApiConfig.footballApiKey,
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
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
      final response = await _dio.get('/fixtures?live=all');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> getUpcomingMatches({DateTime? date}) async {
    try {
      final dateString = date != null 
          ? date.toIso8601String().split('T')[0]
          : 'today';
      final response = await _dio.get('/fixtures?date=$dateString&status=NS');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> getFinishedMatches({DateTime? date}) async {
    try {
      final dateString = date != null 
          ? date.toIso8601String().split('T')[0]
          : 'today';
      final response = await _dio.get('/fixtures?date=$dateString&status=FT');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Match?> getMatchDetails(String matchId) async {
    try {
      final response = await _dio.get('/fixtures?id=$matchId');
      return _parseMatch(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> searchMatches(String query) async {
    try {
      final response = await _dio.get('/fixtures?search=$query');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<League>> getPopularLeagues() async {
    try {
      final response = await _dio.get('/leagues');
      return _parseLeagues(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Helper Methods ───────────────────────────────────────────────────

  List<Match> _parseMatches(dynamic data) {
    if (data is! Map) return [];
    
    final response = data['response'] as List? ?? [];
    return response.map((match) => _parseMatch(match)).whereType<Match>().toList();
  }

  Match? _parseMatch(dynamic data) {
    try {
      if (data is! Map) return null;
      
      final matchData = data as Map<String, dynamic>;
      
      // Parse teams
      final homeTeam = Team(
        id: matchData['teams']['home']['id']?.toString() ?? '',
        name: matchData['teams']['home']['name'] ?? 'Unknown',
        logo: matchData['teams']['home']['logo'] ?? '',
        shortName: matchData['teams']['home']['name'] ?? '',
      );
      
      final awayTeam = Team(
        id: matchData['teams']['away']['id']?.toString() ?? '',
        name: matchData['teams']['away']['name'] ?? 'Unknown',
        logo: matchData['teams']['away']['logo'] ?? '',
        shortName: matchData['teams']['away']['name'] ?? '',
      );

      // Parse match status
      final statusStr = matchData['status'] ?? 'UNKNOWN';
      final status = _parseMatchStatus(statusStr);

      // Parse scores
      final homeScore = matchData['goals']['home'] as int?;
      final awayScore = matchData['goals']['away'] as int?;

      // Parse league
      final league = League(
        id: matchData['league']['id']?.toString() ?? '',
        name: matchData['league']['name'] ?? 'Unknown League',
        logo: matchData['league']['logo'] ?? '',
        country: matchData['league']['country'] ?? '',
        sportType: SportType.football,
      );

      return Match(
        id: matchData['id']?.toString() ?? '',
        sportType: SportType.football,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
        startTime: DateTime.parse(matchData['utcDate'] ?? DateTime.now().toIso8601String()),
        status: status,
        venue: matchData['venue'] ?? '',
        isHot: false, // You can implement logic to determine hot matches
      );
    } catch (e) {
      debugPrint('Error parsing match: $e');
      return null;
    }
  }

  MatchStatus _parseMatchStatus(String status) {
    switch (status.toUpperCase()) {
      case 'LIVE':
      case 'IN_PLAY':
      case 'PAUSED':
      case '1H':
      case '2H':
      case 'HT':
      case 'ET':
      case 'BT':
        return MatchStatus.live;
      case 'NS':
      case 'SCHEDULED':
      case 'TIMED':
        return MatchStatus.upcoming;
      case 'FT':
      case 'AET':
      case 'PEN':
        return MatchStatus.finished;
      default:
        return MatchStatus.upcoming;
    }
  }

  List<League> _parseLeagues(dynamic data) {
    if (data is! Map) return [];
    
    final response = data['response'] as List? ?? [];
    return response.map((league) {
      if (league is! Map) return null;
      
      return League(
        id: league['league']['id']?.toString() ?? '',
        name: league['league']['name'] ?? 'Unknown',
        logo: league['league']['logo'] ?? '',
        country: league['country']['name'] ?? '',
        sportType: SportType.football,
      );
    }).whereType<League>().toList();
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Request timeout. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Invalid API key. Please check your configuration.');
        } else if (statusCode == 429) {
          return Exception('Rate limit exceeded. Please try again later.');
        } else {
          return Exception('Server error: $statusCode');
        }
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
