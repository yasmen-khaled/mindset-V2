import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final bool passed;

  const ResultPage({Key? key, required this.score, required this.passed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدم score و passed هنا
    return Scaffold(
      body: Center(
        child: Text('Score: $score\nPassed: $passed'),
      ),
    );
  }
}
