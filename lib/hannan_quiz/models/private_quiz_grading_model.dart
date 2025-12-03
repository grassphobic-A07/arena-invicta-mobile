// To parse this JSON data, do
//
//     final privateQuizGradingEntry = privateQuizGradingEntryFromJson(jsonString);

import 'dart:convert';

PrivateQuizGradingEntry privateQuizGradingEntryFromJson(String str) => PrivateQuizGradingEntry.fromJson(json.decode(str));

String privateQuizGradingEntryToJson(PrivateQuizGradingEntry data) => json.encode(data.toJson());

class PrivateQuizGradingEntry {
    int score;
    int total;
    List<Result> result;

    PrivateQuizGradingEntry({
        required this.score,
        required this.total,
        required this.result,
    });

    factory PrivateQuizGradingEntry.fromJson(Map<String, dynamic> json) => PrivateQuizGradingEntry(
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
