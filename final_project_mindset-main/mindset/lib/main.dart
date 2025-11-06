import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindset/pages/home.dart';
import 'package:mindset/pages/splash.dart';
import 'package:mindset/pages/onboarding.dart';
import 'package:mindset/pages/home9.dart';
import 'package:mindset/pages/games.dart';
import 'package:mindset/pages/memory_game.dart';
import 'package:mindset/pages/login.dart';
import 'package:mindset/pages/SignUp.dart';
import 'package:mindset/pages/Repassword.dart';
import 'package:mindset/pages/simple_reset.dart';
import 'package:mindset/pages/welcome.dart';
import 'package:mindset/pages/selection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set system UI mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.leanBack,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindset',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 183, 154, 58)),
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: "/onboarding",
      routes: {
        "/splash": (context) => const Splash(),
        "/onboarding": (context) => const Onboarding(),
        "/home": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return HomePage(username: username);
        },
        "/games": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return GamesPage(username: username);
        },
        "/memory-game": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return MemoryGamePage(username: username);
        },
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignUpPage(),
        "/forgot-password": (context) => const ResetPasswordPage(),
        "/simple-reset": (context) => const SimpleResetPage(),
        "/selection": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return SelectionPage(username: username);
        },
        "/welcome": (context) => const WelcomePage(username: '', gender: ''),
      },
    );
  }
}