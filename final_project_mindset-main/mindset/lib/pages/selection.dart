import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'welcome.dart';

class SelectionPage extends StatefulWidget {
  final String username;
  
  const SelectionPage({Key? key, required this.username}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String? selectedLearningPath;
  String? selectedLanguage;
  String? selectedAcademicLevel;
  String? selectedTmazightScript;
  
  // Learning paths
  final List<Map<String, dynamic>> learningPaths = [
    {
      'id': 'software_engineering',
      'title': 'Software Engineering',
      'subtitle': 'Become a Software Developer',
      'icon': Icons.code,
      'color': Colors.blue,
      'description': 'Learn programming, web development, mobile apps, and more',
    },
    {
      'id': 'tmazight_language',
      'title': 'Tmazight Language',
      'subtitle': 'Learn Amazigh Language',
      'icon': Icons.language,
      'color': Colors.green,
      'description': 'Master the beautiful Amazigh language and culture',
    },
    {
      'id': 'academic_courses',
      'title': 'Academic Courses',
      'subtitle': 'School Curriculum',
      'icon': Icons.school,
      'color': Colors.purple,
      'description': 'Follow structured academic learning paths',
    },
  ];

  // App languages
  final List<Map<String, dynamic>> appLanguages = [
    {
      'id': 'arabic',
      'title': 'العربية',
      'subtitle': 'Arabic',
      'flag': '🇸🇦',
    },
    {
      'id': 'english',
      'title': 'English',
      'subtitle': 'English',
      'flag': '🇺🇸',
    },
    {
      'id': 'tmazight',
      'title': 'Tamazight',
      'subtitle': 'Amazigh',
      'flag': '🏔️',
    },
  ];

  // Academic levels
  final List<Map<String, String>> academicLevels = [
    {'id': 'kg1', 'title': 'Kindergarten 1', 'age': '3-4 years'},
    {'id': 'kg2', 'title': 'Kindergarten 2', 'age': '4-5 years'},
    {'id': 'kg3', 'title': 'Kindergarten 3', 'age': '5-6 years'},
    {'id': 'high1', 'title': 'High School 1', 'age': '15-16 years'},
    {'id': 'high2', 'title': 'High School 2', 'age': '16-17 years'},
    {'id': 'high3', 'title': 'High School 3', 'age': '17-18 years'},
  ];

  // Tmazight script options
  final List<Map<String, String>> tmazightScripts = [
    {'id': 'tifinagh', 'title': 'Tifinagh Script', 'subtitle': 'ⵜⵉⴼⵉⵏⴰⵖ'},
    {'id': 'arabic_letters', 'title': 'Arabic Letters', 'subtitle': 'تامازيغت'},
  ];

  Future<void> _saveSelections() async {
    if (selectedLearningPath == null || selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both learning path and app language'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Additional validation for academic courses
    if (selectedLearningPath == 'academic_courses' && selectedAcademicLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your academic level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Additional validation for Tmazight language
    if (selectedLanguage == 'tmazight' && selectedTmazightScript == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Tmazight script preference'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save selections to local storage
    await StorageService.saveUserPreferences(
      learningPath: selectedLearningPath!,
      appLanguage: selectedLanguage!,
      academicLevel: selectedAcademicLevel,
      tmazightScript: selectedTmazightScript,
    );

    // Navigate to welcome page with actual username and gender
    if (mounted) {
      // Get gender from storage
      String? savedGender = await StorageService.getGender();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(
            username: widget.username,
            gender: savedGender ?? 'male', // Default to male if not saved
          ),
        ),
      );
    }
  }

  Widget _buildLearningPathCard(Map<String, dynamic> path) {
    bool isSelected = selectedLearningPath == path['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLearningPath = path['id'];
          if (path['id'] != 'academic_courses') {
            selectedAcademicLevel = null;
          }
        });
        // Debug: Force UI rebuild
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white.withOpacity(0.15) 
            : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 139, 203, 255) : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color.fromARGB(255, 139, 203, 255).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: path['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: path['color'].withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                path['icon'],
                color: path['color'],
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    path['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    path['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: path['color'],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    bool isSelected = selectedLanguage == language['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language['id'];
          if (language['id'] != 'tmazight') {
            selectedTmazightScript = null;
          }
        });
        // Debug: Force UI rebuild
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white.withOpacity(0.15) 
            : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 139, 203, 255) : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              language['flag'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    language['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 139, 203, 255),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicLevelCard(Map<String, String> level) {
    bool isSelected = selectedAcademicLevel == level['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAcademicLevel = level['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white.withOpacity(0.12) 
            : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    level['age']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.purple,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTmazightScriptCard(Map<String, String> script) {
    bool isSelected = selectedTmazightScript == script['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTmazightScript = script['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white.withOpacity(0.12) 
            : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.text_fields,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    script['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    script['subtitle']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ResizeImage(
              const AssetImage('Assets/background/login.png'),
              width: (size.width * devicePixelRatio).toInt(),
              height: (size.height * devicePixelRatio).toInt(),
            ),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(15, 0, 0, 0).withOpacity(0.4),
                const Color.fromARGB(47, 0, 0, 0).withOpacity(0.3),
                const Color.fromARGB(22, 0, 0, 0).withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Welcome ${widget.username}! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Let\'s personalize your learning experience',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),



                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Learning Path Selection
                        const Text(
                          'What would you like to learn? 📚',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...learningPaths.map((path) => _buildLearningPathCard(path)),
                        
                        // Academic Level Selection (if academic courses selected)
                        if (selectedLearningPath == 'academic_courses') ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple, width: 2),
                            ),
                            child: const Text(
                              'Select your academic level 🎓',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...academicLevels.map((level) => _buildAcademicLevelCard(level)),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // App Language Selection
                        const Text(
                          'Choose your app language 🌍',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...appLanguages.map((language) => _buildLanguageCard(language)),
                        
                        // Tmazight Script Selection (if Tmazight selected)
                        if (selectedLanguage == 'tmazight') ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Text(
                              'Choose Tmazight script ⵜⵉⴼⵉⵏⴰⵖ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...tmazightScripts.map((script) => _buildTmazightScriptCard(script)),
                        ],
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveSelections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 139, 203, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Continue to Learning 🚀',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 