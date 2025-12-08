// To parse this JSON data, do
//
//     final privateQuizDetailEntry = privateQuizDetailEntryFromJson(jsonString);

import 'dart:convert';

PrivateQuizDetailEntry privateQuizDetailEntryFromJson(String str) => PrivateQuizDetailEntry.fromJson(json.decode(str));

String privateQuizDetailEntryToJson(PrivateQuizDetailEntry data) => json.encode(data.toJson());

class PrivateQuizDetailEntry {
    int id;
    String title;
    List<CorrectAnswer> correctAnswers;
    List<Score> scores;

    PrivateQuizDetailEntry({
        required this.id,
        required this.title,
        required this.correctAnswers,
        required this.scores,
    });

    factory PrivateQuizDetailEntry.fromJson(Map<String, dynamic> json) => PrivateQuizDetailEntry(
        id: json["id"],
        title: json["title"],
        correctAnswers: List<CorrectAnswer>.from(json["correct_answers"].map((x) => CorrectAnswer.fromJson(x))),
        scores: List<Score>.from(json["scores"].map((x) => Score.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "correct_answers": List<dynamic>.from(correctAnswers.map((x) => x.toJson())),
        "scores": List<dynamic>.from(scores.map((x) => x.toJson())),
    };
}

class CorrectAnswer {
    int questionId;
    String correctAnswer;

    CorrectAnswer({
        required this.questionId,
        required this.correctAnswer,
    });

    factory CorrectAnswer.fromJson(Map<String, dynamic> json) => CorrectAnswer(
        questionId: json["question_id"],
        correctAnswer: json["correct_answer"],
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "correct_answer": correctAnswer,
    };
}

class Score {
    String user;
    int score;

    Score({
        required this.user,
        required this.score,
    });

    factory Score.fromJson(Map<String, dynamic> json) => Score(
        user: json["user"],
        score: json["score"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "score": score,
    };
}
