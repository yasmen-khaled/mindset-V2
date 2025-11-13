import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;
  Timer? _autoSwipeTimer;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Welcome to Mindset',
      description: 'Your journey to mental wellness starts here',
      svgPath: 'Assets/onbording/line.svg',
      imageScale: 2.0,
      imageTop: 0.35,
      imageLeft: 0,
      imageWidth: 1.3,
      imageHeight: 0.4,
      imageAlignment: Alignment.center,
    ),
    OnboardingItem(
      title: 'Track Your Progress',
      description: 'Monitor your mental health journey with easy-to-use tools',
      svgPath: 'Assets/onbording/level1.svg',
      imageScale: 1.0,
      imageTop: 0.35,
      imageLeft: -50,
      imageWidth: 1.0,
      imageHeight: 0.45,
      imageAlignment: Alignment.center,
    ),
    OnboardingItem(
      title: 'Daily Exercises',
      description: 'Access a variety of mental wellness exercises',
      svgPath: 'Assets/onbording/image2.svg',
      imageScale: 1.1,
      imageTop: 0.35,
      imageLeft: 0,
      imageWidth: 1.0,
      imageHeight: 0.45,
      imageAlignment: Alignment.center,
    ),
    OnboardingItem(
      title: 'Community Support',
      description: 'Connect with others on similar journeys',
      imagePath: 'Assets/onbording/s2.png',
      imageScale: 1.1,
      imageTop: 0.35,
      imageLeft: 0,
      imageWidth: 1.0,
      imageHeight: 0.45,
      imageAlignment: Alignment.center,
    ),
    OnboardingItem(
      title: 'Ready to Begin?',
      description: '',
      svgPath: 'Assets/onbording/new.svg',
      imageScale: 1.5,
      imageTop: 0.1,
      imageLeft: -20,
      imageWidth: 1.0,
      imageHeight: 0.50,
      imageAlignment: Alignment.center,
      titleTop: 0.2,
      titleLeft: 94,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSwipe();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSwipeTimer?.cancel();
    super.dispose();
  }

  void _startAutoSwipe() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _pages.length - 1 && mounted) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = _currentPage == _pages.length - 1;
    });
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLoadingPlaceholder(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget buildSvgWithFallback(String svgPath, {double? width, double? height}) {
    return SvgPicture.asset(
      svgPath,
      width: width,
      height: height,
      placeholderBuilder: (context) =>
          _buildLoadingPlaceholder(MediaQuery.of(context).size),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading SVG: $error for $svgPath');
        return Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.1),
          child: const Icon(Icons.image_not_supported,
              size: 24, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Page View
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              physics: const PageScrollPhysics(), // Enable swiping left/right
              itemBuilder: (context, index) {
                return OnboardingPage(
                  item: _pages[index],
                  isLastPage: _currentPage == _pages.length - 1,
                );
              },
            ),

            // Skip button (only show if not on last page)
            if (!_isLastPage)
              Positioned(
                top: 70,
                right: 20,
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Page indicator dots
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Created by Protobyte',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String? svgPath;
  final String? imagePath;
  final double? imageScale;
  final double? imageTop;
  final double? imageLeft;
  final double? imageWidth;
  final double? imageHeight;
  final Alignment? imageAlignment;
  final double? titleTop;
  final double? titleLeft;

  OnboardingItem({
    required this.title,
    required this.description,
    this.svgPath,
    this.imagePath,
    this.imageScale = 1.0,
    this.imageTop = 0.35,
    this.imageLeft = -20,
    this.imageWidth = 0.9,
    this.imageHeight = 0.4,
    this.imageAlignment = Alignment.centerLeft,
    this.titleTop,
    this.titleLeft,
  }) : assert(svgPath != null || imagePath != null,
            'Either svgPath or imagePath must be provided');
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final bool isLastPage;

  const OnboardingPage({
    super.key,
    required this.item,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('Assets/background/_splash.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.05,
        ),
        child: Stack(
          children: [
            // Text at top with responsive positioning
            Positioned(
              top: size.height * (item.titleTop ?? 0.25),
              left: size.width *
                  (item.titleLeft != null
                      ? item.titleLeft! / size.width
                      : 0.05),
              right: size.width * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  if (item.description.isNotEmpty) ...[
                    SizedBox(height: size.height * 0.02),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
            // Image with improved error handling
            Positioned(
              top: size.height * (item.imageTop ?? 0.35),
              left: item.imageLeft != null
                  ? size.width * (item.imageLeft! / size.width)
                  : 0,
              right: 0,
              child: SizedBox(
                height: size.height * (item.imageHeight ?? 0.4),
                width: size.width * (item.imageWidth ?? 1.0),
                child: Transform.scale(
                  scale: item.imageScale ?? 1.0,
                  child: Align(
                    alignment: item.imageAlignment ?? Alignment.centerLeft,
                    child: item.svgPath != null && item.svgPath!.isNotEmpty
                        ? SvgPicture.asset(
                            item.svgPath!,
                            fit: BoxFit.contain,
                            width: size.width * (item.imageWidth ?? 1.0),
                            height: size.height * (item.imageHeight ?? 0.4),
                            alignment: item.imageAlignment ?? Alignment.center,
                            placeholderBuilder: (context) =>
                                _buildLoadingPlaceholder(size),
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading SVG: $error for ${item.svgPath}');
                              return _buildErrorPlaceholder(size);
                            },
                          )
                        : item.imagePath != null
                            ? Image.asset(
                                item.imagePath!,
                                fit: BoxFit.contain,
                                width: size.width * (item.imageWidth ?? 1.0),
                                height: size.height * (item.imageHeight ?? 0.4),
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading image: $error');
                                  return _buildErrorPlaceholder(size);
                                },
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // Start button on last page with improved styling
            if (isLastPage)
              Positioned(
                bottom: size.height * 0.15,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: size.width * 0.6,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.1),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2B8DDC),
                          Color(0xFF1A5C9A),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        borderRadius: BorderRadius.circular(size.width * 0.1),
                        child: Center(
                          child: Text(
                            'START',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(Size size) {
    return Container(
      width: size.width * 0.5,
      height: size.width * 0.5,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(Size size) {
    return Container(
      width: size.width * 0.5,
      height: size.width * 0.5,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: size.width * 0.15,
        ),
      ),
    );
  }
}
