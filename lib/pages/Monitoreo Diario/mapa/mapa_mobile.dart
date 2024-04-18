// ignore_for_file: avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class MapaPageMobile extends StatefulWidget {
  const MapaPageMobile({super.key});

  @override
  State<MapaPageMobile> createState() => _MapaPageMobileState();
}

class _MapaPageMobileState extends State<MapaPageMobile>
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
          drawer:  Drawer(
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
                      }
                  )
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Tecnico: ',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
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
                      ],
                    ),
                    
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      children: [
                        Text(
                          'Cliente: ',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ButtonDelegate(
                            colorSeleccionado: Colors.black,
                            nombreProvider: 'Mapa'),
                      ],
                    ),
                        const SizedBox(
                          height: 10,
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
