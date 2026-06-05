// ============================================================
// MODELS
// ============================================================

class Confederation {
  final int id;
  final String name;

  Confederation({required this.id, required this.name});

  factory Confederation.fromJson(Map<String, dynamic> json) {
    return Confederation(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Country {
  final int id;
  final String name;
  final int confederationId;
  final String emoji;

  Country({
    required this.id,
    required this.name,
    required this.confederationId,
    required this.emoji,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      confederationId: json['confederation_id'],
      emoji: json['emoji'] ?? '🌍',
    );
  }

  String get displayName => '$emoji $name';
}

class Match {
  final int? id;
  final int homeTeamId;
  final int awayTeamId;
  final int homeTeamScore;
  final int awayTeamScore;
  final DateTime date;
  final String stage;

  Match({
    this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.date,
    required this.stage,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      homeTeamId: json['home_team_id'],
      awayTeamId: json['away_team_id'],
      homeTeamScore: json['home_team_score'],
      awayTeamScore: json['away_team_score'],
      date: DateTime.parse(json['date']),
      stage: json['stage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'home_team_score': homeTeamScore,
      'away_team_score': awayTeamScore,
      'date': date.toIso8601String(),
      'stage': stage,
    };
  }

  MatchResult get result {
    if (homeTeamScore > awayTeamScore) return MatchResult.homeWin;
    if (awayTeamScore > homeTeamScore) return MatchResult.awayWin;
    return MatchResult.draw;
  }

  Match copyWith({
    int? id,
    int? homeTeamId,
    int? awayTeamId,
    int? homeTeamScore,
    int? awayTeamScore,
    DateTime? date,
    String? stage,
  }) {
    return Match(
      id: id ?? this.id,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeTeamScore: homeTeamScore ?? this.homeTeamScore,
      awayTeamScore: awayTeamScore ?? this.awayTeamScore,
      date: date ?? this.date,
      stage: stage ?? this.stage,
    );
  }
}

enum MatchResult { homeWin, awayWin, draw }