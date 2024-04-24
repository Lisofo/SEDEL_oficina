// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/planificacion_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';

import '../provider/orden_provider.dart';

class CustomizedTimetableMobile extends StatefulWidget {
  const CustomizedTimetableMobile({super.key});
  @override
  State<CustomizedTimetableMobile> createState() =>
      _CustomizedTimetableMobileState();
}

class _CustomizedTimetableMobileState extends State<CustomizedTimetableMobile> {
  late List<TimetableItem<Orden>> items = [];
  final controller = TimetableController(
    start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 30)),
    initialColumns: 7,
    cellHeight: 100.0,
  );
  Tecnico? selectedTecnico;
  late DateTimeRange selectedDate = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  late DateTime nuevaFecha = selectedDate.start;
  late DateTimeRange selectedDatePlanificacion = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  int tecnicoFiltro = 0;
  int clienteFiltro = 0;
  List<Tecnico> tecnicos = [];
  List<Orden> ordenes = [];
  final _ordenServices = OrdenServices();
  Map<String, Color> colores = {
    'PENDIENTE': Colors.yellow.shade200,
    'EN PROCESO': Colors.greenAccent.shade400,
    'REVISADA': Colors.blue.shade400,
    'FINALIZADA': Colors.red.shade200
  };
  late String token = ' ';
  late Cliente clienteSeleccionado = Cliente.empty();
  bool cargando = false;
  late List<Orden> ordenesFiltradas = [];
  int columnas = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.jumpTo(DateTime.now());
      });
    });
    Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('Planificador');
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
    clienteSeleccionado = context.read<OrdenProvider>().clientePlanificador;

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

  Orden obtenerOrden(int ordenId) {
    var x = ordenes.where((orden) => orden.ordenTrabajoId == ordenId).toList();
    return x[0];
  }

  myFittedBox(texto) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        texto,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  List<TimetableItem<Orden>> generateItems3(List<Orden> lista) {
    final items = <TimetableItem<Orden>>[];
    for (var e in lista) {
      items.add(TimetableItem(
        e.fechaDesde,
        e.fechaHasta,
        data: e,
      ));
    }
    return items;
  }

  void generarPlanificacion() async {
    if (clienteSeleccionado.clienteId.toString() == '0' && tecnicoFiltro.toString() == '0') {
      ordenes = await _ordenServices.getOrden(context, '', '', '', '', '', '', 0, token);
    } else {
      ordenes = await _ordenServices.getOrden(
        context, 
        clienteSeleccionado.clienteId.toString(),
        tecnicoFiltro.toString(),
        '',
        '',
        '',
        '',
        0,
        token);
    }
  }

  void cargarPlanificacion() {
    ordenesFiltradas = ordenes
        .where((e) =>
            (clienteFiltro > 0 ? e.cliente.clienteId == clienteFiltro : true) &&
            (tecnicoFiltro > 0 ? e.tecnico.tecnicoId == tecnicoFiltro : true))
        .toList();
    items = generateItems3(ordenesFiltradas);
  }

  addDay() {
    
      nuevaFecha = nuevaFecha.add(const Duration(days: 1));
    
  }

  subtractDay() {
      nuevaFecha = nuevaFecha.subtract(const Duration(days: 1));
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    token = context.read<OrdenProvider>().token;
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Planificador',
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width *0.9,
        child: Column(
          children: [

          SizedBox(
            width: 220,
            child: DropdownSearch(
              dropdownDecoratorProps: const DropDownDecoratorProps(
                textAlign: TextAlign.center,
                  baseStyle: TextStyle(color: Colors.black),
                  dropdownSearchDecoration: InputDecoration(
                    border: InputBorder.none,
                      hintText: 'Tecnico',
                      hintStyle: TextStyle(color: Colors.black))),
              items: tecnicos,
              popupProps: const PopupProps.menu(
                  showSearchBox: true, searchDelay: Duration.zero),
              onChanged: (value) {
                setState(() {
                  selectedTecnico = value;
                  tecnicoFiltro = value!.tecnicoId;
                  print(clienteSeleccionado.nombre);
                });
              },
            ),
          ),
          Divider(
            thickness: 3,
            color: colors.primary,
          ),
          const ButtonDelegate(
            colorSeleccionado: Colors.black,
            nombreProvider: 'Planificador',
          ),
          Divider(
            thickness: 3,
            color: colors.primary,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                  maximumSize: MaterialStatePropertyAll(Size.fromWidth(MediaQuery.of(context).size.width * 0.5 )),
                  backgroundColor: MaterialStatePropertyAll(colors.secondary),
                  shape: MaterialStatePropertyAll(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)))
                ),
                  onPressed: () async {
                    final pickedDate = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2025));
              
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        nuevaFecha = pickedDate.start;
                      });
                    }
                  },
                  child: const Text(
                    'Período',
                    style: TextStyle(color: Colors.black),
                  )
              ),
              IconButton(
                onPressed: () async {
                  await buscar(token);
                  cargarPlanificacion();
                },
                icon: const Icon(Icons.search_outlined),
                tooltip: 'Buscar',
                style: const ButtonStyle(
                    iconColor: MaterialStatePropertyAll(Colors.black)),
              ),
            ],
          ),
          
          const SizedBox(width: 10,),
          Text('${DateFormat("EEEEE d MMMM", 'es').format(selectedDate.start)} - ${DateFormat("EEEEE d MMMM", 'es').format(selectedDate.end)}',
            style: const TextStyle(color: Colors.black),
          ),
          Divider(
            thickness: 3,
            color: colors.primary,
          ),
          Text(
            '${ordenesFiltradas.isEmpty ? '0' : ordenesFiltradas.length} Ordenes', 
            style: const TextStyle(color: Colors.black),
          ),
          const Spacer(),
          const Divider(),
          Wrap(
            
            children: [
              IconButton(
                onPressed: () async {
                await generadorPlanificacion(context);
                },
                icon:  Icon(Icons.play_lesson_rounded, color: colors.primary,),
                tooltip: 'Generar planificador',
              ),
              TextButton(
                child:  Text(
                  "Hoy",
                  style: TextStyle(color: colors.primary),
                ),
                onPressed: () => controller.jumpTo(DateTime.now()),
              ),
              IconButton(
                icon: const Icon(Icons.start),
                style:  ButtonStyle(
                    iconColor: MaterialStatePropertyAll(colors.primary)),
                onPressed: () {
                  nuevaFecha = selectedDate.start;  
                  controller.jumpTo(selectedDate.start);
                } ,
                tooltip: 'Inicio del período',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_view_day),
                style:  ButtonStyle(
                    iconColor: MaterialStatePropertyAll(colors.primary)),
                onPressed: () {
                  controller.setColumns(1);
                  columnas = 1;
                } ,
                tooltip: 'Vista día',
              ),
              // IconButton(
              //   icon: const Icon(Icons.calendar_view_month_outlined),
              //   style:  ButtonStyle(
              //       iconColor: MaterialStatePropertyAll(colors.primary)),
              //   onPressed: () => controller.setColumns(30),
              //   tooltip: 'Vista mensual',
              // ),
              IconButton(
                icon: const Icon(Icons.calendar_view_week),
                style:  ButtonStyle(
                    iconColor: MaterialStatePropertyAll(colors.primary)),
                onPressed: () {
                  controller.setColumns(7);
                  columnas = 7;
                } ,
                tooltip: 'Vista semanal',
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                style:  ButtonStyle(
                    iconColor: MaterialStatePropertyAll(colors.primary)),
                onPressed: () =>
                    controller.setCellHeight(controller.cellHeight + 10),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out),
                style:  ButtonStyle(
                    iconColor: MaterialStatePropertyAll(colors.primary)),
                onPressed: () =>
                    controller.setCellHeight(controller.cellHeight - 10),
              ),
            ],
          ),
          ],
        ),
      ),
      body: cargando ? const Center(child: Column(
        children: [
          Text('GENERANDO PLANIFICACIÓN',style: TextStyle(fontSize: 24),),
          SizedBox(height: 10,),
          CircularProgressIndicator(),
        ],
      ),) : Timetable<Orden>(
        controller: controller,
        items: items,
        cornerBuilder: (datetime) => Container(
          color: Colors.accents[datetime.day % Colors.accents.length],
          child: Center(child: Text("${datetime.year}")),
        ),
        headerCellBuilder: (datetime) {
          final color = Colors.primaries[datetime.day % Colors.accents.length];
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color, width: 2)),
            ),
            child: Center(
              child: FittedBox(
                child: Text(
                  DateFormat("E\nMMM d", 'es').format(datetime),
                  style: TextStyle(
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
        hourLabelBuilder: (time) {
          final hour = time.hour == 12 ? 12 : time.hour % 12;
          final period = time.hour < 12 ? "am" : "pm";
          final isCurrentHour = time.hour == DateTime.now().hour;
          return Text(
            "$hour$period",
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
        itemBuilder: (item) => InkWell(
          onTap: () {
            final orden = obtenerOrden(item.data!.ordenTrabajoId);
            Provider.of<OrdenProvider>(context, listen: false).setOrden(orden);
            router.push('/editOrden');
          },
          child: Container(
            decoration: BoxDecoration(
              color: colores[item.data!.estado],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          '${item.data!.ordenTrabajoId}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if(columnas == 1) ... [
                        myFittedBox('${item.data!.cliente.codCliente} ${item.data!.cliente.nombre}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            myFittedBox(item.data!.tipoOrden.descripcion),
                            const SizedBox(width: 30,),
                            if(item.data!.tipoOrden.tipoOrdenId == 1) ... [
                              const Icon(Icons.web) // normal
                            ] else if(item.data!.tipoOrden.tipoOrdenId == 2) ...[
                              const Icon(Icons.align_horizontal_left_rounded) // diagnostico
                            ] else if (item.data!.tipoOrden.tipoOrdenId == 3) ... [
                              const Icon(Icons.fact_check_rounded), // control de calidad
                            ]
                          ],
                        ),
                        
                        myFittedBox(item.data!.estado),
                      ] else ... [
                        myFittedBox(item.data!.cliente.codCliente),
                        if(item.data!.tipoOrden.tipoOrdenId == 1) ... [
                          const Icon(Icons.web) // normal
                        ] else if(item.data!.tipoOrden.tipoOrdenId == 2) ...[
                          const Icon(Icons.align_horizontal_left_rounded) // diagnostico
                        ] else if (item.data!.tipoOrden.tipoOrdenId == 3) ... [
                          const Icon(Icons.fact_check_rounded) // control de calidad
                        ]
                      ],
                      
                      // for (var i = 0; i < item.data!.servicio.length; i++) ...[
                      //   myFittedBox(item.data!.servicio[i].descripcion)
                      // ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        nowIndicatorColor: Colors.red,
        snapToDay: true,
      ),
    );
  }

   generadorPlanificacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Generar planificación',
            style: TextStyle(fontSize: 25),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Se va a generar la planificación automática para el período '),
                TextSpan(
                  text: '${DateFormat("d/MM/yyyy", 'es').format(selectedDatePlanificacion.start)} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'hasta el '),
                TextSpan(
                  text: DateFormat("d/MM/yyyy", 'es').format(selectedDatePlanificacion.end),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            Column(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035));

                    if (pickedDate != null && pickedDate != selectedDatePlanificacion) {
                      setState(() {
                        selectedDatePlanificacion = pickedDate;
                        print(selectedDatePlanificacion);
                      });
                    }
                    Navigator.pop(context);
                    generadorPlanificacion(context);
                    
                  },
                  icon: const Icon(Icons.date_range),
                  label: const Text('Editar fechas')
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                    onPressed: () async {
                      router.pop(context);
                      await cargandoPlanificacion();
                    },
                    child: const Text('Confirmar')
                    ),
                    TextButton(
                      onPressed: () {
                       router.pop(context);
                     },
                      child: const Text('Cancelar')
                    ),
                  ],
                )
                
                
              ],
            )
            
          ],
        );
      },
    );
  }

   Future<void> cargandoPlanificacion() async {
      String fechaDesde =
        ('${selectedDatePlanificacion.start.year}-${selectedDatePlanificacion.start.month}-${selectedDatePlanificacion.start.day}');
    String fechaHasta =
        ('${selectedDatePlanificacion.end.year}-${selectedDatePlanificacion.end.month}-${selectedDatePlanificacion.end.day}');
     setState(() {
       cargando = true;
     });
     await PlanificacionServices().generarPlanificacion(context,fechaDesde,fechaHasta,token);
     setState(() {
       cargando = false;
     });
   }

  Future<void> buscar(String token) async {
    clienteSeleccionado = context.read<OrdenProvider>().clientePlanificador;
    print(clienteSeleccionado.nombre);
    print(clienteSeleccionado.clienteId.toString());
    print(clienteSeleccionado);

    String fechaDesde = ('${selectedDate.start.year}-${selectedDate.start.month}-${selectedDate.start.day}');
    String fechaHasta = ('${selectedDate.end.year}-${selectedDate.end.month}-${selectedDate.end.day}');

    String tecnicoId = selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';

    List<Orden> results = await _ordenServices.getOrden(
      context, 
      clienteSeleccionado.clienteId.toString(),
      tecnicoId,
      fechaDesde,
      fechaHasta,
      '',
      '',
      0,
      token,
    );
    setState(() {
      ordenes = results;
    });
  }

}
