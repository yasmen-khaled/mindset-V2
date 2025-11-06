import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'tasks.dart';
import 'home.dart';
import 'games.dart';
import 'quiz.dart'; // Added import for QuizPage

class LevelTopicsPage extends StatefulWidget {
  final int level;
  const LevelTopicsPage({Key? key, required this.level}) : super(key: key);

  @override
  _LevelTopicsPageState createState() => _LevelTopicsPageState();
}

class _LevelTopicsPageState extends State<LevelTopicsPage> {
  late Future<List<Category>> futureCategories;
    bool allCompleted = false; 

  @override
  void initState() {
    super.initState();
    futureCategories = ApiService.getTopicsByLevel( widget.level);
  }

    void checkCompletion(List<Category> categories) {
    setState(() {
      allCompleted = categories.every((topic) => topic.completed);
    });
  }

  Widget _buildNavIcon({
    required IconData icon,
    required Color color,
    required bool isHome,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () {
            if (isHome) {
              // Navigate to home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else if (icon == Icons.games) {
              // Navigate to games page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            } else if (icon == Icons.emoji_events) {
              // Navigate to leaderboard/achievements (you can implement this later)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leaderboard coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: isPressed ? 1.2 : 1),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.all(isHome ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isPressed
                            ? color.withOpacity(0.5)
                            : color.withOpacity(0.3),
                        spreadRadius: isPressed ? 4 : 2,
                        blurRadius: isPressed ? 12 : 8,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isHome ? 40 : 30,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // استخدم متغير لحفظ حالة المراحل المفتوحة
    // المرحلة الأولى دائماً مفتوحة، والباقي تفتح عند إنهاء السابقة
    List<bool> unlockedLevels = List.generate(6, (i) => i == 0);

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E88E5),
                  Color(0xFF0D47A1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'title here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Level list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: FutureBuilder<List<Category>>(
                          future: futureCategories,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}',
                                      style: TextStyle(color: Colors.white)));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text('No levels found.',
                                      style: TextStyle(color: Colors.white)));
                            }

                            final categories = snapshot.data!;
                             WidgetsBinding.instance.addPostFrameCallback((_) {
    // تحديث الحالة إذا تغيرت القيمة لتجنب النداء المتكرر
    final completed = categories.every((topic) => topic.completed);
    if (completed != allCompleted) {
      setState(() {
        allCompleted = completed;
      });
    }
  });

                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                   bool isUnlocked = category.unlocked; // استخدم قيمة "unlocked" من الباكيند

                                double progress = category.progress / 100.0;

                                return GestureDetector(
                                  onTap: isUnlocked
                                      ? () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LevelDetailPage(
                                                levelIndex: index,
                                                levelTitle:
                                                    'Category: ${category.name}',
                                                isLevelCompleted:
                                                    progress >= 1.0,
                                                categoryId: category.id,
                                              ),
                                            ),
                                          );
                                         if (result == true) {

    setState(() {
   futureCategories = ApiService.getTopicsByLevel( widget.level);
  });
  }
}
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: (category.image == null || category.image!.isEmpty) 
        ? Colors.amber 
        : null,  // اللون البرتقالي فقط لو ما في صورة
    image: (category.image != null && category.image!.isNotEmpty)
        ? DecorationImage(
            image: NetworkImage('http://127.0.0.1:8000/storage/${category.image!}'),
            fit: BoxFit.cover,
          )
        : null, // بدون صورة لو null أو فارغة
  ),
),

                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Level ${category.level}: ${category.name}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: progress,
                                                      backgroundColor:
                                                          Colors.blue[900],
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.green),
                                                      minHeight: 8,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 8,
                                                          offset: Offset(0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.star,
                                                            color:
                                                                Colors.yellow,
                                                            size: 16),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          '${category.stars}',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '${category.progress.toStringAsFixed(0)}%',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              isUnlocked
                                                  ? Icons.lock_open
                                                  : Icons.lock,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              if (allCompleted) Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
  child: ElevatedButton(
    onPressed: () async {
      // 
      final levelId = widget.level;

      // التنقل إلى صفحة QuizPage مع تمرير levelId
      await Navigator.push(
        context,
        MaterialPageRoute(
builder: (context) => QuizPage(levelId: levelId),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4A4A4A),
      minimumSize: const Size(200, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      elevation: 8,
    ),
    child: const Text(
      'Done?',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

                  // Bottom navigation
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavIcon(
                          icon: Icons.emoji_events,
                          color: Colors.cyan,
                          isHome: false,
                        ),
                        _buildNavIcon(
                          icon: Icons.home,
                          color: Colors.cyan,
                          isHome: true,
                        ),
                        _buildNavIcon(
                          icon: Icons.games,
                          color: Colors.cyan,
                          isHome: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
