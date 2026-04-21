import 'package:equatable/equatable.dart';
import 'sport_type.dart';

/// Represents a sports league or competition.
///
/// A league belongs to exactly one [SportType] and is optionally associated
/// with a country and visual assets ([logo], [flag]).
class League extends Equatable {
  const League({
    required this.id,
    required this.name,
    required this.country,
    required this.sportType,
    this.logo,
    this.flag,
  });

  /// Unique identifier for the league (e.g. a provider ID or internal UUID).
  final String id;

  /// Full display name of the league (e.g. "Premier League").
  final String name;

  /// Country where the league is based (e.g. "England").
  final String country;

  /// The type of sport this league covers.
  final SportType sportType;

  /// URL or asset path pointing to the league's logo image.
  final String? logo;

  /// URL or asset path pointing to the country flag image.
  final String? flag;

  /// Creates a [League] from a JSON map.
  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      sportType: SportTypeX.fromJsonKey(json['sportType'] as String?) ??
          SportType.football,
      logo: json['logo'] as String?,
      flag: json['flag'] as String?,
    );
  }

  /// Serializes this [League] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'sportType': sportType.jsonKey,
      'logo': logo,
      'flag': flag,
    };
  }

  /// Creates a copy of this [League] with the given fields replaced.
  League copyWith({
    String? id,
    String? name,
    String? country,
    SportType? sportType,
    String? logo,
    String? flag,
  }) {
    return League(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      sportType: sportType ?? this.sportType,
      logo: logo ?? this.logo,
      flag: flag ?? this.flag,
    );
  }

  @override
  List<Object?> get props => [id, name, country, sportType, logo, flag];

  @override
  String toString() => 'League(id: $id, name: $name, country: $country)';
}
