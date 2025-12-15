// To parse this JSON data, do
//
//     final teams = teamFromJson(jsonString);

import 'dart:convert';

List<Team> teamFromJson(String str) => List<Team>.from(json.decode(str).map((x) => Team.fromJson(x)));

String teamToJson(List<Team> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Team {
    String model;
    int pk;
    Fields fields;

    Team({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
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
    String name;
    String shortName;
    int? foundedYear;

    Fields({
        required this.league,
        required this.name,
        required this.shortName,
        required this.foundedYear,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        league: json["league"],
        name: json["name"],
        shortName: json["short_name"],
        foundedYear: json["founded_year"], 
    );

    Map<String, dynamic> toJson() => {
        "league": league,
        "name": name,
        "short_name": shortName,
        "founded_year": foundedYear,
    };
}