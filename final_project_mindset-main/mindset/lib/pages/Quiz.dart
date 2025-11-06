import 'package:flutter/material.dart';
import 'package:mindset/pages/home.dart';
import 'Result.dart'; // Import result page
import 'games.dart'; // Import GamesPage
import 'dart:async';
import '../services/api_service.dart';
import '../models/question.dart';

class QuizPage extends StatefulWidget {
  final int levelId;
  const QuizPage({Key? key, required this.levelId}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Question>> futureQuestions;
  int currentQuestionIndex = 0;
  bool isCompleted = false;

  int remainingSeconds = 60; // 60 seconds total
  Timer? _timer;
  bool canGoToResult = false;
  int _selectedIndex = 1; // Start with home selected

 List<Map<String, int>> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    futureQuestions = ApiService.fetchQuestions(widget.levelId);
    _startTimer();
  }

  void _startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
    if (remainingSeconds > 0) {
      setState(() {
        remainingSeconds--;
      });
    } else {
      _timer?.cancel();
      setState(() {
        canGoToResult = true;
      });

              final result = await ApiService.submitAnswers(widget.levelId, selectedAnswers);
if (result != null && result is Map && result['data'] != null) {
        final data = result['data'];
int score = data['score'] ?? 0;
        bool passed = data['next_stage_opened'] ?? false;

       
        // Auto navigate to result page when total time is up
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ResultPage(score: score, passed: passed),
  ),
).then((result) {
  if (result == true) {
    Navigator.pop(context, true);
          }
        });
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answers. Please try again.')),
        );
      }
    }
  });
}
    

  void _moveToNextQuestion(List<Question> questions) async {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _timer?.cancel();
      setState(() {
        isCompleted = true;
        canGoToResult = true;
      });

       final result = await ApiService.submitAnswers(widget.levelId, selectedAnswers);

if (result != null && result is Map && result['data'] != null) {
  final data = result['data'];
  int score = data['score'] ?? 0;
  bool passed = data['next_stage_opened'] ?? false;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ResultPage(score: score, passed: passed),
    ),
  ).then((result) {
    if (result == true) {
      Navigator.pop(context, true);
    }
  });
} else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answers. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get timerText {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

 void answerQuestion(int questionId, int selectedAnswerId, List<Question> questions) {
  selectedAnswers.add({
    'question_id': questionId,
    'selected_answer_id': selectedAnswerId,
  });
  _moveToNextQuestion(questions);
}


  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Show leaderboard coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leaderboard coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    if (index == 1) {
      // Navigate to home page
         Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
      return;
    }

    if (index == 2) {
      // Navigate to games page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamesPage(),
        ),
      );
      return;
    }
  }

  Widget _buildNavButton(IconData icon,
      {bool isSelected = false,
      bool isHome = false,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isHome ? 24 : 20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isHome ? 30 : 25),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 33, 150, 243)
                : Colors.white.withOpacity(0.2),
            width: isHome ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 33, 150, 243)
                        .withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white,
          size: isHome ? 48 : 38,
        ),
      ),
    );
  }









  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: FutureBuilder<List<Question>>(
          future: futureQuestions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No questions found.',
                      style: TextStyle(color: Colors.white)));
            }

            final questions = snapshot.data!;
            final currentQuestion = questions[currentQuestionIndex];
            final totalQuestions = questions.length;

            return Column(
              children: [
                // Top bar (stars, character, hearts)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Row(
                    children: [
                      // Stars
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.blue[200], size: 32),
                          SizedBox(width: 4),
                          Text('30',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Spacer(),
                      // Character (default icon)
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 22,
                        child: Icon(Icons.emoji_emotions,
                            color: Colors.blue[700], size: 32),
                      ),
                      SizedBox(width: 12),
                      // Percentage
                      Text('200%',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 16),
                      // Hearts
                      Row(
                        children: [
                          Icon(Icons.favorite,
                              color: Colors.red[300], size: 30),
                          SizedBox(width: 4),
                          Text('5',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currentQuestionIndex + 1}/$totalQuestions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer,
                                        color: Colors.red, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      timerText,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (currentQuestionIndex + 1) / totalQuestions,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 24),

                          // Question text
                          Text(
                            currentQuestion.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 32),

                          // Answer options
                          ...currentQuestion.answers
                              .map((option) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: ElevatedButton(
                                       onPressed: () => answerQuestion(currentQuestion.id, option.id, questions),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade300,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        option.answerText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 32.0, top: 16.0, left: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavButton(
                        Icons.leaderboard,
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onNavTap(0),
                      ),
                      _buildNavButton(
                        Icons.home,
                        isSelected: _selectedIndex == 1,
                        isHome: true,
                        onTap: () => _onNavTap(1),
                      ),
                      _buildNavButton(
                        Icons.gamepad,
                        isSelected: _selectedIndex == 2,
                        onTap: () => _onNavTap(2),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
