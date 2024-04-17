// ignore_for_file: file_names
// // ignore_for_file: file_names

// import 'package:flutter/material.dart';
// import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
// import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

// class EditIndisponibilidad extends StatefulWidget {
//   const EditIndisponibilidad({super.key});

//   @override
//   State<EditIndisponibilidad> createState() => _EditIndisponibilidadState();
// }

// class _EditIndisponibilidadState extends State<EditIndisponibilidad> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBarDesktop(
//         titulo: '',
//       ),
//       drawer: Drawer(
//         child: BotonesDrawer(),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Card(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Flexible(
//                   flex: 1,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Codigo: '),
//                           Container(
//                             width: 200,
//                             child: TextField(),
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Tipo: '),
//                           SizedBox(
//                             width: 18,
//                           ),
//                           Container(
//                             width: 200,
//                             child: TextField(),
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Fecha Desde: '),
//                           SizedBox(
//                             width: 18,
//                           ),
//                           TextButton(
//                               onPressed: () {
//                                 DatePickerDialog(
//                                   firstDate: DateTime(1990),
//                                   initialDate: DateTime.now(),
//                                   lastDate: DateTime(2099),
//                                 );
//                               },
//                               child: Text('Seleccione Fecha'))
//                         ],
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Fecha Hasta: '),
//                           SizedBox(
//                             width: 18,
//                           ),
//                           TextButton(
//                               onPressed: () {
//                                 DatePickerDialog(
//                                   firstDate: DateTime(1990),
//                                   initialDate: DateTime.now(),
//                                   lastDate: DateTime(2099),
//                                 );
//                               },
//                               child: Text('Seleccione Fecha'))
//                         ],
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Cliente: '),
//                           SizedBox(
//                             width: 18,
//                           ),
//                           Container(width: 200, child: TextField())
//                         ],
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Tecnico: '),
//                           SizedBox(
//                             width: 18,
//                           ),
//                           Container(width: 200, child: TextField())
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 100,
//                 ),
//                 Flexible(
//                     flex: 1,
//                     child: Card(
//                       child: Column(
//                         children: [
//                           Text('Observaciones'),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Container(
//                               width: 600,
//                               decoration: BoxDecoration(border: Border.all()),
//                               child: TextField(
//                                 maxLines: 20,
//                                 decoration:
//                                     InputDecoration(border: InputBorder.none),
//                               ))
//                         ],
//                       ),
//                     ))
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         elevation: 0,
//         color: Colors.grey.shade200,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               ElevatedButton(
//                   style: ButtonStyle(
//                       backgroundColor: MaterialStatePropertyAll(Colors.white),
//                       elevation: MaterialStatePropertyAll(10),
//                       shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                           borderRadius: BorderRadius.horizontal(
//                               left: Radius.circular(50),
//                               right: Radius.circular(50))))),
//                   onPressed: () {},
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.5),
//                     child: Text(
//                       'Guardar',
//                       style: TextStyle(
//                           color: colors.primary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20),
//                     ),
//                   )),
//               SizedBox(
//                 width: 30,
//               ),
//               ElevatedButton(
//                   style: ButtonStyle(
//                       backgroundColor: MaterialStatePropertyAll(Colors.white),
//                       elevation: MaterialStatePropertyAll(10),
//                       shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                           borderRadius: BorderRadius.horizontal(
//                               left: Radius.circular(50),
//                               right: Radius.circular(50))))),
//                   onPressed: () {},
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.5),
//                     child: Text(
//                       'Modificar',
//                       style: TextStyle(
//                           color: colors.primary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20),
//                     ),
//                   )),
//               SizedBox(
//                 width: 30,
//               ),
//               ElevatedButton(
//                   style: ButtonStyle(
//                       backgroundColor: MaterialStatePropertyAll(Colors.white),
//                       elevation: MaterialStatePropertyAll(10),
//                       shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                           borderRadius: BorderRadius.horizontal(
//                               left: Radius.circular(50),
//                               right: Radius.circular(50))))),
//                   onPressed: () {},
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.5),
//                     child: Text(
//                       'Eliminar',
//                       style: TextStyle(
//                           color: colors.primary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20),
//                     ),
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
