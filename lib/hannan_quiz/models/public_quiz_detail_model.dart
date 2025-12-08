// To parse this JSON data, do
//
//     final publicQuizDetailEntry = publicQuizDetailEntryFromJson(jsonString);

import 'dart:convert';

PublicQuizDetailEntry publicQuizDetailEntryFromJson(String str) => PublicQuizDetailEntry.fromJson(json.decode(str));

String publicQuizDetailEntryToJson(PublicQuizDetailEntry data) => json.encode(data.toJson());

class PublicQuizDetailEntry {
    int id;
    String title;
    String description;
    List<Question> questions;
    List<Leaderboard> leaderboard;

    PublicQuizDetailEntry({
        required this.id,
        required this.title,
        required this.description,
        required this.questions,
        required this.leaderboard,
    });

    factory PublicQuizDetailEntry.fromJson(Map<String, dynamic> json) => PublicQuizDetailEntry(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        questions: List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
        leaderboard: List<Leaderboard>.from(json["leaderboard"].map((x) => Leaderboard.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
        "leaderboard": List<dynamic>.from(leaderboard.map((x) => x.toJson())),
    };
}

class Leaderboard {
    String user;
    int score;

    Leaderboard({
        required this.user,
        required this.score,
    });

    factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
        user: json["user"],
        score: json["score"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "score": score,
    };
}

class Question {
    int id;
    String text;
    Options options;

    Question({
        required this.id,
        required this.text,
        required this.options,
    });

    factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        text: json["text"],
        options: Options.fromJson(json["options"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "options": options.toJson(),
    };
}

class Options {
    String a;
    String b;
    String c;
    String d;

    Options({
        required this.a,
        required this.b,
        required this.c,
        required this.d,
    });

    factory Options.fromJson(Map<String, dynamic> json) => Options(
        a: json["A"],
        b: json["B"],
        c: json["C"],
        d: json["D"],
    );

    Map<String, dynamic> toJson() => {
        "A": a,
        "B": b,
        "C": c,
        "D": d,
    };
}
