import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Real HTTP implementation of [ApiService] for basketball.
///
/// This class integrates with NBA API to provide real basketball data.
class RealBasketballService implements ApiService {
  late final Dio _dio;

  RealBasketballService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.basketballBaseUrl,
      connectTimeout: ApiConfig.requestTimeout,
      receiveTimeout: ApiConfig.requestTimeout,
      headers: {
        'apikey': ApiConfig.basketballApiKey,
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
      final response = await _dio.get('/games?live=1');
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
          : '2024-01-01';
      final response = await _dio.get('/games?date=$dateString&status=NS');
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
          : '2024-01-01';
      final response = await _dio.get('/games?date=$dateString&status=FT');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Match?> getMatchDetails(String matchId) async {
    try {
      final response = await _dio.get('/games?id=$matchId');
      return _parseMatch(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> searchMatches(String query) async {
    try {
      final response = await _dio.get('/games?search=$query');
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
        id: matchData['HomeTeamID']?.toString() ?? '',
        name: matchData['HomeTeam'] ?? 'Unknown',
        logo: '', // NBA API doesn't provide logos in basic endpoint
        shortName: matchData['HomeTeam'] ?? '',
      );
      
      final awayTeam = Team(
        id: matchData['AwayTeamID']?.toString() ?? '',
        name: matchData['AwayTeam'] ?? 'Unknown',
        logo: '', // NBA API doesn't provide logos in basic endpoint
        shortName: matchData['AwayTeam'] ?? '',
      );

      // Parse match status
      final statusStr = matchData['GameStatus'] ?? 'UNKNOWN';
      final status = _parseMatchStatus(statusStr);

      // Parse scores
      final homeScore = matchData['HomeTeamScore'] as int?;
      final awayScore = matchData['AwayTeamScore'] as int?;

      // Parse league
      final league = League(
        id: matchData['Season']?.toString() ?? '',
        name: 'NBA Season ${matchData['Season'] ?? ''}',
        logo: '',
        country: 'USA',
        sportType: SportType.basketball,
      );

      return Match(
        id: matchData['GameID']?.toString() ?? '',
        sportType: SportType.basketball,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
        status: status,
        startTime: DateTime.tryParse(matchData['DateTime'] ?? '') ?? DateTime.now(),
        venue: matchData['Stadium'],
      );
    } catch (e) {
      debugPrint('Error parsing basketball match: $e');
      return null;
    }
  }

  MatchStatus _parseMatchStatus(String status) {
    switch (status.toUpperCase()) {
      case 'INPROGRESS':
        return MatchStatus.live;
      case 'SCHEDULED':
        return MatchStatus.upcoming;
      case 'FINAL':
      case 'COMPLETED':
        return MatchStatus.finished;
      default:
        return MatchStatus.upcoming;
    }
  }

  List<League> _parseLeagues(dynamic data) {
    if (data is! List) return [];
    
    return data.map((league) {
      if (league is! Map) return null;
      
      return League(
        id: league['LeagueID']?.toString() ?? '',
        name: league['LeagueName'] ?? 'Unknown',
        logo: '',
        country: league['Country'] ?? '',
        sportType: SportType.basketball,
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
