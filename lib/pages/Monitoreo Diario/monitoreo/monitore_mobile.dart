// ignore_for_file: avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

import '../../../config/router/app_router.dart';
import '../../../models/cliente.dart';
import '../../../models/orden.dart';
import '../../../models/tecnico.dart';
import '../../../provider/orden_provider.dart';
import '../../../services/orden_services.dart';
import '../../../widgets/appbar_desktop.dart';
import '../../../widgets/button_delegate.dart';

class MonitoreoMobile extends StatefulWidget {
  const MonitoreoMobile({super.key});

  @override
  State<MonitoreoMobile> createState() => _MonitoreoMobileState();
}

class _MonitoreoMobileState extends State<MonitoreoMobile> {
  List<Tecnico> tecnicos = [];
  List<Orden> ordenes = [];
  List<String> estados = [
    'Pendiente',
    'En Proceso',
    'Finalizada',
    'Revisada',
  ];
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
  late Cliente clienteSeleccionado;
  late final PageController _pageController = PageController(initialPage: 0);
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    clienteSeleccionado = Cliente.empty();
    cargarListas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
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
              cargo: null));
    });
  }

  Future<void> buscar(String token) async {
    clienteSeleccionado = context.read<OrdenProvider>().clienteMonitoreo;
    Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('Monitoreo');
    // print(clienteSeleccionado.clienteId.toString());

    String tecnicoId =
        selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';
    String fechaDesde =
        ('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}');

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
  final token = context.watch<OrdenProvider>().token;
  final colors = Theme.of(context).colorScheme;
  return SafeArea(
    child: Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Monitoreo de ordenes',
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: colors.primary, width: 15)),  
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Column(
                  children: [
                    const Text(
                      'Tecnico: ',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10,),
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
                    const Divider(height: 50,),
                    const Text(
                      'Cliente: ',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    const FittedBox(
                      fit: BoxFit.contain,
                      child: ButtonDelegate(
                        colorSeleccionado: Colors.black,
                        nombreProvider: 'Monitoreo',
                      ),
                    ),
                  ],
                ),              
                const Divider(height: 50,),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Seleccione fecha'),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2099),
                      context: context,
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        print(selectedDate);
                      });
                    }
                  },
                ),
                Text(
                  DateFormat('d/MM/yyyy').format(selectedDate), style: const TextStyle(fontSize: 20),
                ),
                const Divider(height: 50,),
                CustomButton(
                  text: 'Buscar',
                  onPressed: () async {
                    await buscar(token);
                    cargarListas();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        scrollDirection: Axis.horizontal,
          children: [
            _buildEstadoContainer('Pendiente', ordenesPendientes),
            _buildEstadoContainer('En Proceso', ordenesEnProceso),
            _buildEstadoContainer('Finalizada', ordenesFinalizadas),
            _buildEstadoContainer('Revisada', ordenesRevisadas),
          ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        showUnselectedLabels: true,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pendiente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'En Proceso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Finalizada',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Revisada',
          ),
        ],
      ),
    ),
  );
}

  cardsDeLaLista(List<Orden> orden, int index, String color) {
    return InkWell(
      onTap: () {
        Provider.of<OrdenProvider>(context, listen: false)
            .setOrden(orden[index]);
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
                'Orden  ${orden[index].ordenTrabajoId}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              )),
              Text('Tecnico: ${orden[index].tecnico.nombre}'
                  '\n${orden[index].cliente.codCliente} Cliente: ${orden[index].cliente.nombre}'),
              Text(
                  'Fecha Desde: ${DateFormat("E d, MMM, HH:mm", 'es').format(orden[index].fechaDesde)}'),
              Text(
                  'Fecha Hasta: ${DateFormat("E d, MMM, HH:mm", 'es').format(orden[index].fechaHasta)}'),
              Text(orden[index].tipoOrden.descripcion),
              Text(orden[index].estado),
              // for (var i = 0; i < orden[index].servicios.length; i++) ...[
              //   Text(orden[index].servicios[i].descripcion)
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoContainer(String estado, List<Orden> ordenesEstado) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Container(
              decoration: BoxDecoration(
                color: colores[estado],
                borderRadius: BorderRadius.circular(5)),
              height: 30,
              child: Center(
                child: Text(
                  estado,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ordenesEstado.length,
              itemBuilder: (context, index) {
                return cardsDeLaLista(ordenesEstado, index, estado);
              },
            ),
          ),
        ],
      ),
    );
  }

}