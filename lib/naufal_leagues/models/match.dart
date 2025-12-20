// To parse this JSON data, do
//
//     final matches = matchFromJson(jsonString);

import 'dart:convert';

List<Match> matchFromJson(String str) => List<Match>.from(json.decode(str).map((x) => Match.fromJson(x)));

String matchToJson(List<Match> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Match {
    String model;
    int pk;
    Fields fields;

    Match({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Match.fromJson(Map<String, dynamic> json) => Match(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int league;
    String season; // UBAH KE STRING AGAR AMAN
    DateTime date;
    int homeTeam;
    int awayTeam;
    String status; // Boleh String atau Enum, tapi String lebih aman
    int homeScore;
    int awayScore;
    int homeClearances;
    int homeCorners;
    int homeFoulsConceded;
    int homeOffsides;
    int homePasses;
    double homePossession; // FloatField di Django biasanya jadi double
    int homeRedCards;
    int homeShots;
    int homeShotsOnTarget;
    int homeTackles;
    int homeTouches;
    int homeYellowCards;
    int awayClearances;
    int awayCorners;
    int awayFoulsConceded;
    int awayOffsides;
    int awayPasses;
    double awayPossession; // FloatField di Django biasanya jadi double
    int awayRedCards;
    int awayShots;
    int awayShotsOnTarget;
    int awayTackles;
    int awayTouches;
    int awayYellowCards;

    Fields({
        required this.league,
        required this.season,
        required this.date,
        required this.homeTeam,
        required this.awayTeam,
        required this.status,
        required this.homeScore,
        required this.awayScore,
        required this.homeClearances,
        required this.homeCorners,
        required this.homeFoulsConceded,
        required this.homeOffsides,
        required this.homePasses,
        required this.homePossession,
        required this.homeRedCards,
        required this.homeShots,
        required this.homeShotsOnTarget,
        required this.homeTackles,
        required this.homeTouches,
        required this.homeYellowCards,
        required this.awayClearances,
        required this.awayCorners,
        required this.awayFoulsConceded,
        required this.awayOffsides,
        required this.awayPasses,
        required this.awayPossession,
        required this.awayRedCards,
        required this.awayShots,
        required this.awayShotsOnTarget,
        required this.awayTackles,
        required this.awayTouches,
        required this.awayYellowCards,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        league: json["league"],
        season: json["season"],
        date: DateTime.parse(json["date"]),
        homeTeam: json["home_team"],
        awayTeam: json["away_team"],
        status: json["status"],
        homeScore: json["home_score"],
        awayScore: json["away_score"],
        homeClearances: json["home_clearances"],
        homeCorners: json["home_corners"],
        homeFoulsConceded: json["home_fouls_conceded"],
        homeOffsides: json["home_offsides"],
        homePasses: json["home_passes"],
        homePossession: (json["home_possession"] as num).toDouble(), // Handle int or double
        homeRedCards: json["home_red_cards"],
        homeShots: json["home_shots"],
        homeShotsOnTarget: json["home_shots_on_target"],
        homeTackles: json["home_tackles"],
        homeTouches: json["home_touches"],
        homeYellowCards: json["home_yellow_cards"],
        awayClearances: json["away_clearances"],
        awayCorners: json["away_corners"],
        awayFoulsConceded: json["away_fouls_conceded"],
        awayOffsides: json["away_offsides"],
        awayPasses: json["away_passes"],
        awayPossession: (json["away_possession"] as num).toDouble(), // Handle int or double
        awayRedCards: json["away_red_cards"],
        awayShots: json["away_shots"],
        awayShotsOnTarget: json["away_shots_on_target"],
        awayTackles: json["away_tackles"],
        awayTouches: json["away_touches"],
        awayYellowCards: json["away_yellow_cards"],
    );

    Map<String, dynamic> toJson() => {
        "league": league,
        "season": season,
        "date": date.toIso8601String(),
        "home_team": homeTeam,
        "away_team": awayTeam,
        "status": status,
        "home_score": homeScore,
        "away_score": awayScore,
        "home_clearances": homeClearances,
        "home_corners": homeCorners,
        "home_fouls_conceded": homeFoulsConceded,
        "home_offsides": homeOffsides,
        "home_passes": homePasses,
        "home_possession": homePossession,
        "home_red_cards": homeRedCards,
        "home_shots": homeShots,
        "home_shots_on_target": homeShotsOnTarget,
        "home_tackles": homeTackles,
        "home_touches": homeTouches,
        "home_yellow_cards": homeYellowCards,
        "away_clearances": awayClearances,
        "away_corners": awayCorners,
        "away_fouls_conceded": awayFoulsConceded,
        "away_offsides": awayOffsides,
        "away_passes": awayPasses,
        "away_possession": awayPossession,
        "away_red_cards": awayRedCards,
        "away_shots": awayShots,
        "away_shots_on_target": awayShotsOnTarget,
        "away_tackles": awayTackles,
        "away_touches": awayTouches,
        "away_yellow_cards": awayYellowCards,
    };
}