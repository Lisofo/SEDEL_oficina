// ignore_for_file: file_names
// // ignore_for_file: must_be_immutable

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../models/ubicacion.dart';

// class GoogleMapOptionCopy extends StatefulWidget {
//   late List<Ubicacion> ubicaciones;
//   GoogleMapOptionCopy({required this.ubicaciones});

//   @override
//   State<GoogleMapOptionCopy> createState() => _GoogleMapOptionCopyState();
// }

// class _GoogleMapOptionCopyState extends State<GoogleMapOptionCopy> {
//   final LatLng currentLocation = LatLng(-34.8927715, -56.1233649);
//   late GoogleMapController mapController;
//   Map<String, Marker> _markers = {};

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         GoogleMap(
//           initialCameraPosition: CameraPosition(
//             target: currentLocation,
//             zoom: 14.0,
//           ),
//           onMapCreated: (controller) {
//             mapController = controller;
//             cargarMarkers();
//           },
//           markers: _markers.values.toSet(),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Align(
//             alignment: Alignment.topRight,
//             child: Column(
//               children: <Widget>[
//                 FloatingActionButton(
//                   onPressed: () {},
//                   materialTapTargetSize: MaterialTapTargetSize.padded,
//                   backgroundColor: Colors.green,
//                   child: const Icon(Icons.format_list_bulleted_rounded,
//                       size: 36.0),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   addMarker(String id, LatLng location, String title, String snippet) {
//     var marker = Marker(
//         markerId: MarkerId(id),
//         position: location,
//         infoWindow: InfoWindow(title: title, snippet: snippet));
//     _markers[id] = marker;
//     setState(() {});
//   }

//   cargarMarkers() {
//     for (var ubicacion in widget.ubicaciones) {
//       addMarker(
//           ubicacion.orden.ordenTrabajoId.toString(),
//           LatLng(ubicacion.coordenada.latitud, ubicacion.coordenada.longitud),
//           'Cliente: ' + ubicacion.orden.cliente.nombre,
//           'Tecnico: ' + ubicacion.tecnico.nombre);
//     }
//   }
// }
