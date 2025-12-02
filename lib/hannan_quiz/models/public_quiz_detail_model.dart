// To parse this JSON data, do
//
//     final quizEntry = quizEntryFromJson(jsonString);

import 'dart:convert';

QuizEntry quizEntryFromJson(String str) => QuizEntry.fromJson(json.decode(str));

String quizEntryToJson(QuizEntry data) => json.encode(data.toJson());

class QuizEntry {
    int id;
    String title;
    String description;
    List<Question> questions;

    QuizEntry({
        required this.id,
        required this.title,
        required this.description,
        required this.questions,
    });

    factory QuizEntry.fromJson(Map<String, dynamic> json) => QuizEntry(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        questions: List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
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
