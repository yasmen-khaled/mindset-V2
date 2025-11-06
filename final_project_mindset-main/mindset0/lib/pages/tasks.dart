import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindset/pages/home.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'Quiz.dart'; // Import QuizPage instead
import 'games.dart'; // Import GamesPage
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class LevelDetailPage extends StatefulWidget {
  final int levelIndex;
  final String levelTitle;
  final bool isLevelCompleted;
  final int categoryId;
  final int completedTasksCount; // Number of completed tasks

  const LevelDetailPage({
    Key? key,
    required this.levelIndex,
    required this.levelTitle,
    this.isLevelCompleted = false,
    required this.categoryId,
    this.completedTasksCount = 0, // Default to 0 completed tasks
  }) : super(key: key);

  @override
  State<LevelDetailPage> createState() => _LevelDetailPageState();
}

class _LevelDetailPageState extends State<LevelDetailPage> {
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = ApiService.fetchTasks(widget.categoryId);
  }

  int _selectedIndex = 1; // Start with home selected

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

void debugSvgContent(String url) async {
  final response = await http.get(Uri.parse(url));
  print('SVG Content: ${response.body}');
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
              // Back button and title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                    Expanded(
                      child: Text(
                        widget.levelTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Level content
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
                    child: FutureBuilder<List<Task>>(
                      future: futureTasks,
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
                              child: Text('No tasks found.',
                                  style: TextStyle(color: Colors.white)));
                        }

                        final tasks = snapshot.data!;
                        return ListView.builder(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            bool isUnlocked =
                                task.unlocked;
                                

                            double progress = task.completed ? 1.0 : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: isUnlocked
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              _buildTaskDialog(context, task, tasks),
                                        );
                                      }
                                    : null,
                                child: Opacity(
                                  opacity: isUnlocked ? 1.0 : 0.5,
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade700,
                                          Colors.blue.shade900,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.5)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.3),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.greenAccent),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 20),
                                                SizedBox(width: 4),
                                                Text(
                                                  task.stars?.toString() ?? '0', // Placeholder for stars
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${(progress * 100).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            task.completed
                                                ? Icon(Icons.check_circle,
                                                    color: Colors.greenAccent)
                                                : Icon(Icons.lock,
                                                    color: Colors.white),
                                          ],
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

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.leaderboard,
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onNavTap(0)),
                    _buildNavButton(Icons.home,
                        isSelected: _selectedIndex == 1,
                        isHome: true,
                        onTap: () => _onNavTap(1)),
                    _buildNavButton(Icons.games,
                        isSelected: _selectedIndex == 2,
                        onTap: () => _onNavTap(2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDialog(BuildContext context, Task task, List<Task> tasks)
 {   
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[900]?.withOpacity(0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              task.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple[400]?.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow, size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: task.completed ? 1.0 : 0.0,
                      backgroundColor: Colors.blue[900],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(width: 8),
                  SvgPicture.asset(
                    'Assets/items/smart.svg',
                    width: 22,
                    height: 22,
                  ),
                  SizedBox(width: 2),
                  Text( task.stars?.toString() ?? '0',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold)), // Placeholder for stars
                  SizedBox(width: 8),
                  Text('${(task.completed ? 100 : 0)}%',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(6),
                      color: task.completed ? Colors.green : Colors.transparent,
                    ),
                    child: task.completed
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 24),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
  padding: const EdgeInsets.all(8.0),
  child: (task.avatar != null && task.avatar!.isNotEmpty)
      ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SvgPicture.network(
  'http://127.0.0.1:8000/storage/task-avatars/MIqqKGlhOVdUeMGs69d9LY0X0x4b6DZT2RKWRKBg.svg',
  placeholderBuilder: (context) => CircularProgressIndicator(),
  height: 100,
)
        )
      : SvgPicture.asset(
          'Assets/charcters/nadir.svg',
          width: 44,
          height: 44,
        ),
),

                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${task.hint}!',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 20),


 GestureDetector(
  onTap: () async {
    if (!task.completed) {
      bool success = await ApiService.markTaskCompleted(task.id);
      if (success) {
        setState(() {
          task.completed = true;

          int currentIndex = tasks.indexOf(task);
          if (currentIndex + 1 < tasks.length) {
            tasks[currentIndex + 1].unlocked = true;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark task as completed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  
                if (task.videoUrl != null && task.videoUrl!.isNotEmpty) {
                  final uri = Uri.parse(task.videoUrl!);
                  if (!await launchUrl(uri)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not launch video'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Opacity(
                opacity: (task.videoUrl != null && task.videoUrl!.isNotEmpty)
                    ? 1.0
                    : 0.5,
                child: Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (task.image != null && task.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                'http://127.0.0.1:8000/storage/${task.image!}',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            // بديل في حال لا توجد صورة
            Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.purple.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.blue[900],
                          size: 30,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '5:42', // Placeholder
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                task.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
