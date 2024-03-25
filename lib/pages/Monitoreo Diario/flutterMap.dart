// ignore_for_file: file_names
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// final myPosition = LatLng(-31.6989459, -55.9391544);
// final myPosition2 = LatLng(-34.8864, -56.1224);

// class FlutterMapOption extends StatefulWidget {
//   const FlutterMapOption({super.key});

//   @override
//   State<FlutterMapOption> createState() => _FlutterMapOptionState();
// }

// class _FlutterMapOptionState extends State<FlutterMapOption> {
//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options:
//           MapOptions(center: myPosition2, minZoom: 5, maxZoom: 100, zoom: 18),
//       nonRotatedChildren: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//         ),
//         MarkerLayer(
//           markers: [
//             Marker(
//               point: myPosition,
//               builder: (context) {
//                 return Container(
//                   child: const Icon(
//                     Icons.person_pin,
//                     color: Colors.blueAccent,
//                     size: 40,
//                   ),
//                 );
//               },
//             ),
//             Marker(
//               point: myPosition2,
//               builder: (context) {
//                 return Container(
//                   child: const Icon(
//                     Icons.person_pin,
//                     color: Colors.blueAccent,
//                     size: 40,
//                   ),
//                 );
//               },
//             )
//           ],
//         )
//       ],
//     );  
//   }
// }
