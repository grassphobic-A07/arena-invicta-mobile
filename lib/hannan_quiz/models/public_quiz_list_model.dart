// To parse this JSON data, do
//
//     final quizEntry = quizEntryFromJson(jsonString);

import 'dart:convert';

List<QuizEntry> quizEntryFromJson(String str) => List<QuizEntry>.from(json.decode(str).map((x) => QuizEntry.fromJson(x)));

String quizEntryToJson(List<QuizEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuizEntry {
    int id;
    String title;
    String description;
    String category;
    bool isQuizHot;
    int totalQuestions;
    String createdBy;

    QuizEntry({
        required this.id,
        required this.title,
        required this.description,
        required this.category,
        required this.isQuizHot,
        required this.totalQuestions,
        required this.createdBy,
    });

    factory QuizEntry.fromJson(Map<String, dynamic> json) => QuizEntry(
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
