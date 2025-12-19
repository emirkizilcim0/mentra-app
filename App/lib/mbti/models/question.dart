class Choice {
  final String label;
  final int value; // -2'den +2'ye kadar puan

  Choice({required this.label, required this.value});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(label: json['label'] as String, value: json['value'] as int);
  }
}

class Question {
  final int no;
  final String question;
  final String dimension; // Örneğin: "E/I", "S/N"
  final String scoreType; // Örneğin: "E", "S", "T", "J"
  final List<Choice> choices;

  Question({
    required this.no,
    required this.question,
    required this.dimension,
    required this.scoreType,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var choicesList = json['choices'] as List;
    List<Choice> choices = choicesList.map((i) => Choice.fromJson(i)).toList();

    return Question(
      no: json['no'] as int,
      question: json['question'] as String,
      dimension: json['dimension'] as String,
      scoreType: json['score_type'] as String,
      choices: choices,
    );
  }

  void operator [](String other) {}
}
