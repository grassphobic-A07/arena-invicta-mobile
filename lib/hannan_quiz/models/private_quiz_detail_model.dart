// To parse this JSON data, do
//
//     final quizEntry = quizEntryFromJson(jsonString);

import 'dart:convert';

QuizEntry quizEntryFromJson(String str) => QuizEntry.fromJson(json.decode(str));

String quizEntryToJson(QuizEntry data) => json.encode(data.toJson());

class QuizEntry {
    int id;
    String title;
    List<CorrectAnswer> correctAnswers;
    List<Score> scores;

    QuizEntry({
        required this.id,
        required this.title,
        required this.correctAnswers,
        required this.scores,
    });

    factory QuizEntry.fromJson(Map<String, dynamic> json) => QuizEntry(
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
