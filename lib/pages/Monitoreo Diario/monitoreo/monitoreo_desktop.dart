// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';

import '../../../models/tecnico.dart';

class MonitoreoDesktop extends StatefulWidget {
  const MonitoreoDesktop({super.key});

  @override
  _MonitoreoDesktopState createState() => _MonitoreoDesktopState();
}

class _MonitoreoDesktopState extends State<MonitoreoDesktop> {
  List<Tecnico> tecnicos = [];
  List<Orden> ordenes = [];
  List<String> estados = [
    'Pendiente',
    'En Proceso',
    'Finalizada',
    'Revisada',
  ];
  late String token = '';
  Tecnico? selectedTecnico;
  final _ordenServices = OrdenServices();
  DateTime selectedDate = DateTime.now();
  int tecnicoFiltro = 0;
  int clienteFiltro = 0;
  List<Orden> ordenesPendientes = [];
  List<Orden> ordenesEnProceso = [];
  List<Orden> ordenesFinalizadas = [];
  List<Orden> ordenesRevisadas = [];
  Map<String, Color> colores = {
    'Pendiente': Colors.yellow.shade200,
    'En Proceso': Colors.greenAccent.shade400,
    'Revisada': Colors.blue.shade400,
    'Finalizada': Colors.red.shade200
  };
  Map<String, Color> coloresCampanita = {
    'PENDIENTE': Colors.yellow.shade200,
    'EN PROCESO': Colors.greenAccent.shade400,
    'REVISADA': Colors.blue.shade400,
    'FINALIZADA': Colors.red.shade200
  };
  late Cliente clienteSeleccionado;
  List<Orden> ordenesCampanita = [];
  late DateTime hoy = DateTime.now();
  late DateTime mesesAtras = DateTime(hoy.year, hoy.month - 3, hoy.day);
  late DateTime ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);
  late String desde = DateFormat('yyyy-MM-dd', 'es').format(mesesAtras);
  late String hasta = DateFormat('yyyy-MM-dd', 'es').format(ayer);

  @override
  void initState() {
    super.initState();
    clienteSeleccionado = Cliente.empty();
    Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('Monitoreo');

    cargarListas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
    cargarDatos();
  }

  cargarDatos() async {
    token = context.watch<OrdenProvider>().token;
    ordenesCampanita = await OrdenServices().getOrdenCampanita(context, desde, hasta, 'PENDIENTE, EN PROCESO, FINALIZADA', 1, token);
    setState(() {});
  }

  Future<void> loadTecnicos() async {
    final token = context.watch<OrdenProvider>().token;
    final loadedTecnicos = await TecnicoServices().getAllTecnicos(context, token);

    setState(() {
      tecnicos = loadedTecnicos;
      tecnicos.insert(
          0,
          Tecnico(
          cargoId: 0,
          tecnicoId: 0,
          codTecnico: '0',
          nombre: 'Todos',
          fechaNacimiento: null,
          documento: '',
          fechaIngreso: null,
          fechaVtoCarneSalud: null,
          deshabilitado: false,
          firmaPath: '' ,
          firmaMd5: '' ,
          avatarPath: '' ,
          avatarMd5: '' ,
          cargo: null, verDiaSiguiente: null,
        ));
    });
  }

  Future<void> buscar(String token) async {
    clienteSeleccionado = context.read<OrdenProvider>().clienteMonitoreo;
    print(clienteSeleccionado.clienteId.toString());

    String tecnicoId = selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';
    String fechaDesde = DateFormat('yyyy-MM-dd', 'es').format(selectedDate);

    List<Orden> results = await _ordenServices.getOrden(
      context, 
      clienteSeleccionado.clienteId.toString(),
      tecnicoId,
      fechaDesde,
      fechaDesde,
      '',
      '',
      0,
      token,
      false
    );
    setState(() {
      ordenes = results;
    });
  }

  void cargarListas() {
    List<Orden> ordenesFiltradas = [];
    ordenesFiltradas = ordenes
        .where((e) =>
            (clienteFiltro > 0 ? e.cliente.clienteId == clienteFiltro : true) &&
            (tecnicoFiltro > 0 ? e.tecnico.tecnicoId == tecnicoFiltro : true))
        .toList();
    ordenesPendientes.clear();
    ordenesEnProceso.clear();
    ordenesFinalizadas.clear();
    ordenesRevisadas.clear();
    for (var orden in ordenesFiltradas) {
      switch (orden.estado.toLowerCase()) {
        case 'pendiente':
          ordenesPendientes.add(orden);
          break;
        case 'en proceso':
          ordenesEnProceso.add(orden);
          break;
        case 'finalizada':
          ordenesFinalizadas.add(orden);
          break;
        case 'revisada':
          ordenesRevisadas.add(orden);
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Monitoreo de ordenes',
        ),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
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
                        width: 20,
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
                        nombreProvider: 'Monitoreo',
                      ),
                      IconButton(
                        onPressed: () async {
                          await buscar(token);
                          cargarListas();
                        },
                        icon: const Icon(Icons.search_outlined),
                        tooltip: 'Buscar',
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await ordenesARevisar(context);
                        },
                        tooltip: 'Ordenes a revisar',  
                        icon: ordenesCampanita.isEmpty ? Icon(Icons.notifications, color: colors.primary,) : Icon(Icons.notifications_active, color: colors.primary,)
                      ),
                      IconButton(
                        tooltip: 'Seleccione fecha',
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
                              print(selectedDate);
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month)
                      ),
                      const Text('Fecha: ',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(DateFormat("E d, MMM", 'es').format(selectedDate),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(5)),
                  height: 30,
                  child: const Center(
                    child: Text(
                      'Ordenes de trabajo',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: estados.map((estado) {
                    final color = colores[estado];
                    return Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 60,
                        width: 170,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              '$estado (${ordenes.where((orden) => orden.estado.toLowerCase() == estado.toLowerCase()).length})',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: 450,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: ordenesPendientes.length,
                              itemBuilder: (context, index) {
                                return cardsDeLaLista(ordenesPendientes, index, 'Pendiente');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: 450,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: ordenesEnProceso.length,
                              itemBuilder: (context, index) {
                                return cardsDeLaLista(ordenesEnProceso, index, 'En Proceso');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: 450,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: ordenesFinalizadas.length,
                              itemBuilder: (context, index) {
                                return cardsDeLaLista(ordenesFinalizadas, index, 'Finalizada');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: 450,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: ordenesRevisadas.length,
                              itemBuilder: (context, index) {
                                return cardsDeLaLista(ordenesRevisadas, index, 'Revisada');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> ordenesARevisar(BuildContext context) async {
    ordenesCampanita = await OrdenServices().getOrdenCampanita(context, desde, hasta, 'PENDIENTE, EN PROCESO, FINALIZADA', 1000, token);
    await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Ordenes a revisar"),
          content: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.68,
                width: MediaQuery.of(context).size.width * 0.3,
                child: ListView.builder(
                  itemCount: ordenesCampanita.length,
                  itemBuilder: (context, i) {
                    var orden = ordenesCampanita[i];
                    return ListTile(
                      isThreeLine: true,
                      leading: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: coloresCampanita[orden.estado],),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${orden.ordenTrabajoId}', style: const TextStyle(color: Colors.white),),
                        )
                      ),
                      title: Text(orden.cliente.nombre, style: const TextStyle(fontWeight: FontWeight.w600),),
                      subtitle: Text('${orden.tecnico.nombre} \nEstado: ${orden.estado}'),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat("E d, MMM HH:mm", 'es').format(orden.fechaDesde)),
                          Text(DateFormat("E d, MMM HH:mm", 'es').format(orden.fechaHasta)),
                        ],
                      ),
                      onTap: () {
                        Provider.of<OrdenProvider>(context, listen: false).setOrden(orden);
                        Navigator.of(context).pop();
                        router.push('/editOrden');
                      },
                    );
                  },
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: (){router.pop();}, 
              child: const Text('Cerrar')
            )
          ],
        );
      },
    );
  }

  cardsDeLaLista(List<Orden> orden, int i, String color) {
    return InkWell(
      onTap: () {
        Provider.of<OrdenProvider>(context, listen: false).setOrden(orden[i]);
        router.push('/editOrden');
      },
      child: Card(
        color: colores[color],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Orden  ${orden[i].ordenTrabajoId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                )
              ),
              Text('Tecnico: ${orden[i].tecnico.nombre}''\n${orden[i].cliente.codCliente} Cliente: ${orden[i].cliente.nombre}'),
              Text('Fecha Desde: ${DateFormat("E d, MMM, HH:mm", 'es').format(orden[i].fechaDesde)}'),
              Text('Fecha Hasta: ${DateFormat("E d, MMM, HH:mm", 'es').format(orden[i].fechaHasta)}'),
              if(orden[i].estado != 'PENDIENTE')...[
                Text(orden[i].iniciadaEn == null ? '' : 'Iniciada: ${_formatDateAndTime(orden[i].iniciadaEn)}'),
                if(orden[i].estado != 'EN PROCESO')
                Text(orden[i].finalizadaEn == null ? '' : 'Finalizada: ${_formatDateAndTime(orden[i].finalizadaEn)}')
              ],
              Text(orden[i].tipoOrden.descripcion),
              Text(orden[i].estado),
              // for (var i = 0; i < orden[index].servicios.length; i++) ...[
              //   Text(orden[index].servicios[i].descripcion)
              // ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateAndTime(DateTime? date) {
    return '${date?.day.toString().padLeft(2, '0')}/${date?.month.toString().padLeft(2, '0')}/${date?.year.toString().padLeft(4, '0')} ${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}';
  }

}
