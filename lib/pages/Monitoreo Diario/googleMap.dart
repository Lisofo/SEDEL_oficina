// ignore_for_file: file_names
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sedel_oficina_maqueta/models/tecnico.dart';
// import 'package:sedel_oficina_maqueta/models/ubicacion.dart';



// class GoogleMapOption extends StatefulWidget {
//   const GoogleMapOption({super.key});

//   @override
//   State<GoogleMapOption> createState() => _GoogleMapOptionState();
// }

// class _GoogleMapOptionState extends State<GoogleMapOption> {
//   Completer<GoogleMapController> _controller = Completer();

//   static const LatLng _center = const LatLng(-34.8864, -56.1224);
//   static const LatLng _center2 = const LatLng(-31.6989459, -55.9391544);
//   // static const LatLng _center3 = const LatLng(-34.8864, -56.1224);
//   MapType _currentMapType = MapType.normal;

//   LatLng _lastMapPosition = _center;
//   LatLng _lastMapPosition2 = _center2;
//   // LatLng _lastMapPosition3 = _center2;
//   Tecnico? selectedTecnico;
//   List<Tecnico> tecnicos = [];
//   final Set<Marker> _markers = {};

//   void _onMapTypeButtonPressed() {
//     setState(() {
//       _currentMapType = _currentMapType == MapType.normal
//           ? MapType.satellite
//           : MapType.normal;
//     });
//   }

//   void _onAddMarkerButtonPressed() {
//     setState(() {
//       _markers.add(Marker(
//         // This marker id can be anything that uniquely identifies each marker.
//         markerId: MarkerId(_lastMapPosition.toString()),
//         position: _lastMapPosition,
//         infoWindow: InfoWindow(
//           title: 'Cliente: Frigorifico Tacuarembo',
//           snippet: 'Tecnico: juan perez',
//         ),
//         icon: BitmapDescriptor.defaultMarker,
//       ));
//       _markers.add(Marker(
//         // This marker id can be anything that uniquely identifies each marker.
//         markerId: MarkerId(_lastMapPosition2.toString()),
//         position: _lastMapPosition2,
//         infoWindow: InfoWindow(
//           title: 'Cliente: Almacen La Teja',
//           snippet: 'Tecnico: juan perez',
//         ),
//         icon: BitmapDescriptor.defaultMarker,
//       ));
//     });
//   }

//   void _onCameraMove(CameraPosition position) {
//     _lastMapPosition = position.target;
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _controller.complete(controller);
//   }

//   // void _showLocations() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       return AlertDialog(
//   //         title: Text('Selector de filtro'),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             DropdownButton(
//   //               hint: Text('Tecnico'),
//   //               value: selectedTecnico,
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedTecnico = value;
//   //                 });
//   //               },
//   //               items: tecnicos.map((e) {
//   //                 return DropdownMenuItem(
//   //                   child: Text(e.nombreTecnico),
//   //                   value: e,
//   //                 );
//   //               }).toList(),
//   //             ),
//   //           ],
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //               onPressed: () {
//   //                 Navigator.pop(context);
//   //               },
//   //               child: Text('Confirmar')),
//   //           TextButton(
//   //               onPressed: () {
//   //                 Navigator.pop(context);
//   //               },
//   //               child: Text('Cancelar')),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   List<Ubicacion> ubicaciones = [
//     // Ubicacion(
//     //     tecnico: Tecnico(tecnicoId: 1, nombreTecnico: 'Jose'),
//     //     fecha: DateTime.now(),
//     //     coordenada: Coordenada(latitud: -34.8927715, longitud: -56.1233649),
//     //     cliente: Cliente(
//     //       clienteId: 1,
//     //       nombre: 'Frigorifico Tacuarembo',
//     //       codCliente: '123',
//     //       direccion:
//     //           'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //       telefono1: '4632 3641',
//     //       nombreFantasia: '',
//     //       barrio: '',
//     //       localidad: '',
//     //       departamentoId: 0,
//     //       telefono2: '',
//     //       email: '',
//     //       ruc: '',
//     //       tecnicoId: 0,
//     //       tipoClienteId: 0,
//     //       estado: '',
//     //     ),
//     //     orden: Orden(
//     //         ordenId: 1,
//     //         fechaDesde: DateTime.utc(2023, 9, 15, 13, 30),
//     //         fechaHasta: DateTime.utc(2023, 9, 15, 16, 30),
//     //         tecnico: Tecnico(nombreTecnico: 'Jose', tecnicoId: 1),
//     //         cliente: Cliente(
//     //           clienteId: 1,
//     //           nombre: 'Frigorifico Tacuarembo',
//     //           codCliente: '123',
//     //           direccion:
//     //               'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //           telefono1: '4632 3641',
//     //           nombreFantasia: '',
//     //           barrio: '',
//     //           localidad: '',
//     //           departamentoId: 0,
//     //           telefono2: '',
//     //           email: '',
//     //           ruc: '',
//     //           tecnicoId: 0,
//     //           tipoClienteId: 0,
//     //           estado: '',
//     //         ),
//     //         tipoOrden: 'Normal',
//     //         estado: 'Pendiente',
//     //         numOrden: 1,
//     //         instrucciones: 'Hacer recorrida por el deposito X',
//     //         codTipoOrden: '',
//     //         servicios: [
//     //           Servicios(
//     //               codServicio: '01',
//     //               descripcion: 'Monitoreo y control de aves'),
//     //           Servicios(codServicio: '02', descripcion: 'Cobranza'),
//     //         ]),
//     //     comentario: 'comentario'),
//     // Ubicacion(
//     //     tecnico: Tecnico(tecnicoId: 1, nombreTecnico: 'Jose'),
//     //     fecha: DateTime.now(),
//     //     coordenada: Coordenada(latitud: -34.8864, longitud: -56.1224),
//     //     cliente: Cliente(
//     //       clienteId: 1,
//     //       nombre: 'Almacen La Teja',
//     //       codCliente: '123',
//     //       direccion:
//     //           'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //       telefono1: '4632 3641',
//     //       nombreFantasia: '',
//     //       barrio: '',
//     //       localidad: '',
//     //       departamentoId: 0,
//     //       telefono2: '',
//     //       email: '',
//     //       ruc: '',
//     //       tecnicoId: 0,
//     //       tipoClienteId: 0,
//     //       estado: '',
//     //     ),
//     //     orden: Orden(
//     //         ordenId: 2,
//     //         fechaDesde: DateTime.utc(2023, 9, 15, 13, 30),
//     //         fechaHasta: DateTime.utc(2023, 9, 15, 16, 30),
//     //         tecnico: Tecnico(nombreTecnico: 'Jose', tecnicoId: 1),
//     //         cliente: Cliente(
//     //           clienteId: 1,
//     //           nombre: 'Almacen La Teja',
//     //           codCliente: '123',
//     //           direccion:
//     //               'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //           telefono1: '4632 3641',
//     //           nombreFantasia: '',
//     //           barrio: '',
//     //           localidad: '',
//     //           departamentoId: 0,
//     //           telefono2: '',
//     //           email: '',
//     //           ruc: '',
//     //           tecnicoId: 0,
//     //           tipoClienteId: 0,
//     //           estado: '',
//     //         ),
//     //         tipoOrden: 'Normal',
//     //         estado: 'Pendiente',
//     //         numOrden: 1,
//     //         instrucciones: 'Hacer recorrida por el deposito X',
//     //         codTipoOrden: '',
//     //         servicios: [
//     //           Servicios(
//     //               codServicio: '01',
//     //               descripcion: 'Monitoreo y control de aves'),
//     //           Servicios(codServicio: '02', descripcion: 'Cobranza'),
//     //         ]),
//     //     comentario: 'comentario'),
//     // Ubicacion(
//     //     tecnico: Tecnico(tecnicoId: 1, nombreTecnico: 'Jose'),
//     //     fecha: DateTime.now(),
//     //     coordenada: Coordenada(latitud: -34.8752818, longitud: -56.1624937),
//     //     cliente: Cliente(
//     //       clienteId: 1,
//     //       nombre: 'Almacen La Teja',
//     //       codCliente: '123',
//     //       direccion:
//     //           'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //       telefono1: '4632 3641',
//     //       nombreFantasia: '',
//     //       barrio: '',
//     //       localidad: '',
//     //       departamentoId: 0,
//     //       telefono2: '',
//     //       email: '',
//     //       ruc: '',
//     //       tecnicoId: 0,
//     //       tipoClienteId: 0,
//     //       estado: '',
//     //     ),
//     //     orden: Orden(
//     //         ordenId: 3,
//     //         fechaDesde: DateTime.utc(2023, 9, 15, 13, 30),
//     //         fechaHasta: DateTime.utc(2023, 9, 15, 16, 30),
//     //         tecnico: Tecnico(nombreTecnico: 'Jose', tecnicoId: 1),
//     //         cliente: Cliente(
//     //           clienteId: 1,
//     //           nombre: 'Almacen La Teja',
//     //           codCliente: '123',
//     //           direccion:
//     //               'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //           telefono1: '4632 3641',
//     //           nombreFantasia: '',
//     //           barrio: '',
//     //           localidad: '',
//     //           departamentoId: 0,
//     //           telefono2: '',
//     //           email: '',
//     //           ruc: '',
//     //           tecnicoId: 0,
//     //           tipoClienteId: 0,
//     //           estado: '',
//     //         ),
//     //         tipoOrden: 'Normal',
//     //         estado: 'Pendiente',
//     //         numOrden: 1,
//     //         instrucciones: 'Hacer recorrida por el deposito X',
//     //         codTipoOrden: '',
//     //         servicios: [
//     //           Servicios(
//     //               codServicio: '01',
//     //               descripcion: 'Monitoreo y control de aves'),
//     //           Servicios(codServicio: '02', descripcion: 'Cobranza'),
//     //         ]),
//     //     comentario: 'comentario'),
//     // Ubicacion(
//     //     tecnico: Tecnico(tecnicoId: 1, nombreTecnico: 'Jose'),
//     //     fecha: DateTime.now(),
//     //     coordenada: Coordenada(latitud: -34.8884675, longitud: -56.1470045),
//     //     cliente: Cliente(
//     //       clienteId: 1,
//     //       nombre: 'Almacen La Teja',
//     //       codCliente: '123',
//     //       direccion:
//     //           'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //       telefono1: '4632 3641',
//     //       nombreFantasia: '',
//     //       barrio: '',
//     //       localidad: '',
//     //       departamentoId: 0,
//     //       telefono2: '',
//     //       email: '',
//     //       ruc: '',
//     //       tecnicoId: 0,
//     //       tipoClienteId: 0,
//     //       estado: '',
//     //     ),
//     //     orden: Orden(
//     //         ordenId: 4,
//     //         fechaDesde: DateTime.utc(2023, 9, 15, 13, 30),
//     //         fechaHasta: DateTime.utc(2023, 9, 15, 16, 30),
//     //         tecnico: Tecnico(nombreTecnico: 'Jose', tecnicoId: 1),
//     //         cliente: Cliente(
//     //           clienteId: 1,
//     //           nombre: 'Almacen La Teja',
//     //           codCliente: '123',
//     //           direccion:
//     //               'Brigadier Gral. Fructuso Rivera, 45000 Tacuarembo, Departamento de Tacuarembo',
//     //           telefono1: '4632 3641',
//     //           nombreFantasia: '',
//     //           barrio: '',
//     //           localidad: '',
//     //           departamentoId: 0,
//     //           telefono2: '',
//     //           email: '',
//     //           ruc: '',
//     //           tecnicoId: 0,
//     //           tipoClienteId: 0,
//     //           estado: '',
//     //         ),
//     //         tipoOrden: 'Normal',
//     //         estado: 'Pendiente',
//     //         numOrden: 1,
//     //         instrucciones: 'Hacer recorrida por el deposito X',
//     //         codTipoOrden: '',
//     //         servicios: [
//     //           Servicios(
//     //               codServicio: '01',
//     //               descripcion: 'Monitoreo y control de aves'),
//     //           Servicios(codServicio: '02', descripcion: 'Cobranza'),
//     //         ]),
//     //     comentario: 'comentario'),
//   ];

//   void mostrarMarkers() {
//     for (var ubicacion in ubicaciones) {
//       _markers.add(Marker(
//         markerId: MarkerId(ubicacion.orden.ordenTrabajoId.toString()),
//         position:
//             LatLng(ubicacion.coordenada.latitud, ubicacion.coordenada.longitud),
//         infoWindow: InfoWindow(
//           title: 'Cliente: ${ubicacion.orden.cliente.nombre}',
//           snippet: 'Técnico: ${ubicacion.tecnico.nombre}',
//         ),
//         icon: BitmapDescriptor.defaultMarker,
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // for (var ubicacion in ubicaciones) {
//     //   _markers.add(Marker(
//     //     markerId: MarkerId(ubicacion.coordenada.toString()),
//     //     position:
//     //         LatLng(ubicacion.coordenada.latitud, ubicacion.coordenada.longitud),
//     //     infoWindow: InfoWindow(
//     //       title: 'Cliente: ${ubicacion.cliente.nombreCliente}',
//     //       snippet: 'Técnico: ${ubicacion.tecnico.nombreTecnico}',
//     //     ),
//     //     icon: BitmapDescriptor.defaultMarker,
//     //   ));
//     // }

//     return Stack(
//       children: <Widget>[
//         GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(
//             target: _center,
//             zoom: 11.0,
//           ),
//           mapType: _currentMapType,
//           markers: _markers,
//           onCameraMove: _onCameraMove,
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Align(
//             alignment: Alignment.topRight,
//             child: Column(
//               children: <Widget>[
//                 FloatingActionButton(
//                   onPressed: _onMapTypeButtonPressed,
//                   materialTapTargetSize: MaterialTapTargetSize.padded,
//                   backgroundColor: Colors.green,
//                   child: const Icon(Icons.map, size: 36.0),
//                 ),
//                 SizedBox(height: 16.0),
//                 FloatingActionButton(
//                   onPressed: _onAddMarkerButtonPressed,
//                   materialTapTargetSize: MaterialTapTargetSize.padded,
//                   backgroundColor: Colors.green,
//                   child: const Icon(Icons.add_location, size: 36.0),
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 FloatingActionButton(
//                   onPressed: () {
//                     setState(() {
//                       mostrarMarkers();
//                     });
//                   },
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
// }
