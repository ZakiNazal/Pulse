import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Real HTTP implementation of [ApiService] for MMA.
///
/// This class integrates with MMA API to provide real MMA data.
class RealMMAService implements ApiService {
  late final Dio _dio;

  RealMMAService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.mmaBaseUrl,
      connectTimeout: ApiConfig.requestTimeout,
      receiveTimeout: ApiConfig.requestTimeout,
      headers: {
        'Ocp-Apim-Subscription-Key': ApiConfig.mmaApiKey,
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
      final response = await _dio.get('/scores/json/LiveGames');
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
      final response = await _dio.get('/scores/json/GamesByDate/$dateString');
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
          ? date.toIso8601String().split('T')[0]
          : 'today';
      final response = await _dio.get('/scores/json/GamesByDate/$dateString');
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
      final response = await _dio.get('/scores/json/GameByGameID/$matchId');
      return _parseMatch(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Match>> searchMatches(String query) async {
    try {
      final response = await _dio.get('/scores/json/SearchFights/$query');
      return _parseMatches(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<League>> getPopularLeagues() async {
    try {
      final response = await _dio.get('/leagues/json/ActiveLeagues');
      return _parseLeagues(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Helper Methods ───────────────────────────────────────────────────

  List<Match> _parseMatches(dynamic data) {
    if (data is! List) return [];
    
    return data.map((match) => _parseMatch(match)).whereType<Match>().toList();
  }

  Match? _parseMatch(dynamic data) {
    try {
      if (data is! Map) return null;
      
      final matchData = data as Map<String, dynamic>;
      
      // Parse fighters (teams)
      final homeTeam = Team(
        id: matchData['FighterID1']?.toString() ?? '',
        name: matchData['Fighter1'] ?? 'Unknown Fighter',
        logo: '',
        shortName: matchData['Fighter1Nickname'] ?? '',
      );
      
      final awayTeam = Team(
        id: matchData['FighterID2']?.toString() ?? '',
        name: matchData['Fighter2'] ?? 'Unknown Fighter',
        logo: '',
        shortName: matchData['Fighter2Nickname'] ?? '',
      );

      // Parse match status
      final statusStr = matchData['Status'] ?? 'UNKNOWN';
      final status = _parseMatchStatus(statusStr);

      // Parse scores (fight results)
      final homeScore = matchData['Fighter1Score'] as int?;
      final awayScore = matchData['Fighter2Score'] as int?;

      // Parse league/organization
      final league = League(
        id: matchData['OrganizationID']?.toString() ?? '',
        name: matchData['Organization'] ?? 'Unknown Organization',
        logo: '',
        country: matchData['Country'] ?? '',
        sportType: SportType.mma,
      );

      return Match(
        id: matchData['FightID']?.toString() ?? '',
        sportType: SportType.mma,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
        status: status,
        startTime: DateTime.tryParse(matchData['DateTime'] ?? '') ?? DateTime.now(),
        venue: matchData['Venue'],
      );
    } catch (e) {
      debugPrint('Error parsing MMA match: $e');
      return null;
    }
  }

  MatchStatus _parseMatchStatus(String status) {
    switch (status.toUpperCase()) {
      case 'INPROGRESS':
      case 'LIVE':
        return MatchStatus.live;
      case 'SCHEDULED':
      case 'UPCOMING':
        return MatchStatus.upcoming;
      case 'FINISHED':
      case 'COMPLETED':
      case 'ENDED':
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
        id: league['OrganizationID']?.toString() ?? '',
        name: league['OrganizationName'] ?? 'Unknown',
        logo: '',
        country: league['Country'] ?? '',
        sportType: SportType.mma,
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
