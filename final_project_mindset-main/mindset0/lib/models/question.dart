class Answer {
  final int id;
  final String answerText;

  Answer({required this.id, required this.answerText});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      answerText: json['text'],
    );
  }
}

class Question {
  final int id;
  final String text;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var answersList = json['answers'] as List;
    List<Answer> answers = answersList.map((i) => Answer.fromJson(i)).toList();

    return Question(
      id: json['id'],
      text: json['question'],  
      answers: answers,
    );
  }
}

class QuestionsResponse {
  final int code;
  final String msg;
  final List<Question> questions;

  QuestionsResponse({
    required this.code,
    required this.msg,
    required this.questions,
  });

  factory QuestionsResponse.fromJson(Map<String, dynamic> json) {
    var questionsJson = json['data']['questions'] as List;
    List<Question> questions = questionsJson.map((q) => Question.fromJson(q)).toList();

    return QuestionsResponse(
      code: json['code'],
      msg: json['msg'],
      questions: questions,
    );
  }
}
