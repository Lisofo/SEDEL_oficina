// ignore_for_file: avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/services/ubicaciones_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';

import '../../../models/cliente.dart';
import '../../../models/tecnico.dart';
import '../../../models/ubicacion.dart';

class MapaPageDesktop extends StatefulWidget {
  const MapaPageDesktop({super.key});

  @override
  State<MapaPageDesktop> createState() => _MapaPageDesktopState();
}

class _MapaPageDesktopState extends State<MapaPageDesktop>
    with SingleTickerProviderStateMixin {
  Tecnico? selectedTecnico;
  Cliente? selectedCliente;
  DateTime selectedDate = DateTime.now();
  late String token = '';

  List<Tecnico> tecnicos = [];
  int tecnicoFiltro = 0;
  int clienteFiltro = 0;
  List<Ubicacion> ubicaciones = [];

  Key apiKeyMap = const Key('AIzaSyDXT7F5CCCKNAok1xCYtxDX0sztOnQellM');

  List<Ubicacion> ubicacionesFiltradas = [];
  final LatLng currentLocation = const LatLng(-34.8927715, -56.1233649);
  late GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];

  TextEditingController filtroController = TextEditingController();
  late AnimationController _animationController;
  bool selectAll = true;

  @override
  void initState() {
    super.initState();
    selectedCliente = Cliente.empty();
    cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    print(_animationController.value);
  }

  Future<void> loadTecnicos() async {
    final token = context.watch<OrdenProvider>().token;
    final loadedTecnicos =
        await TecnicoServices().getAllTecnicos(context, token);
    setState(() {
      tecnicos = loadedTecnicos;
    });
  }

  void toggleMapWidth() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBarDesktop(
            titulo: 'Mapa',
          ),
          drawer: const Drawer(
            child: BotonesDrawer(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Tecnico: ',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownSearch(
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                                hintText: 'Seleccione un tecnico')),
                        items: tecnicos,
                        popupProps: const PopupProps.menu(
                            showSearchBox: true, searchDelay: Duration.zero),
                        onChanged: (value) {
                          setState(() {
                            selectedTecnico = value;
                            tecnicoFiltro = value!.tecnicoId;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    const Text(
                      'Cliente: ',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const ButtonDelegate(
                        colorSeleccionado: Colors.black,
                        nombreProvider: 'Mapa'),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () async {
                        ubicaciones = await UbicacionesServices()
                            .getUbicaciones(
                                context,
                                selectedTecnico!.tecnicoId,
                                selectedDate.toIso8601String(),
                                selectedDate
                                    .add(const Duration(days: 1))
                                    .toIso8601String(),
                                token);

                        cargarUbicacion();
                        cargarMarkers();
                        setState(() {});
                      },
                      icon: const Icon(Icons.search),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            initialDate: selectedDate,
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2099),
                            context: context,
                          );

                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month)),
                    const Text(
                      'Fecha: ',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      DateFormat("E d, MMM", 'es').format(selectedDate),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final targetWidth =
                              MediaQuery.of(context).size.width / 1.35;
                          final initialWidth =
                              MediaQuery.of(context).size.width - 26;
                          final currentWidth = initialWidth +
                              (_animationController.value *
                                  (targetWidth - initialWidth));

                          final targetHeight =
                              MediaQuery.of(context).size.height / 1.45;
                          final initialHeight = MediaQuery.of(context)
                                  .size
                                  .height -
                              141; // Puedes ajustar esto según tus necesidades
                          final currentHeight = initialHeight +
                              (_animationController.value *
                                  (targetHeight - initialHeight));

                          return SizedBox(
                              width: currentWidth,
                              height: currentHeight,
                              child: Stack(
                                children: <Widget>[
                                  GoogleMap(
                                    key: apiKeyMap,
                                    initialCameraPosition: CameraPosition(
                                      target: currentLocation,
                                      zoom: 14.0,
                                    ),
                                    onMapCreated: (controller) {
                                      mapController = controller;
                                      // cargarUbicacion();
                                      // cargarMarkers();
                                    },
                                    markers: _markers.values.toSet(),
                                    polylines: {
                                      Polyline(
                                        polylineId:
                                            const PolylineId('polyline'),
                                        color: Colors.blue,
                                        width: 3,
                                        points: polylineCoordinates,
                                      ),
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Column(
                                        children: <Widget>[
                                          FloatingActionButton(
                                            onPressed: () async {
                                              toggleMapWidth();
                                              print(_animationController.value);
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.padded,
                                            backgroundColor: Colors.green,
                                            child: const Icon(
                                                Icons
                                                    .format_list_bulleted_rounded,
                                                size: 36.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        }),

                    if (_animationController.value == 1.0)
                      const SizedBox(
                          width: 10.0), // Espacio entre el mapa y la lista
                    if (_animationController.value == 1.0)
                      Card(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 300,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: filtroController,
                                      onChanged: (value) {
                                        cargarUbicacion();
                                        cargarMarkers();
                                      },
                                      onFieldSubmitted: (value) {
                                        cargarUbicacion();
                                        cargarMarkers();
                                        setState(() {});
                                      },
                                      maxLines: 1,
                                      label: 'Filtrar por número de orden',
                                    ),
                                  ),
                                  Checkbox(
                                    value: selectAll,
                                    onChanged: (value) {
                                      setState(() {
                                        selectAll = value!;
                                        // Actualiza el estado de todos los elementos en la lista
                                        for (var ubicacion
                                            in ubicacionesFiltradas) {
                                          ubicacion.seleccionado = selectAll;
                                        }
                                        // Actualiza los markers en el mapa
                                        cargarMarkers();
                                      });
                                    },
                                  ),
                                  const Text('Marcar todos'),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: 300,
                                height:
                                    MediaQuery.of(context).size.height / 1.45,
                                child: ListView.builder(
                                    itemCount: ubicacionesFiltradas.length,
                                    itemBuilder: (context, i) {
                                      var ubicacion = ubicacionesFiltradas[i];
                                      return CheckboxListTile(
                                        title: Text(
                                          ubicacion.cliente.nombre,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                            '${ubicacion.ordenTrabajoId} - ${DateFormat('HH:mm', 'es').format(ubicacion.fechaDate)}'),
                                        value: ubicacion.seleccionado,
                                        onChanged: (value) {
                                          ubicacion.seleccionado = value!;
                                          setState(() {
                                            cargarMarkers();
                                          });
                                        },
                                      );
                                    })),
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  addMarker(String id, LatLng location, String title, String snippet) {
    var marker = Marker(
        markerId: MarkerId(id),
        position: location,
        infoWindow: InfoWindow(title: title, snippet: snippet),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan));
    _markers[id] = marker;
    polylineCoordinates.add(location);
  }

  cargarMarkers() {
    _markers.clear();
    polylineCoordinates.clear();
    for (var ubicacion in ubicacionesFiltradas) {
      var coord = ubicacion.ubicacion?.split(',');

      if (ubicacion.seleccionado) {
        print('mostrando ${ubicacion.logId}');
        addMarker(
            ubicacion.logId.toString(),
            LatLng(double.parse(coord![0]), double.parse(coord[1])),
            'Cliente: ${ubicacion.cliente.nombre}',
            'Tecnico: ${ubicacion.tecnico.nombre}');
      }
    }
  }

  void cargarUbicacion() {
    ubicacionesFiltradas = ubicaciones.where((e) =>
      (clienteFiltro > 0 ? e.cliente.clienteId == clienteFiltro : true) &&
      (tecnicoFiltro > 0 ? e.tecnico.tecnicoId == tecnicoFiltro : true) &&
      e.ubicacion != '' &&
      (filtroController.text.isEmpty || e.ordenTrabajoId.toString().contains(filtroController.text)))
    .toList();
  }
}
