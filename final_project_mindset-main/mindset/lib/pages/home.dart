import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindset/services/api_service.dart';
import '../services/storage_service.dart';
import '../models/leaderBoard.dart';
import 'games.dart';
import 'catagory.dart';
import 'home_academic.dart';
import 'home_tmazight.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, this.username = 'User'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class FloatingButton extends StatefulWidget {
  final double left;
  final double top;
  final int buttonNumber;
  final int currentLevel;
  final Color color;
  //final VoidCallback onLevelComplete;
  final Function(int) onSpecificLevelComplete;

  const FloatingButton({
    Key? key,
    required this.left,
    required this.top,
    required this.buttonNumber, 
    required this.currentLevel,
    //required this.onLevelComplete,
    required this.onSpecificLevelComplete,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = widget.buttonNumber <= widget.currentLevel;
  
print("🔹 بناء الزر رقم ${widget.buttonNumber} | currentLevel = ${widget.currentLevel} | isUnlocked = $isUnlocked");

       
    double opacity = isUnlocked ? 1.0 : 0.15;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: widget.top + (isUnlocked ? _animation.value : 0),
          child: GestureDetector(
            onTap: isUnlocked
                ? () {
                    // Navigate to category page for this level
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LevelTopicsPage(level: widget.buttonNumber),
                      ),
                    ).then((result) {
                      // If level was completed, trigger level unlock with the specific level number
                      if (result != null && result is int) {
                        widget.onSpecificLevelComplete(result);
                      }
                    });
                  }
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Extreme outer glow
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(12, 33, 149, 243)
                            .withOpacity(0.08 * opacity),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
                // Outer glow layer
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(36, 33, 149, 243)
                            .withOpacity(0.12 * opacity),
                        blurRadius: 60,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
                // Middle glow layer
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.2 * opacity),
                        Colors.blue.withOpacity(0.1 * opacity),
                        Colors.transparent,
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(38, 33, 149, 243)
                            .withOpacity(0.15 * opacity),
                        blurRadius: 50,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                ),
                // Inner bright layer
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.25 * opacity),
                        Colors.blue.withOpacity(0.15 * opacity),
                        Colors.blue.withOpacity(0.08 * opacity),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 0.4, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1 * opacity),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Core glow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3 * opacity),
                        Colors.blue.withOpacity(0.2 * opacity),
                        Colors.transparent,
                      ],
                      stops: const [0.2, 0.5, 1.0],
                    ),
                  ),
                ),
                // Lock icon (only show if locked)
                if (!isUnlocked)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 33, 149, 243)
                            .withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 33, 149, 243)
                              .withOpacity(0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 33, 149, 243)
                                .withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.9),
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


/*


class LeaderboardUser {
  final String name;
  final int stars;
  final int level;
  final String rank;
  final String avatar;
  final int problemsSolved;
  final int daysStreak;
  final List<String> achievements;

  LeaderboardUser({
    required this.name,
    required this.stars,
    required this.level,
    required this.rank,
    required this.avatar,
    this.problemsSolved = 0,
    this.daysStreak = 0,
    this.achievements = const [],
  });
}*/

class AvatarSkin {
  final String image;
  final String name;
  bool isUnlocked;
  final int cost;

  AvatarSkin({
    required this.image,
    required this.name,
    required this.isUnlocked,
    required this.cost,
  });
}

class TeamMember {
  final String name;
  final String skills;
  final String role;
  final int superpower;
  final String svgPath;
  final String description;

  TeamMember({
    required this.name,
    required this.skills,
    required this.role,
    required this.superpower,
    required this.svgPath,
    required this.description,
  });
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _selectedIndex = 1; // Start with home selected
  late Map<String, dynamic> userData = {};
  int star = 0;
  int hearts = 0;
  
   String rank = 'Beginner';
   String avatar = 'Assets/items/default_avatar.svg';
   int problemsSolved = 0;
   int daysStreak = 0;
   int score = 0;
   List<String> achievements = const [];
    late String currentUsername;
  late  List<LeaderboardUser> leaderboardUsers = [];


  // Level state management
  int currentLevel = 1; // Start with level 1 unlocked

  // Keep track of the last positions
  double button1Left = 180.0;
  double button1Top = 600.0;

  double button2Left = 80.0;
  double button2Top = 450.0;

  double button3Left = 110.0;
  double button3Top = 320.0;

  double button4Left = 250.0;
  double button4Top = 219.0;

  double button5Left = 129.00;
  double button5Top = 150.0;

  double button6Left = 1.0;
  double button6Top = 40.0;

  double button7Left = 129.0;
  double button7Top = 30.0;

  // Update the leaderboard users with programming theme

  // Avatar skins
  final List<AvatarSkin> avatarSkins = [
    AvatarSkin(
      image: 'Assets/items/avatar1.png',
      name: 'Default',
      isUnlocked: true,
      cost: 0,
    ),
    AvatarSkin(
      image: 'Assets/items/avatar2.png',
      name: 'Ninja',
      isUnlocked: false,
      cost: 100,
    ),
    AvatarSkin(
      image: 'Assets/items/avatar3.png',
      name: 'Warrior',
      isUnlocked: false,
      cost: 200,
    ),
    AvatarSkin(
      image: 'Assets/items/avatar4.png',
      name: 'Mage',
      isUnlocked: false,
      cost: 300,
    ),
    AvatarSkin(
      image: 'Assets/items/avatar5.png',
      name: 'Robot',
      isUnlocked: false,
      cost: 400,
    ),
  ];

  // Add color options for cover
  final List<Color> coverColors = [
    const Color(0xFF51B7FF), // Default blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF795548), // Brown
  ];

  int selectedColorIndex = 0; // Track selected color
  int selectedSkinIndex = 0; // Track selected skin

  final List<TeamMember> teamMembers = [
    TeamMember(
      name: 'Nadir Al Hajji',
      skills: 'Flutter, UI/UX, Animation',
      role: 'Lead Developer',
      superpower: 40,
      svgPath: 'Assets/charcters/nadir.svg',
      description:
          'A passionate developer with a keen eye for design and user experience. Specializes in creating beautiful and performant Flutter applications.',
    ),
    TeamMember(
      name: 'Muhanad',
      skills: 'Backend, System Architecture',
      role: 'Backend Developer',
      superpower: 38,
      svgPath: 'Assets/charcters/muhanad.svg',
      description:
          'Expert in building robust backend systems and optimizing server performance. Masters complex architectural challenges with elegant solutions.',
    ),
    TeamMember(
      name: 'Ajwad',
      skills: 'Mobile Dev, API Integration',
      role: 'Mobile Developer',
      superpower: 39,
      svgPath: 'Assets/charcters/ajwad.svg',
      description:
          'Skilled mobile developer with expertise in API integration and state management. Creates seamless user experiences across platforms.',
    ),
    TeamMember(
      name: 'Nada',
      skills: 'UI Design, User Research',
      role: 'UI/UX Designer',
      superpower: 42,
      svgPath: 'Assets/charcters/nada.svg',
      description:
          'Creative designer who combines aesthetics with functionality. Expert in user research and creating intuitive interfaces that users love.',
    ),
    TeamMember(
      name: 'Yasmena',
      skills: 'Frontend, Animation , Ui/Ux, Artist',
      role: 'Frontend Developer',
      superpower: 100,
      svgPath: 'Assets/charcters/yasmena.svg',
      description:
          'Frontend specialist with a passion for creating smooth animations and responsive designs. Brings websites to life with dynamic interactions.',
    ),
    TeamMember(
      name: 'Lujaina',
      skills: 'Product Strategy, UX',
      role: 'Product Manager',
      superpower: 41,
      svgPath: 'Assets/charcters/lujaina.svg',
      description:
          'Strategic product manager who bridges user needs with business goals. Expert in creating roadmaps and delivering successful products.',
    ),
    TeamMember(
      name: 'Maram',
      skills: 'Testing, Quality Assurance',
      role: 'QA Engineer',
      superpower: 36,
      svgPath: 'Assets/charcters/maram.svg',
      description:
          'Detail-oriented QA engineer ensuring the highest quality standards. Specializes in automated testing and bug prevention.',
    ),
    TeamMember(
      name: 'Hiba',
      skills: 'DevOps, Cloud Infrastructure',
      role: 'DevOps Engineer',
      superpower: 40,
      svgPath: 'Assets/charcters/hiba.svg',
      description:
          'DevOps expert managing cloud infrastructure and deployment pipelines. Ensures smooth operation and scalability of systems.',
    ),
  ];

  int _currentTeamMemberIndex = 0;

  @override
  void initState() {
    super.initState();

    _fetchUserProfile();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      
    );
   
 ApiService.fetchHighestUnlockedLevel().then((level) {
    setState(() {
     print("  ✅ fetch sent ${level}");
      currentLevel = level;
    });
  });

    _initializeUser();
  }

void _buyLifePackage(int starsCost, int livesToAdd) async {
  bool success = await ApiService.buyHearts(
    starsToSpend: starsCost,
    heartsToAdd: livesToAdd,
  );

  if (success) {
    setState(() {
     _fetchUserProfile();
    });
   
  } 
}void _fetchUserProfile() async {
  try {
    leaderboardUsers = await ApiService.fetchLeaderboard();

    LeaderboardUser? thisuser;

    try {
      thisuser = leaderboardUsers.firstWhere(
        (user) => user.name.toLowerCase() == currentUsername.toLowerCase(),
      );
    } catch (e) {
      thisuser = null; // إذا لم يتم العثور على المستخدم
    }

    if (thisuser != null) {
      final achievementsRaw = thisuser.achievements;

      setState(() {

        star = thisuser!.stars;
        rank = thisuser!.rank;
        achievements = (achievementsRaw is List)
            ? achievementsRaw.whereType<String>().toList()
            : <String>[];
        
        problemsSolved = thisuser.problemsSolved;
        avatar = thisuser.avatar;
        score = thisuser.score.toInt();
        hearts = thisuser.daysStreak;
        

        userData = {
          'achievements': achievements,
          'rank': rank,
          'problemsSolved': problemsSolved,
          'star': star,
          'heart': hearts,
          'avatar': avatar,
          'score': score,
          // أضف بيانات أخرى حسب الحاجة
        };
      });
    } else {
      print('User "$currentUsername" not found in leaderboard');
    }
  } catch (e) {
    print('Failed to fetch leaderboard: $e');
  }
}



  void _initializeUser() async {
    // Get username from storage if not provided or is default
   {
      String? storedUsername = await StorageService.getUsername();
      if (storedUsername != null && storedUsername.isNotEmpty) {
        currentUsername = storedUsername;
      }
    }

    // Initialize leaderboard users with actual username
    /*_leaderboardUsers = [
      LeaderboardUser(
        name: currentUsername,
        stars: 250,
        level: 7,
        rank: "Code Master",
        avatar: "Assets/items/smart.svg",
        problemsSolved: 145,
        daysStreak: 30,
        achievements: ["Algorithm Master", "30 Days Streak", "Problem Solver"],
      ),
      LeaderboardUser(
        name: "Alex Kumar",
        stars: 245,
        level: 7,
        rank: "Algorithm Expert",
        avatar: "Assets/items/smart.svg",
        problemsSolved: 140,
        daysStreak: 25,
        achievements: ["Quick Learner", "Code Ninja", "Early Bird"],
      ),
      LeaderboardUser(
        name: "Maria Garcia",
        stars: 220,
        level: 6,
        rank: "Problem Solver",
        avatar: "Assets/items/smart.svg",
      ),
      LeaderboardUser(
        name: "James Wilson",
        stars: 200,
        level: 6,
        rank: "Code Explorer",
        avatar: "Assets/items/smart.svg",
      ),
      LeaderboardUser(
        name: "Emma Zhang",
        stars: 190,
        level: 5,
        rank: "Rising Coder",
        avatar: "Assets/items/smart.svg",
      ),
    ];*/

    // Update the state to refresh UI with correct username
    if (mounted) {
      setState(() {});
    }
  }

 /* void _showHibaWelcome() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.purple[900]?.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.purple[300]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiba's character
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    'Assets/charcters/hiba.svg',
                    width: 68,
                    height: 68,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Welcome message
              Text(
                'Amazing Achievement!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Hi ${leaderboardUsers.isNotEmpty ? leaderboardUsers[0].name : widget.username}! I\'m Hiba, and I\'m so proud of you!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'You\'ve completed ALL categories and mastered every skill! You\'ve shown incredible dedication and growth. You\'re now ready for any challenge life brings your way!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Thank You!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      showLeaderboard(context);
      return;
    }

    if (index == 2) {
      // Navigate to games page

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamesPage(username: currentUsername),
        ),
      );
      return;
    }

    // Show feedback dialog
    String message = '';
    switch (index) {
      case 1:
        message = 'You are home!';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue.withOpacity(0.7),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

 Future<void> showLeaderboard(BuildContext context) async {
  //List<LeaderboardUser> leaderboardUsers = [];
  try {
    leaderboardUsers = await ApiService.fetchLeaderboard();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading leaderboard: $e')),
    );
    return;
  }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sparkle effect background
                ...List.generate(20, (index) {
                  return Positioned(
                    left: Random().nextDouble() *
                        MediaQuery.of(context).size.width *
                        0.8,
                    top: Random().nextDouble() *
                        MediaQuery.of(context).size.height *
                        0.6,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: SvgPicture.asset(
                              'Assets/items/blue_star.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Top Learners',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Leaderboard list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: leaderboardUsers.length,
                        itemBuilder: (context, index) {
                          final user = leaderboardUsers[index];
                          final isTop3 = index < 3;

                          return GestureDetector(
                            onTap: () => _showUserProfile(context, user),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isTop3
                                        ? const Color(0xFF64B5F6)
                                            .withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withOpacity(0.2),
                                        border: Border.all(
                                          color: isTop3
                                              ? const Color(0xFF64B5F6)
                                              : Colors.blue.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          user.avatar,
                                          width: 30,
                                          height: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (isTop3)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF64B5F6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Level ${user.level} • ${user.rank}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                        'Assets/items/blue_star.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${user.stars}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.blue.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
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
                      ),
                    ),
                  ],
                ),

                // Close button
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserProfile(BuildContext context, LeaderboardUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            user.avatar,
                            width: 50,
                            height: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user.rank,
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: 'Assets/items/blue_star.svg',
                        value: user.stars.toString(),
                        label: 'Stars',
                      ),
                      _buildStatItem(
                        icon: 'Assets/items/smart.svg',
                        value: user.problemsSolved.toString(),
                        label: 'Problems',
                      ),
                      _buildStatItem(
                        icon: 'Assets/items/life.svg',
                        value: user.daysStreak.toString(),
                        label: 'Streak',
                      ),
                    ],
                  ),
                ),

                // Achievements Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.achievements.map((achievement) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              achievement,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Close Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: SvgPicture.asset(
            icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedButton(double left, double top, int buttonNumber,
      {Color color = Colors.blue}) {
    return FloatingButton(
      left: left,
      top: top,
      buttonNumber: buttonNumber,
      currentLevel: currentLevel,
      color: color,
      //onLevelComplete: unlockNextLevel,
      onSpecificLevelComplete: unlockSpecificLevel,
    );
  }



  // Method to unlock a specific level and show Hiba's popup only when all levels are completed
  void unlockSpecificLevel(int levelNumber) {
    _fetchUserProfile();
    setState(() {
  ApiService.fetchHighestUnlockedLevel().then((level) {
    setState(() {
     print("fetch sent ${level}");
      currentLevel = level;
    });
  });
    });
  }

  void _showProfileSettings(BuildContext context) {
    final user = leaderboardUsers[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Cover and Header
                  Container(
                    height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        coverColors[selectedColorIndex],
                        coverColors[selectedColorIndex].withOpacity(0.5),
                        coverColors[selectedColorIndex].withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Color Selection Row
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Cover Color',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    coverColors.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final color = entry.value;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedColorIndex = index;
                                      });
                                      Navigator.pop(context);
                                      _showProfileSettings(context);
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selectedColorIndex == index
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // User Info
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  user.avatar,
                                  width: 50,
                                  height: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                   currentUsername,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          userData['rank'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Edit name button
                                      GestureDetector(
                                        onTap: () {
                                          // Show edit name dialog
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              final TextEditingController
                                                  nameController =
                                                  TextEditingController(
                                                      text: currentUsername);
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF0A1832)
                                                            .withOpacity(0.95),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: Colors.blue
                                                          .withOpacity(0.3),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Edit Name',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      TextField(
                                                        controller:
                                                            nameController,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Enter new name',
                                                          hintStyle: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.5)),
                                                          filled: true,
                                                          fillColor: Colors
                                                              .white
                                                              .withOpacity(0.1),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red
                                                                      .withOpacity(
                                                                          0.1),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          30,
                                                                      vertical:
                                                                          15),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          0.3),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              if (nameController
                                                                  .text
                                                                  .trim()
                                                                  .isNotEmpty) {
                                                                final newUsername =
                                                                    nameController
                                                                        .text
                                                                        .trim();

                                                                // Update stored username
                                                                await StorageService
                                                                    .updateUsername(
                                                                        newUsername);

                                                                        ApiService.updateUsername(newUsername);

                                                                setState(() {
                                                                  _initializeUser();
                                                                  leaderboardUsers[
                                                                          0] =
                                                                      LeaderboardUser(
                                                                    name:
                                                                        newUsername,
                                                                    stars: user
                                                                        .stars,
                                                                    level: user
                                                                        .level,
                                                                    rank: user
                                                                        .rank,
                                                                    avatar: user
                                                                        .avatar,
                                                                    problemsSolved:
                                                                        user.problemsSolved,
                                                                    daysStreak:
                                                                        user.daysStreak,
                                                                    achievements:
                                                                        user.achievements,
                                                                  );
                                                                });
                                                                Navigator.pop(
                                                                    context); // Close edit dialog
                                                                Navigator.pop(
                                                                    context); // Close settings dialog
                                                                _showProfileSettings(
                                                                    context); // Reopen settings dialog

                                                                // Show success message
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        const Text(
                                                                      'Name updated successfully!',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    backgroundColor: Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.7),
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            2),
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            100,
                                                                        left:
                                                                            50,
                                                                        right:
                                                                            50),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(25)),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  Colors.blue
                                                                      .withOpacity(
                                                                          0.2),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          30,
                                                                      vertical:
                                                                          15),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .blue
                                                                      .withOpacity(
                                                                          0.3),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Save',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
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
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
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

                // Stats Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: 'Assets/items/blue_star.svg',
                        value: userData['star'].toString(),
                        label:  'Stars',
                      ),
                      _buildStatItem(
                        icon: 'Assets/items/smart.svg',
                        value: userData['problemsSolved'].toString(),
                        label: 'Problems',
                      ),
                      _buildStatItem(
                        icon: 'Assets/items/life.svg',
                        value: userData['heart'].toString(),
                        label: 'Streak',
                      ),
                    ],
                  ),
                ),

                // Achievements Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                       children: (userData['achievements'] ?? []).map<Widget>((achievement) {

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              achievement,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Close Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Learning Path Settings
                      _buildSettingItem(
                        icon: Icons.school_outlined,
                        label: 'Learning Path',
                        onTap: () {
                          Navigator.pop(context);
                          _showLearningPathSettings(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      // App Language Settings
                      _buildSettingItem(
                        icon: Icons.language_outlined,
                        label: 'App Language',
                        onTap: () {
                          Navigator.pop(context);
                          _showLanguageSettings(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      // GitHub Repository Settings
                                      _buildSettingItem(
                                        icon: Icons.code_outlined,
                                        label: 'GitHub Repository',
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showGitHubSettings(context);
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      // App Language Settings
                                      _buildSettingItem(
                                        icon: Icons.language_outlined,
                                        label: 'App Language',
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showLanguageSettings(context);
                                        },
                                      ),
                                      const SizedBox(height: 10),


                      // Avatar Shop Button
                      _buildSettingItem(
                        icon: Icons.store_outlined,
                        label: 'Avatar Shop',
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A1832)
                                        .withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Header
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color:
                                                  Colors.blue.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.store_outlined,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Avatar Shop',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'Assets/items/blue_star.svg',
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(width: 5),
                                                 Text(
                                                  star.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Avatar Grid
                                      Expanded(
                                        child: GridView.builder(
                                          padding: const EdgeInsets.all(20),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 15,
                                            mainAxisSpacing: 15,
                                            childAspectRatio: 0.8,
                                          ),
                                          itemCount: avatarSkins.length,
                                          itemBuilder: (context, index) {
                                            final skin = avatarSkins[index];
                                            final isSelected =
                                                selectedSkinIndex == index;

                                            return GestureDetector(
                                              onTap: () => _handleSkinSelection(
                                                  context, skin, index),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.white
                                                            .withOpacity(0.2),
                                                    width: isSelected ? 2 : 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      skin.image,
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      skin.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    if (!skin.isUnlocked)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            'Assets/items/blue_star.svg',
                                                            width: 16,
                                                            height: 16,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            '${skin.cost}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (skin.isUnlocked &&
                                                        isSelected)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Text(
                                                          'Selected',
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Close button
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.withOpacity(0.2),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: Colors.blue
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Logout Button
                      _buildSettingItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: () {
                          Navigator.pop(context);
                          _handleLogout(context);
                        },
                        isDestructive: true,
                      ),
                      const SizedBox(height: 20),
                      // Close Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red.withOpacity(0.8),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Clear stored login data
                        await StorageService.clearLoginData();

                        // Show logout success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Logged out successfully!',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.green.withOpacity(0.7),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                  bottom: 100, left: 50, right: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          );
                        }

                        // Navigate to login and clear all previous routes
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        '🚪 Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _handleSkinSelection(BuildContext context, AvatarSkin skin, int index) {
    if (skin.isUnlocked) {
      setState(() {
        selectedSkinIndex = index;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Avatar changed to ${skin.name}!',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green.withOpacity(0.7),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      );
    } else {
      // Show purchase confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1832).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    skin.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    skin.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'Assets/items/blue_star.svg',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${skin.cost}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Here you would check if user has enough stars
                          // For now, we'll just unlock it
                          setState(() {
                            avatarSkins[index].isUnlocked = true;
                            selectedSkinIndex = index;
                          });
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${skin.name} unlocked and equipped!',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.green.withOpacity(0.7),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                  bottom: 100, left: 50, right: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Purchase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
  }

  void _showTeamMemberCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 39, 93, 194),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                final member = teamMembers[_currentTeamMemberIndex];
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 400;
                
                return Stack(
                  children: [
                    // Background glow effects
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: isSmallScreen ? 200 : 300,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.5,
                            colors: [
                              Colors.blue.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        // Info section at the top - made responsive
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 15 : 30, 
                            isSmallScreen ? 20 : 30, 
                            isSmallScreen ? 15 : 30, 
                            isSmallScreen ? 15 : 20
                          ),
                          child: isSmallScreen 
                            ? Column(
                                children: [
                                  // Profile image for small screens
                                  Container(
                                    width: isSmallScreen ? 100 : 150,
                                    height: isSmallScreen ? 100 : 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: isSmallScreen ? 50 : 80,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Info fields for small screens
                                  ...['Name', 'Skills', 'Role', 'Superpower'].map((label) {
                                    final value = label == 'Name' ? member.name 
                                        : label == 'Skills' ? member.skills
                                        : label == 'Role' ? member.role
                                        : member.superpower.toString();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildInfoField(label, value),
                                    );
                                  }).toList(),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile image for larger screens
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  // Info fields for larger screens
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildInfoField('Name', member.name),
                                        const SizedBox(height: 10),
                                        _buildInfoField('Skills', member.skills),
                                        const SizedBox(height: 10),
                                        _buildInfoField('Role', member.role),
                                        const SizedBox(height: 10),
                                        _buildInfoField('Superpower', member.superpower.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        ),

                        // Character SVG and Description section - made responsive
                        Expanded(
                          child: Column(
                            children: [
                              // Character SVG - responsive sizing
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 5 : 10,
                                    horizontal: isSmallScreen ? 10 : 20,
                                  ),
                                  child: SvgPicture.asset(
                                    member.svgPath,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              
                              // Description at the bottom - responsive padding and font
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color.fromARGB(0, 114, 187, 255),
                                      const Color.fromARGB(255, 31, 80, 172).withOpacity(0.9),
                                      const Color.fromRGBO(32, 90, 199, 1),
                                    ],
                                    stops: const [0.0, 0.3, 0.6],
                                  ),
                                ),
                                child: Text(
                                  member.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 14 : 18,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Page indicator - responsive positioning
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: isSmallScreen ? 20 : 30,
                            left: isSmallScreen ? 10 : 20,
                            right: isSmallScreen ? 10 : 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              teamMembers.length,
                              (index) => Container(
                                width: isSmallScreen ? 8 : 12,
                                height: isSmallScreen ? 8 : 12,
                                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentTeamMemberIndex
                                    ? Colors.blue
                                    : Colors.white.withOpacity(0.3),
                                  boxShadow: index == _currentTeamMemberIndex
                                    ? [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Navigation arrows - responsive positioning and sizing
                    Positioned(
                      left: isSmallScreen ? 5 : 10,
                      top: isSmallScreen ? 200 : 300,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _currentTeamMemberIndex = (_currentTeamMemberIndex - 1) % teamMembers.length;
                              if (_currentTeamMemberIndex < 0) {
                                _currentTeamMemberIndex = teamMembers.length - 1;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white.withOpacity(0.9),
                            size: isSmallScreen ? 24 : 32,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                        ),
                      ),
                    ),
                    Positioned(
                      right: isSmallScreen ? 5 : 10,
                      top: isSmallScreen ? 200 : 300,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _currentTeamMemberIndex = (_currentTeamMemberIndex + 1) % teamMembers.length;
                            });
                          },
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.white.withOpacity(0.9),
                            size: isSmallScreen ? 24 : 32,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                        ),
                      ),
                    ),
                    
                    // Close button - responsive positioning and sizing
                    Positioned(
                      right: isSmallScreen ? 5 : 10,
                      top: isSmallScreen ? 5 : 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.white.withOpacity(0.9),
                            size: isSmallScreen ? 20 : 24,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5D6A7).withOpacity(0.9), // Slightly brighter
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showLifeShop(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'Assets/items/life.svg',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Life Shop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Life packages
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                 _buildLifePackage(
  context: context,
  lives: 5,
  stars: 100,
  isPopular: false,
 // onTap: () => _buyLifePackage(100, 5),
),
                      const SizedBox(height: 15),
                      _buildLifePackage(
  context: context,
  lives: 15,
  stars: 250,
  isPopular: false,
//  onTap: () => _buyLifePackage(250, 15),
),

                      const SizedBox(height: 15),
                     _buildLifePackage(
  context: context,
  lives: 30,
  stars: 450,
  isPopular: true,
 // onTap: () => _buyLifePackage(450, 30),
),
                    ],
                  ),
                ),

                // Info text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Lives regenerate automatically every 30 minutes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget _buildLifePackage({
  required BuildContext context,
  required int lives,
  required int stars,
  required bool isPopular,
 // required VoidCallback onTap,
}) {
  return GestureDetector(
   // onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Lives info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'Assets/items/life.svg',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'x$lives',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Purchase button
            TextButton(
              onPressed: () {
               
                if (star >= stars) {
    _buyLifePackage(stars, lives);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$lives lives purchased successfully!',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green.withOpacity(0.7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Not enough stars to buy lives!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.withOpacity(0.7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
},
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'Assets/items/blue_star.svg',
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$stars',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1832), // Dark blue background
      body: SafeArea(
        child: Stack(
          children: [
            // Background PNG
            Positioned.fill(
              child: Image.asset(
                'Assets/background/home-back1.png',
                fit: BoxFit.cover,
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),

            // SVG Layer
            Positioned.fill(
              child: SvgPicture.asset(
                'Assets/background/home.svg',
                fit: BoxFit.cover,
              ),
            ),

            // Fixed buttons in their final positions
            _buildFixedButton(button1Left, button1Top, 1, color: Colors.blue),
            _buildFixedButton(button2Left, button2Top, 2, color: Colors.green),
            _buildFixedButton(button3Left, button3Top, 3, color: Colors.purple),
            _buildFixedButton(button4Left, button4Top, 4, color: Colors.orange),
            _buildFixedButton(button5Left, button5Top, 5, color: Colors.pink),
            _buildFixedButton(button6Left, button6Top, 6, color: Colors.teal),
            _buildFixedButton(button7Left, button7Top, 7, color: Colors.amber),

            // Top status bars
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBar(
                        icon: 'Assets/items/blue_star.svg',
                        value: userData['star'].toString(),
                        maxWidth: 120,
                      ),
                      _buildStatusBar(
                        icon: 'Assets/items/smart.svg',
                        value: userData['score'].toString() + "%",
                        maxWidth: 120,
                      ),
                      Stack(
                        children: [
                          _buildStatusBar(
                            icon: 'Assets/items/life.svg',
                            value: userData['heart'].toString(),
                            maxWidth: 120,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // Settings button
                      GestureDetector(
                        onTap: () {
                          _showProfileSettings(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tmazight button (left side)
            Positioned(
              left: -50,
              top: MediaQuery.of(context).size.height * 0.3,
              child: GestureDetector(
                onTap: () async {
                  // Update learning path to Tmazight
                  await StorageService.updateLearningPath('tmazight_language');
                  
                  // Navigate to Tmazight home page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TmazightHomePage(username: currentUsername),
                    ),
                  );
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Switched to Tmazight Language path!',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.green.withOpacity(0.7),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                  child: SvgPicture.asset(
                    'Assets/items/tmazight.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Chibies button (right side)
            Positioned(
              right: -40,
              top: MediaQuery.of(context).size.height * 0.09,
              child: GestureDetector(
                onTap: () => _showTeamMemberCard(context),
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      bottomLeft: Radius.circular(100),
                    ),
                  ),
                  child: SvgPicture.asset(
                    'Assets/items/us.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom navigation
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
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
    );
  }

  Widget _buildStatusBar({
    required String icon,
    required String value,
    required double maxWidth,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(88, 56, 56, 56),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(
              icon,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(221, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (icon == 'Assets/items/life.svg')
            GestureDetector(
              onTap: () => _showLifeShop(context),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
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

  void _showLearningPathSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Change Learning Path',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Learning paths
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildLearningPathOption(
                          'Software Engineering',
                          'Become a Software Developer',
                          Icons.code,
                          Colors.blue,
                          'software_engineering',
                        ),
                        const SizedBox(height: 15),
                        _buildLearningPathOption(
                          'Tmazight Language',
                          'Learn Amazigh Language',
                          Icons.language,
                          Colors.green,
                          'tmazight_language',
                        ),
                        const SizedBox(height: 15),
                        _buildLearningPathOption(
                          'Academic Courses',
                          'School Curriculum',
                          Icons.school,
                          Colors.purple,
                          'academic_courses',
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Change App Language',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Language options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildLanguageOption(
                          'العربية',
                          'Arabic',
                          '🇸🇦',
                          'arabic',
                        ),
                        const SizedBox(height: 15),
                        _buildLanguageOption(
                          'English',
                          'English',
                          '🇺🇸',
                          'english',
                        ),
                        const SizedBox(height: 15),
                        _buildLanguageOption(
                          'Tamazight',
                          'Amazigh',
                          '🏔️',
                          'tmazight',
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningPathOption(String title, String subtitle, IconData icon, Color color, String pathId) {
    return GestureDetector(
      onTap: () async {
        // Save the new learning path
        await StorageService.updateLearningPath(pathId);
        Navigator.pop(context);
        
        // Navigate to the appropriate home page based on learning path
        Widget targetPage;
        if (pathId == 'academic_courses') {
          targetPage = AcademicHomePage(username: currentUsername);
        } else if (pathId == 'tmazight_language') {
          targetPage = TmazightHomePage(username: currentUsername);
        } else {
          // software_engineering - refresh current page
          targetPage = HomePage(username: currentUsername);
        }

        // Navigate to the new page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Learning path changed to $title!',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green.withOpacity(0.7),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      String title, String subtitle, String flag, String langId) {
    return GestureDetector(
      onTap: () async {
        // Save the new language
        await StorageService.updateAppLanguage(langId);
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'App language changed to $title!',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green.withOpacity(0.7),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void _showGitHubSettings(BuildContext context) {
    final TextEditingController repoController = TextEditingController();
    final TextEditingController tokenController = TextEditingController();
    
    // Load existing values
    StorageService.getRepoUrl().then((url) => repoController.text = url ?? '');
    StorageService.getGithubToken().then((token) => tokenController.text = token ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1832).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.code_outlined, color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'GitHub Repository Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Repository URL
                  TextField(
                    controller: repoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'GitHub Repository URL',
                      hintText: 'https://github.com/username/repo',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.link, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // GitHub Token
                  TextField(
                    controller: tokenController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'GitHub Personal Access Token',
                      hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.key, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Get your GitHub token from: Settings → Developer settings → Personal access tokens',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final repoUrl = repoController.text.trim();
                        final token = tokenController.text.trim();
                        
                        if (repoUrl.isEmpty || token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill both fields')),
                          );
                          return;
                        }
                        
                        // Save to storage
                        await StorageService.saveRepoUrl(repoUrl);
                        await StorageService.saveGithubToken(token);
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('GitHub settings saved!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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

