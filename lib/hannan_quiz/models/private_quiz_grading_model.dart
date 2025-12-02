// To parse this JSON data, do
//
//     final quizEntry = quizEntryFromJson(jsonString);

import 'dart:convert';

QuizEntry quizEntryFromJson(String str) => QuizEntry.fromJson(json.decode(str));

String quizEntryToJson(QuizEntry data) => json.encode(data.toJson());

class QuizEntry {
    int score;
    int total;
    List<Result> result;

    QuizEntry({
        required this.score,
        required this.total,
        required this.result,
    });

    factory QuizEntry.fromJson(Map<String, dynamic> json) => QuizEntry(
        score: json["score"],
        total: json["total"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "score": score,
        "total": total,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class Result {
    int questionId;
    bool correct;

    Result({
        required this.questionId,
        required this.correct,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        questionId: json["question_id"],
        correct: json["correct"],
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "correct": correct,
    };
}
