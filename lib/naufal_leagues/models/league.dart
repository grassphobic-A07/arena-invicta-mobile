// To parse this JSON data, do
//
//     final leagues = leagueFromJson(jsonString);

import 'dart:convert';

List<League> leagueFromJson(String str) => List<League>.from(json.decode(str).map((x) => League.fromJson(x)));

String leagueToJson(List<League> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class League {
    String model;
    int pk;
    Fields fields;

    League({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory League.fromJson(Map<String, dynamic> json) => League(
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
    String name;
    String country;

    Fields({
        required this.name,
        required this.country,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        country: json["country"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "country": country,
    };
}