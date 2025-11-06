// import 'package:flutter/material.dart';
// import '../services/storage_service.dart';
// import 'games.dart';
// import 'catagory.dart';

// class TmazightHomePage extends StatefulWidget {
//   final String username;

//   const TmazightHomePage({super.key, this.username = 'User'});

//   @override
//   State<TmazightHomePage> createState() => _TmazightHomePageState();
// }

// class _TmazightHomePageState extends State<TmazightHomePage> {
//   int _selectedIndex = 1;

//   final List<String> grades = const [
//     'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
//   ];

//   void _onNavTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     if (index == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Achievements coming soon', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.blue.withOpacity(0.7),
//         ),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => GamesPage(username: widget.username),
//         ),
//       );
//     }
//   }

//   Widget _buildNavButton(IconData icon, {bool isSelected = false, bool isHome = false, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(isHome ? 24 : 20),
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3) : Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(isHome ? 30 : 25),
//           border: Border.all(
//             color: isSelected ? const Color.fromARGB(255, 33, 150, 243) : Colors.white.withOpacity(0.2),
//             width: isHome ? 3 : 2,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//           size: isHome ? 48 : 38,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF123A6A),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Color(0xFF245A9B), Color(0xFF123A6A)],
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 20,
//               left: 20,
//               right: 20,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'ⵜⴰⵎⴰⵣⵉⵖⵜ',
//                           style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Welcome ${widget.username}',
//                           style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       await StorageService.updateLearningPath('software_engineering');
//                       if (mounted) {
//                         Navigator.pushReplacementNamed(
//                           context,
//                           '/home',
//                           arguments: {'username': widget.username},
//                         );
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.swap_horiz, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned.fill(
//               top: 90,
//               bottom: 110,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.language, color: Colors.white70),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Choose your grade',
//                           style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Expanded(
//                       child: GridView.builder(
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 14,
//                           mainAxisSpacing: 14,
//                           childAspectRatio: 1.0,
//                         ),
//                         itemCount: grades.length,
//                         itemBuilder: (context, index) {
//                           final title = grades[index];
//                           return GestureDetector(
//                             onTap: () async {
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(
//                               //     builder: (context) => const LevelTopicsPage(),
//                               //   ),
//                               // );
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.08),
//                                 borderRadius: BorderRadius.circular(18),
//                                 border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     right: -10,
//                                     bottom: -10,
//                                     child: Opacity(
//                                       opacity: 0.12,
//                                       child: Icon(Icons.school, size: 120, color: Colors.blue[200]),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.all(10),
//                                           decoration: BoxDecoration(
//                                             color: Colors.green.withOpacity(0.18),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(Icons.menu_book, color: Colors.white),
//                                         ),
//                                         const Spacer(),
//                                         Text(
//                                           title,
//                                           style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           'Tap to explore lessons',
//                                           style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             Positioned(
//               bottom: 30,
//               left: 20,
//               right: 20,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildNavButton(
//                     Icons.emoji_events_outlined,
//                     isSelected: _selectedIndex == 0,
//                     onTap: () => _onNavTap(0),
//                   ),
//                   _buildNavButton(
//                     Icons.home_rounded,
//                     isSelected: _selectedIndex == 1,
//                     isHome: true,
//                     onTap: () => _onNavTap(1),
//                   ),
//                   _buildNavButton(
//                     Icons.sports_esports_rounded,
//                     isSelected: _selectedIndex == 2,
//                     onTap: () => _onNavTap(2),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


