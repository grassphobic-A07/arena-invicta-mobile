// To parse this JSON data, do
//
//     final privateQuizListEntry = privateQuizListEntryFromJson(jsonString);

import 'dart:convert';

List<PrivateQuizListEntry> privateQuizListEntryFromJson(String str) => List<PrivateQuizListEntry>.from(json.decode(str).map((x) => PrivateQuizListEntry.fromJson(x)));

String privateQuizListEntryToJson(List<PrivateQuizListEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrivateQuizListEntry {
    int id;
    String title;
    String description;
    String category;
    bool isQuizHot;
    int totalQuestion;
    bool isPublished;

    PrivateQuizListEntry({
        required this.id,
        required this.title,
        required this.description,
        required this.category,
        required this.isQuizHot,
        required this.totalQuestion,
        required this.isPublished,
    });

    factory PrivateQuizListEntry.fromJson(Map<String, dynamic> json) => PrivateQuizListEntry(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: json["category"],
        isQuizHot: json["is_quiz_hot"],
        totalQuestion: json["total_question"],
        isPublished: json["is_published"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "category": category,
        "is_quiz_hot": isQuizHot,
        "total_question": totalQuestion,
        "is_published": isPublished,
    };
}
