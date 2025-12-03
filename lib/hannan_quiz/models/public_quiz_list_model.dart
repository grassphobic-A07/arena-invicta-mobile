// To parse this JSON data, do
//
//     final publicQuizListEntry = publicQuizListEntryFromJson(jsonString);

import 'dart:convert';

List<PublicQuizListEntry> publicQuizListEntryFromJson(String str) => List<PublicQuizListEntry>.from(json.decode(str).map((x) => PublicQuizListEntry.fromJson(x)));

String publicQuizListEntryToJson(List<PublicQuizListEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PublicQuizListEntry {
    int id;
    String title;
    String description;
    String category;
    bool isQuizHot;
    int totalQuestions;
    String createdBy;

    PublicQuizListEntry({
        required this.id,
        required this.title,
        required this.description,
        required this.category,
        required this.isQuizHot,
        required this.totalQuestions,
        required this.createdBy,
    });

    factory PublicQuizListEntry.fromJson(Map<String, dynamic> json) => PublicQuizListEntry(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: json["category"],
        isQuizHot: json["is_quiz_hot"],
        totalQuestions: json["total_questions"],
        createdBy: json["created_by"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "category": category,
        "is_quiz_hot": isQuizHot,
        "total_questions": totalQuestions,
        "created_by": createdBy,
    };
}
