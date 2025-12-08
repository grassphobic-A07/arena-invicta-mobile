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
    List<Leaderboard> leaderboard;

    PrivateQuizGradingEntry({
        required this.score,
        required this.total,
        required this.result,
        required this.leaderboard,
    });

    factory PrivateQuizGradingEntry.fromJson(Map<String, dynamic> json) => PrivateQuizGradingEntry(
        score: json["score"],
        total: json["total"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        leaderboard: List<Leaderboard>.from(json["leaderboard"].map((x) => Leaderboard.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "score": score,
        "total": total,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
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
