import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home.dart';
import 'home_tmazight.dart';
import 'home_academic.dart';

class HomeRouter extends StatelessWidget {
  final String username;

  const HomeRouter({super.key, required this.username});

  Future<Widget> _resolveHome() async {
    final prefs = await StorageService.getUserPreferences();
    final path = prefs['learning_path'] ?? 'software_engineering';
    switch (path) {
      case 'tmazight_language':
        return TmazightHomePage(username: username);
      case 'academic_courses':
        return AcademicHomePage(username: username);
      default:
        return HomePage(username: username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveHome(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        return snapshot.data!;
      },
    );
  }
}


 