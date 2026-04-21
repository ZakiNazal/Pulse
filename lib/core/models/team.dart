import 'package:equatable/equatable.dart';

/// Represents a sports team.
///
/// Holds the canonical identity of a team across the Pulse app. Fields
/// [logo] and [shortName] are nullable to gracefully handle incomplete
/// data from third-party APIs.
class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    this.logo,
    this.shortName,
  });

  /// Unique identifier for the team (e.g. a provider ID or internal UUID).
  final String id;

  /// Full display name of the team (e.g. "Manchester United").
  final String name;

  /// URL or asset path pointing to the team's logo image.
  final String? logo;

  /// Abbreviated name suitable for compact UIs (e.g. "MAN UTD", "LAL").
  final String? shortName;

  /// Display name that falls back to [name] when [shortName] is null.
  String get displayName => shortName ?? name;

  /// Creates a [Team] from a JSON map.
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      shortName: json['shortName'] as String?,
    );
  }

  /// Serializes this [Team] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'shortName': shortName,
    };
  }

  /// Creates a copy of this [Team] with the given fields replaced.
  Team copyWith({
    String? id,
    String? name,
    String? logo,
    String? shortName,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      shortName: shortName ?? this.shortName,
    );
  }

  @override
  List<Object?> get props => [id, name, logo, shortName];

  @override
  String toString() => 'Team(id: $id, name: $name)';
}
