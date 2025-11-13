import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Wait 2.5 seconds before starting fade out
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Start fade out animation
    if (mounted) {
      _animationController.forward();
    }
    
    // Wait for fade animation to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    // Check if user is already logged in
    final isLoggedIn = await StorageService.isLoggedIn();
    
    if (isLoggedIn) {
      // User is logged in, get username and go to home
      final username = await StorageService.getUsername();
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/home',
          arguments: {'username': username ?? 'User'}
        );
      }
    } else {
      // User is not logged in, go to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SizedBox(
                width: size.width * 0.6,
                height: size.width * 0.6,
                child: Image.asset(
                  'Assets/logo/proto.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading logo: $error');
                    return Container(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}