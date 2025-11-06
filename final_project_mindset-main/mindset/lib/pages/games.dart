import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindset/pages/home.dart';

class GamesPage extends StatefulWidget {
  final String username;
  
  const GamesPage({super.key, this.username = 'User'});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class GameOption {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final bool isLocked;

  GameOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLocked = false,
  });
}

class _GamesPageState extends State<GamesPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedIndex = 2; // Games is selected
  PageController _pageController = PageController();
  int _currentGameIndex = 0;
  int _userLevel = 5; // Current user level (can be changed to test unlocking)

  List<GameOption> get _games => [
    GameOption(
      title: 'Memory Game',
      description: '50 points per level',
      icon: 'memory',
      color: const Color(0xFF4FC3F7),
    ),
    GameOption(
      title: 'Logic Maze',
      description: '75 points per level',
      icon: 'psychology',
      color: const Color(0xFF9C27B0),
    ),
    GameOption(
      title: 'Code Quest',
      description: '100 points per level',
      icon: 'code',
      color: const Color(0xFF795548),
      isLocked: _userLevel < 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 1) {
      // Navigate back to home
     Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
      return;
    
    }
    
    if (index == 0) {
      _showLeaderboard(context);
      return;
    }
  }

  void _showLeaderboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Leaderboard coming soon!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue.withOpacity(0.7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/background/game-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Dark overlay for better readability
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.4),
            ),
            
            SafeArea(
              child: Column(
                children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Hello, ${widget.username}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Main title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Text(
                  'GAMES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Color(0xFF4FC3F7),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Game slides with navigation arrows
              Expanded(
                child: Stack(
                  children: [
                    // PageView
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      allowImplicitScrolling: true,
                      onPageChanged: (index) {
                        setState(() {
                          _currentGameIndex = index;
                        });
                      },
                      itemCount: _games.length,
                      itemBuilder: (context, index) {
                        final game = _games[index];
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                          child: _buildGameCard(game),
                        );
                      },
                    ),
                    
                    // Left arrow
                    if (_currentGameIndex > 0)
                      Positioned(
                        left: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF4FC3F7).withOpacity(0.8),
                                    const Color(0xFF2196F3).withOpacity(0.6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4FC3F7).withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Right arrow
                    if (_currentGameIndex < _games.length - 1)
                      Positioned(
                        right: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF4FC3F7).withOpacity(0.8),
                                    const Color(0xFF2196F3).withOpacity(0.6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4FC3F7).withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page indicator with swipe hint
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Navigation hint text
                    Text(
                      'Use arrows or swipe to explore games',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_games.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentGameIndex == index ? 30 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentGameIndex == index 
                              ? const Color(0xFF4FC3F7)
                              : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: _currentGameIndex == index ? [
                              BoxShadow(
                                color: const Color(0xFF4FC3F7).withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ] : [],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(
                      Icons.emoji_events_outlined,
                      isSelected: _selectedIndex == 0,
                      onTap: () => _onNavTap(0),
                    ),
                    _buildNavButton(
                      Icons.home_rounded,
                      isSelected: _selectedIndex == 1,
                      isHome: true,
                      onTap: () => _onNavTap(1),
                    ),
                    _buildNavButton(
                      Icons.sports_esports_rounded,
                      isSelected: _selectedIndex == 2,
                      onTap: () => _onNavTap(2),
                    ),
                  ],
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

  Widget _buildGameCard(GameOption game) {
    IconData iconData;
    switch (game.icon) {
      case 'code':
        iconData = Icons.code;
        break;
      case 'psychology':
        iconData = Icons.psychology;
        break;
      case 'memory':
        iconData = Icons.memory;
        break;
      default:
        iconData = Icons.games;
    }

    return GestureDetector(
      onTap: game.isLocked ? null : () {
        _startGame(game);
      },
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // Circular game icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: game.isLocked 
                ? LinearGradient(
                    colors: [Colors.grey.withOpacity(0.4), Colors.grey.withOpacity(0.2)],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [game.color.withOpacity(0.8), game.color.withOpacity(0.6)],
                  ),
              border: Border.all(
                color: game.isLocked 
                  ? Colors.grey.withOpacity(0.5)
                  : game.color.withOpacity(0.8),
                width: 3,
              ),
              boxShadow: game.isLocked ? [] : [
                BoxShadow(
                  color: game.color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    iconData,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                if (game.isLocked)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game title
          Text(
            game.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Points description
          Text(
            game.isLocked ? 'Unlock at Level 7' : game.description,
            style: TextStyle(
              color: game.isLocked ? Colors.grey[400] : Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
                     ),
         ],
       ),
     ),
     );
  }

  void _showGameDetail(GameOption game) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [game.color.withOpacity(0.9), game.color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: game.color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: game.color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  game.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  game.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'BACK',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startGame(game);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startGame(GameOption game) {
    if (game.title == 'Memory Game') {
      Navigator.pushNamed(
        context, 
        '/memory-game',
        arguments: {'username': widget.username},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${game.title} is coming soon!',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: game.color.withOpacity(0.8),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      );
    }
  }

  Widget _buildNavButton(IconData icon, {bool isSelected = false, bool isHome = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isHome ? 20 : 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isHome ? 25 : 20),
          border: Border.all(
            color: isSelected 
              ? const Color.fromARGB(255, 33, 150, 243)
              : Colors.white.withOpacity(0.2),
            width: isHome ? 2 : 1,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white,
          size: isHome ? 32 : 28,
        ),
      ),
    );
  }
} 