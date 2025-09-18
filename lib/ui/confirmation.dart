// import 'package:flutter/material.dart';
//
// class ConfirmationPage extends StatelessWidget {
//   const ConfirmationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Confirmation"),
//         backgroundColor: const Color(0xFF2D4CC8),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               "Please provide your signature or upload a photo for confirmation.",
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // TODO: add signature capture logic
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Signature button pressed")),
//                 );
//               },
//               icon: const Icon(Icons.edit),
//               label: const Text("Add Signature"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2D4CC8),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // TODO: add image upload logic
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Image button pressed")),
//                 );
//               },
//               icon: const Icon(Icons.camera_alt),
//               label: const Text("Upload Image"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2D4CC8),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context); // 返回上一頁
//               },
//               child: const Text("Done"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
