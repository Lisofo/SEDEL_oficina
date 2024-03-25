// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';

import '../../../models/orden.dart';
import '../../../provider/orden_provider.dart';

class OrdenPlanificacionDesktop extends StatefulWidget {
  const OrdenPlanificacionDesktop({super.key});

  @override
  State<OrdenPlanificacionDesktop> createState() =>
      _OrdenPlanificacionDesktopState();
}

class _OrdenPlanificacionDesktopState extends State<OrdenPlanificacionDesktop> {
  late Orden orden;
  Map<String, Color> colores = {
    'PENDIENTE': Colors.yellow.shade200,
    'EN PROCESO': Colors.greenAccent.shade400,
    'REVISADA': Colors.blue.shade400,
    'FINALIZADA': Colors.red.shade200
  };
  late String token = '';
  List<Tecnico> tecnicos = [];
  late Tecnico? selectedTecnico;
  late bool editarOrden = false;
  late String dateTime;
  DateTime selectedDateOrden = DateTime.now();
  DateTime selectedDateDesde = DateTime.now();
  DateTime selectedDateHasta = DateTime.now();
  final TextEditingController _dateOrdenController = TextEditingController();
  final TextEditingController _dateDesdeController = TextEditingController();
  final TextEditingController _dateHastaController = TextEditingController();
  final TextEditingController _instruccionesController = TextEditingController();
  List<Servicio> servicios = [];
  List<Servicio> serviciosSeleccionados = [];

  @override
  void initState() {
    super.initState();
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
    orden = context.read<OrdenProvider>().orden;
    token = context.read<OrdenProvider>().token;
    servicios =
        await ServiciosServices().getServicios(context, '', '', '', token);
    editarOrden =
        orden.estado == 'PENDIENTE' ? editarOrden = true : editarOrden = false;
    selectedDateOrden = orden.fechaOrdenTrabajo;
    selectedDateDesde = orden.fechaDesde;
    selectedDateHasta = orden.fechaHasta;
    setState(() {});
  }

  Future<void> loadTecnicos() async {
    final loadedTecnicos = await TecnicoServices().getAllTecnicos(context, token);

    setState(() {
      tecnicos = loadedTecnicos;
    });
  }

  @override
  Widget build(BuildContext context) {
    _instruccionesController.text = orden.instrucciones;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBarDesign(
          titulo: 'Detalles de la orden',
        ),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colores[orden.estado],
                        borderRadius: BorderRadius.circular(5)),
                    height: 30,
                    child: const Center(
                      child: Text(
                        'Detalles',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 650,
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nombre del cliente: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      orden.cliente.nombre,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Codigo del cliente: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      orden.cliente.codCliente,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Direccion del cliente: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      orden.cliente.direccion,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Telefono del cliente: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      orden.cliente.telefono1,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 650,
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nro. Orden: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Orden ${orden.ordenTrabajoId}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Fecha de la orden: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                  text: DateFormat(
                                                          'E, d , MMM, yyyy',
                                                          'es')
                                                      .format(
                                                          selectedDateOrden)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrden)
                                          TextButton.icon(
                                              onPressed: () {
                                                _selectDateOrden(context);
                                              },
                                              icon: const Icon(Icons.calendar_today),
                                              label: const Text(
                                                  'Editar fecha de la orden'))
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Fecha desde: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                  text: DateFormat(
                                                          'E d , MMM, yyyy, HH:mm',
                                                          'es')
                                                      .format(
                                                          selectedDateDesde)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrden)
                                          TextButton.icon(
                                              onPressed: () {
                                                _selectFechaDesde(context);
                                              },
                                              icon: const Icon(Icons.calendar_today),
                                              label: const Text(
                                                  'Editar fecha desde de la orden'))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Fecha hasta: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                  text: DateFormat(
                                                          'E d , MMM, yyyy, HH:mm',
                                                          'es')
                                                      .format(
                                                          selectedDateHasta)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrden)
                                          TextButton.icon(
                                              onPressed: () {
                                                _selectFechaHasta(context);
                                              },
                                              icon: const Icon(Icons.calendar_today),
                                              label: const Text(
                                                  'Editar fecha hasta de la orden'))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Estado: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          orden.estado,
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Tipo de Orden: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(orden.tipoOrden.descripcion,
                                            style: const TextStyle(fontSize: 16))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Tecnico: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(orden.tecnico.nombre,
                                            style: const TextStyle(fontSize: 16))
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Servicios: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    // if (orden.estado == 'PENDIENTE')
                                    //   Container(
                                    //     width: 400,
                                    //     child: DropdownSearch<
                                    //         Servicio>.multiSelection(
                                    //       items: servicios,
                                    //       popupProps:
                                    //           PopupPropsMultiSelection.menu(),
                                    //       onChanged: (value) {
                                    //         serviciosSeleccionados = (value);
                                    //         for (int i = 0;
                                    //             i <
                                    //                 serviciosSeleccionados
                                    //                     .length;
                                    //             i++) {
                                    //           // orden.servicio.add(serviciosSeleccionados[i]);
                                    //         }
                                    //       },
                                    //     ),
                                    //   ),
                                    for (var i = 0;
                                        i < orden.servicio.length;
                                        i++) ...[
                                      Text(
                                        orden.servicio[i].descripcion,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notas del cliente: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(255, 52, 120, 62),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                enabled: false,
                                maxLines: 20,
                                initialValue: orden.cliente.notas,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    fillColor: Colors.white,
                                    filled: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instrucciones: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(255, 52, 120, 62),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                enabled: editarOrden,
                                maxLines: 20,
                                controller: _instruccionesController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    fillColor: Colors.white,
                                    filled: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'Cambiar tecnico',
                  onPressed: () {
                    cambiarTecnico();
                  },
                  disabled: orden.estado == 'DESCARTADA',
                  tamano: 20,
                ),
                const SizedBox(
                  width: 30,
                ),
                CustomButton(
                  text: 'Cambiar estado',
                  onPressed: () {
                    cambiarEstado();
                  },
                  disabled: orden.estado == 'DESCARTADA',
                  tamano: 20,
                ),
                const SizedBox(
                  width: 30,
                ),
                CustomButton(
                  text: 'Guardar',
                  onPressed: orden.estado == 'PENDIENTE'
                      ? () => datosAGuardar(context)
                      : null,
                  tamano: 20,
                  disabled: orden.estado != 'PENDIENTE',
                ),
                // SizedBox(
                //   width: 30,
                // ),
                // CustomButton(
                //   text: 'Eliminar',
                //   onPressed: () {},
                //   tamano: 20,
                // ),
                const SizedBox(width: 30),
                CustomButton(
                  text: 'Revisión',
                  onPressed: (orden.estado == 'EN PROCESO' ||
                          orden.estado == 'FINALIZADA' ||
                          orden.estado == 'REVISADA')
                      ? () => router.push('/revisionOrden')
                      : null,
                  disabled: orden.estado == 'PENDIENTE' ||
                      orden.estado == 'DESCARTADA',
                  tamano: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> datosAGuardar(BuildContext context) async {
    orden.fechaOrdenTrabajo = selectedDateOrden;
    orden.fechaDesde = selectedDateDesde;
    orden.fechaHasta = selectedDateHasta;
    orden.instrucciones = _instruccionesController.text;

    await OrdenServices().putOrden(context, orden, token);
  }

  void cambiarEstado() {
    late String nuevoEstado = '';
    if (orden.estado == 'EN PROCESO') {
      nuevoEstado = 'PENDIENTE';
    } else if (orden.estado == 'FINALIZADA') {
      nuevoEstado = 'EN PROCESO';
    } else if (orden.estado == 'PENDIENTE') {
      nuevoEstado = 'DESCARTADA';
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cambio de estado de la orden'),
            content: Text(
                'Esta por cambiar el estado de la orden ${orden.ordenTrabajoId}. Esta seguro de querer cambiar el estado de ${orden.estado} a $nuevoEstado?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar')),
              TextButton(
                  onPressed: () async {
                    await OrdenServices()
                        .patchOrden(context, orden, nuevoEstado, 0, token);
                    await OrdenServices.showDialogs(
                        context, 'Estado cambiado correctamente', true, false);
                    setState(() {
                      orden.estado = nuevoEstado;
                    });
                  },
                  child: const Text('Confirmar')),
            ],
          );
        });
  }

  void cambiarTecnico() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cambio de estado de la orden'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Esta por cambiar el tecnico de la orden ${orden.ordenTrabajoId} ${orden.tecnico.nombre}. Esta seguro de querer cambiar el tecnico?'),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 300,
                  child: CustomDropdownFormMenu(
                    hint: 'Seleccione un nuevo tecnico',
                    onChanged: (value) {
                      selectedTecnico = value;
                      setState(() {});
                    },
                    value: selectedTecnico,
                    items: tecnicos.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.nombre),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    selectedTecnico = null;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar')),
              TextButton(
                  onPressed: () async {
                    await OrdenServices().cambiarTecnicoDeLaOrden(
                        context, orden, selectedTecnico!.tecnicoId, token);
                    await OrdenServices.showDialogs(
                        context, 'Tecnico cambiado correctamente', true, true);
                    setState(() {
                      orden.tecnico = selectedTecnico!;
                    });
                  },
                  child: const Text('Confirmar')),
            ],
          );
        });
  }

  Future<Null> _selectDateOrden(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDateOrden,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2099));
    if (picked != null) {
      setState(() {
        selectedDateOrden = picked;
        selectedDateHasta = picked;
        selectedDateDesde = picked;
        _dateOrdenController.text = DateFormat.yMd().format(selectedDateOrden);
      });
    }
  }

  Future<Null> _selectFechaDesde(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar fecha y hora desde'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('E d , MMM, yyyy', 'es')
                    .format(selectedDateDesde)),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDateDesde,
                    initialDatePickerMode: DatePickerMode.day,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(2099),
                  );
                  if (picked != null) {
                    selectedDateDesde = picked;
                    _dateDesdeController.text =
                        DateFormat.yMd().format(selectedDateDesde);
                    setState(() {});
                  }
                },
              ),
              ListTile(
                title: const Text('Hora'),
                subtitle: Text(
                    '${selectedDateDesde.hour}:${selectedDateDesde.minute}'),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateDesde),
                  );
                  if (pickedTime != null) {
                    selectedDateDesde = DateTime(
                      selectedDateDesde.year,
                      selectedDateDesde.month,
                      selectedDateDesde.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Confirmar')),
          ],
        );
      },
    );
  }

  Future<Null> _selectFechaHasta(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar fecha y hora desde'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('E d , MMM, yyyy', 'es')
                    .format(selectedDateHasta)),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDateHasta,
                    initialDatePickerMode: DatePickerMode.day,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(2099),
                  );
                  if (picked != null) {
                    selectedDateHasta = picked;
                    _dateHastaController.text =
                        DateFormat.yMd().format(selectedDateHasta);
                    setState(() {});
                  }
                },
              ),
              ListTile(
                title: const Text('Hora'),
                subtitle: Text(
                    '${selectedDateHasta.hour}:${selectedDateHasta.minute}'),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateHasta),
                  );
                  if (pickedTime != null) {
                    selectedDateHasta = DateTime(
                      selectedDateHasta.year,
                      selectedDateHasta.month,
                      selectedDateHasta.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Confirmar')),
          ],
        );
      },
    );
  }
}
