// import 'package:flutter/material.dart';

// class DonePage extends StatelessWidget {
//   const DonePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF1E88E5),
//               Color(0xFF0D47A1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Success icon
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.green.withOpacity(0.3),
//                         spreadRadius: 4,
//                         blurRadius: 20,
//                         offset: Offset(0, 0),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.check,
//                     color: Colors.white,
//                     size: 60,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
                
//                 // Congratulations text
//                 Text(
//                   'Well Done!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 Text(
//                   'Task completed successfully',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 48),
                
//                 // Continue button
//                 Container(
//                   width: 200,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.white.withOpacity(0.3),
//                         spreadRadius: 2,
//                         blurRadius: 12,
//                         offset: Offset(0, 0),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context, true), // Return true to indicate completion
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(Colors.white),
//                       shape: MaterialStateProperty.all(RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       )),
//                       elevation: MaterialStateProperty.all(8),
//                     ),
//                     child: Text(
//                       'Continue',
//                       style: TextStyle(
//                         color: Color(0xFF0D47A1),
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// } 