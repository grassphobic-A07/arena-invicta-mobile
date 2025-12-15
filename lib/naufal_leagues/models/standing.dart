// To parse this JSON data, do
//
//     final standings = standingFromJson(jsonString);

import 'dart:convert';

List<Standing> standingFromJson(String str) => List<Standing>.from(json.decode(str).map((x) => Standing.fromJson(x)));

String standingToJson(List<Standing> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Standing {
    String model;
    int pk;
    Fields fields;

    Standing({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Standing.fromJson(Map<String, dynamic> json) => Standing(
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
    String season; // UBAH KE STRING (PENTING!)
    int team;
    int played;
    int win;
    int draw;
    int loss;
    int gf;
    int ga;
    int gd;
    int points;

    Fields({
        required this.league,
        required this.season,
        required this.team,
        required this.played,
        required this.win,
        required this.draw,
        required this.loss,
        required this.gf,
        required this.ga,
        required this.gd,
        required this.points,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        league: json["league"],
        season: json["season"],
        team: json["team"],
        played: json["played"],
        win: json["win"],
        draw: json["draw"],
        loss: json["loss"],
        gf: json["gf"],
        ga: json["ga"],
        gd: json["gd"],
        points: json["points"],
    );

    Map<String, dynamic> toJson() => {
        "league": league,
        "season": season,
        "team": team,
        "played": played,
        "win": win,
        "draw": draw,
        "loss": loss,
        "gf": gf,
        "ga": ga,
        "gd": gd,
        "points": points,
    };
}