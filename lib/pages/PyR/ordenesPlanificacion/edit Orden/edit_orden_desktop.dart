// ignore_for_file: use_build_context_synchronously, avoid_init_to_null

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/constancia_visita.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/servicios_ordenes.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/search/client_delegate.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EditOrdenDesktop extends StatefulWidget {
  const EditOrdenDesktop({super.key});

  @override
  State<EditOrdenDesktop> createState() => _EditOrdenDesktopState();
}

class _EditOrdenDesktopState extends State<EditOrdenDesktop> {
  late Orden orden = Orden.empty();
  Map<String, Color> colores = {
    'PENDIENTE': Colors.yellow.shade200,
    'EN PROCESO': Colors.greenAccent.shade400,
    'REVISADA': Colors.blue.shade400,
    'FINALIZADA': Colors.red.shade200
  };
  late String token = '';
  List<Tecnico> tecnicos = [];
  late Tecnico? selectedTecnico = null;
  late Tecnico? selectedTecnicoInicial = Tecnico.empty();
  late bool editarOrden = true;
  late bool editarOrdenFechas = true;
  late String dateTime;
  DateTime selectedDateOrden = DateTime.now();
  DateTime selectedDateDesde = DateTime.now();
  DateTime selectedDateHasta = DateTime.now();
  final TextEditingController _dateOrdenController = TextEditingController();
  final TextEditingController _dateDesdeController = TextEditingController();
  final TextEditingController _dateHastaController = TextEditingController();
  final TextEditingController _instruccionesController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _notasClienteController = TextEditingController();
  List<Servicio> servicios = [];
  List<Servicio> serviciosSeleccionados = [];
  late List<TipoOrden> tipoOrdenes = [];
  late TipoOrden selectedTipoOrden = TipoOrden.empty();
  late TipoOrden? tipoOrdenInicial = null;
  late Cliente selectedCliente = Cliente.empty();
  List<Cliente> historial = [];
  int tecnicoFiltro = 0;
  int buttonIndex = 2;
  bool yaCargue = false;
  List<ConstanciaVisita> constanciasOrden = [];

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
    token = context.read<OrdenProvider>().token;
    orden = context.read<OrdenProvider>().orden;
    selectedCliente = context.read<OrdenProvider>().clienteEditOrdenes;
    servicios = await ServiciosServices().getServicios(context, '', '', '', token);
    tipoOrdenes = await OrdenServices().getTipoOrden(context, token);
    if(orden.estado == 'REVISADA') {
      constanciasOrden = await OrdenServices().getOrdenCV(context, orden.ordenTrabajoId, token);
    }
    if(orden.ordenTrabajoId != 0){
      selectedDateOrden = orden.fechaOrdenTrabajo;
      selectedDateDesde = orden.fechaDesde;
      selectedDateHasta = orden.fechaHasta;
    }else{
      selectedDateDesde = DateTime(selectedDateDesde.year, selectedDateDesde.month, selectedDateDesde.day, selectedDateDesde.hour, selectedDateDesde.minute, 0);
      selectedDateHasta = DateTime(selectedDateHasta.year, selectedDateHasta.month, selectedDateHasta.day, selectedDateHasta.hour, selectedDateHasta.minute, 0);
      selectedDateOrden = orden.fechaOrdenTrabajo;
    }
    if(orden.ordenTrabajoId != 0 && orden.estado != 'PENDIENTE'){
      editarOrdenFechas = false;
    }
    yaCargue = true;
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
    final colors = Theme.of(context).colorScheme;
    if(orden.ordenTrabajoId != 0){
      tipoOrdenInicial = orden.tipoOrden;
      _instruccionesController.text = orden.instrucciones;
      _comentarioController.text = orden.comentarios;
      _notasClienteController.text = orden.cliente.notas;
      
      if(serviciosSeleccionados.isEmpty){
        List<Servicio> prueba = convertirServiciosOrden();
        serviciosSeleccionados = prueba;
      }
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBarDesktop(
          titulo: orden.ordenTrabajoId == 0 ? 'Detalles de la orden' : 'Detalles de la orden ${orden.ordenTrabajoId}',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colores[orden.estado],
                      borderRadius: BorderRadius.circular(5)
                    ),
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
                      const SizedBox(width: 30,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 650,
                            child: Card(
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(orden.ordenTrabajoId == 0)...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final cliente = await showSearch(
                                                context: context,
                                                delegate: ClientSearchDelegate('Buscar Cliente', historial, '')
                                              );
                                              if (cliente != null) {
                                                setState(() {
                                                  selectedCliente = cliente;
                                                  selectedTecnico = selectedCliente.tecnico;
                                                  _notasClienteController.text = selectedCliente.notas;
                                                  final int clienteExiste = historial.indexWhere((element) => element.nombre == cliente.nombre);
                                                  if (clienteExiste == -1) {
                                                    historial.insert(0, cliente);
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  selectedCliente = Cliente.empty();
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.edit,color: colors.secondary,)
                                          )
                                        ],
                                      ),
                                    ],
                                    const Text('*  Nombre del cliente: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    Text(
                                      orden.ordenTrabajoId == 0 ? selectedCliente.nombre : orden.cliente.nombre,
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
                                      orden.ordenTrabajoId == 0 ? selectedCliente.codCliente : orden.cliente.codCliente,
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
                                      orden.ordenTrabajoId == 0 ? selectedCliente.direccion : orden.cliente.direccion,
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
                                      orden.ordenTrabajoId == 0 ? selectedCliente.telefono1 : orden.cliente.telefono1,
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
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
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
                                                  text: '*  Fecha de la orden: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                text: DateFormat('E, d , MMM, yyyy', 'es').format(selectedDateOrden)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrdenFechas)...[
                                          IconButton(
                                            onPressed: () {
                                              _selectDateOrden(context);
                                            },
                                            icon: Icon(Icons.edit, color: colors.secondary,),
                                          )
                                        ]
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
                                                  text: '*  Fecha desde: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                  text: DateFormat('E d , MMM, yyyy, HH:mm','es').format(selectedDateDesde)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrdenFechas)
                                          IconButton(
                                            onPressed: () {
                                              _selectFechaDesde(context);
                                            },
                                            icon: Icon(Icons.edit, color: colors.secondary,),
                                          )
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
                                                  text: '*  Fecha hasta: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              TextSpan(
                                                  text: DateFormat('E d , MMM, yyyy, HH:mm', 'es').format(selectedDateHasta)),
                                            ],
                                          ),
                                        ),
                                        if (editarOrdenFechas)
                                          IconButton(
                                            onPressed: () {
                                              _selectFechaHasta(context);
                                            },
                                            icon: Icon(Icons.edit, color: colors.secondary,),
                                          )
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
                                          '*  Tipo de Orden: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(orden.tipoOrden.descripcion,
                                            style:
                                                const TextStyle(fontSize: 16))
                                      ],
                                    ),
                                    if(orden.ordenTrabajoId == 0)
                                    SizedBox(
                                      width: 250,
                                      child: CustomDropdownFormMenu(
                                        isDense: true,
                                        value: tipoOrdenInicial,
                                        hint: 'Seleccione tipo de orden',
                                        items: tipoOrdenes.map((e) {
                                          return DropdownMenuItem(
                                            value: e,
                                            child: Text(e.descripcion)
                                          );
                                        }).toList(),
                                        onChanged: (value){
                                          selectedTipoOrden = value;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const Text(
                                          '* Tecnico: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        Text(
                                          orden.ordenTrabajoId == 0 ? '' : orden.tecnico.nombre,
                                          style: const TextStyle(fontSize: 16)
                                        )
                                      ],
                                    ),
                                    if(orden.ordenTrabajoId == 0)
                                    Container(
                                      width: 220,
                                      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                                      child: DropdownSearch(
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Seleccione un tecnico'
                                          )
                                        ),
                                        selectedItem: selectedCliente.tecnico,
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
                                    const SizedBox(height: 10),
                                    const Text(
                                      '*  Servicios: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    if(/*orden.ordenTrabajoId == 0 &&*/ (orden.estado == 'PENDIENTE' || orden.estado == 'EN PROCESO'))
                                    SizedBox(
                                      width: 400,
                                      child: DropdownSearch<Servicio>(
                                        items: servicios,
                                        popupProps: const PopupProps.menu(
                                          showSearchBox: true, searchDelay: Duration.zero),
                                        onChanged: (value) {
                                          print(value);
                                          serviciosSeleccionados.insert(0, value!);
                                          print(serviciosSeleccionados);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    if(/*orden.ordenTrabajoId != 0*/serviciosSeleccionados.isNotEmpty && (orden.estado == 'PENDIENTE' || orden.estado == 'EN PROCESO'))...[
                                      SizedBox(
                                      height: 250,
                                      child: ListView.builder(
                                        itemCount: serviciosSeleccionados.length,
                                        itemBuilder: (context, i){
                                          final servicio = serviciosSeleccionados[i];
                                          return ListTile(
                                            title: Text(servicio.descripcion),
                                            trailing: IconButton(
                                              onPressed: (){
                                                serviciosSeleccionados.removeAt(i);
                                                setState(() {});
                                              }, 
                                              icon: const Icon(Icons.delete, color: Colors.red,)
                                            ),
                                          );
                                        }),
                                      )
                                    ]else if (orden.ordenTrabajoId != 0 && (orden.estado == 'FINALIZADA' || orden.estado == 'REVISADA'))...[
                                      SizedBox(
                                      height: 250,
                                      child: ListView.builder(
                                        itemCount: orden.servicio.length,
                                        itemBuilder: (context, i){
                                          final servicio = orden.servicio[i];
                                          return ListTile(
                                            title: Text(servicio.descripcion),
                                          );
                                        }),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notas del cliente: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colors.primary,
                                width: 2),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: TextFormField(
                              enabled: false,
                              maxLines: 8,
                              minLines: 2,
                              controller: _notasClienteController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.white,
                                filled: true
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Instrucciones: ',
                              style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colors.primary,
                                width: 2
                              ),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: TextFormField(
                              enabled: editarOrden,
                              maxLines: 8,
                              minLines: 2,
                              controller: _instruccionesController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.white,
                                filled: true
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          const Text(
                            'Comentario:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),    
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colors.primary,
                                width: 2
                              ),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: TextFormField(
                              enabled: editarOrden,
                              maxLines: 8,
                              minLines: 2,
                              controller: _comentarioController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.white,
                                filled: true
                              ),
                            ),
                          ),
                          if(orden.estado == 'REVISADA')...[
                            const SizedBox(height: 10,),
                            const Text(
                              'Constancias:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ), 
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.primary,
                                  width: 2
                                ),
                                color: colors.onPrimary,
                                borderRadius: BorderRadius.circular(5)
                              ),
                              height: MediaQuery.of(context).size.height * 0.45,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: ListView.separated(
                                itemCount: constanciasOrden.length,
                                itemBuilder: (context, i) {
                                  var item = constanciasOrden[i];
                                  return ListTile(
                                    style: ListTileStyle.list,
                                    title: Text(item.filename),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.picture_as_pdf,
                                        color: colors.primary,
                                      ),
                                      onPressed: () async {
                                        await abrirPDF(item.filepath, token);
                                      }
                                    ),
                                  );
                                },
                                separatorBuilder: (context, i) {
                                  return Divider(
                                    color: colors.primary,
                                  );
                                }, 
                              ),
                            )
                          ]
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(

          currentIndex: buttonIndex,
          onTap: (index) {
            setState(() {
              buttonIndex = index;
              switch (buttonIndex){
                case 0: 
                if(orden.estado == 'PENDIENTE' || orden.estado == 'EN PROCESO'){
                  datosAGuardar(context);
                }else{
                  null;
                }
                break;
                case 1:
                if(orden.estado == 'DESCARTADA'){
                  null;
                }else{
                  cambiarEstado();
                }
                break;
                case 2:
                if(orden.estado == 'DESCARTADA'){
                  null;
                }else if(orden.estado == 'PENDIENTE'){
                  cambiarTecnico();
                }else{
                  null;
                }
                break;
                case 3:
                  if(orden.estado == 'EN PROCESO' || orden.estado == 'FINALIZADA' || orden.estado == 'REVISADA'){
                    router.push('/revisionOrden');
                  }else{
                    null;
                  }
                break;
              }

            });
          },
          showUnselectedLabels: true,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.primary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.save_as),
              label: 'Guardar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_backup_restore_rounded),
              label: 'Cambiar Estado',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Cambiar Tecnico',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: 'Revision',
            ),
          ],
        ),
      ),
    );
  }

 Future<void> datosAGuardar(BuildContext context) async {
  DateTime fechaOrden = DateTime(selectedDateOrden.year, selectedDateOrden.month, selectedDateOrden.day);
  
  
  orden.fechaOrdenTrabajo = fechaOrden;
  orden.fechaDesde = selectedDateDesde;
  orden.fechaHasta = selectedDateHasta;
  orden.instrucciones = _instruccionesController.text;
  orden.comentarios = _comentarioController.text;
  List<ServicioOrdenes> serviciosOrdenes = convertirServicios();
  orden.servicio = serviciosOrdenes;
  
  if (orden.ordenTrabajoId == 0) {
    orden.cliente = selectedCliente;
    orden.tipoOrden = selectedTipoOrden;
    orden.tecnico = selectedTecnico!;

    await OrdenServices().postOrden(context, orden, token);
  }else{
    await OrdenServices().putOrden(context, orden, token);
  }
  setState(() {});
}

 List<ServicioOrdenes> convertirServicios() {
   List<ServicioOrdenes> serviciosOrdenes = serviciosSeleccionados.map((servicio) {
     return ServicioOrdenes(
      servicioId: servicio.servicioId,
      codServicio: servicio.codServicio,
      descripcion: servicio.descripcion,
     );
   }).toList();
   return serviciosOrdenes;
 }

 List<Servicio> convertirServiciosOrden() {
   List<Servicio> ordenesServicios = orden.servicio.map((servicio) {
     return Servicio(
      servicioId: servicio.servicioId,
      codServicio: servicio.codServicio,
      descripcion: servicio.descripcion,
      tipoServicio: TipoServicio.empty(),
     );
   }).toList();
   return ordenesServicios;
 }


  void cambiarEstado() {
    late String nuevoEstado = '';
    if (orden.estado == 'EN PROCESO') {
      nuevoEstado = 'PENDIENTE';
    } else if (orden.estado == 'FINALIZADA') {
      nuevoEstado = 'EN PROCESO';
    } else if (orden.estado == 'PENDIENTE') {
      nuevoEstado = 'DESCARTADA';
    } else if(orden.estado == 'REVISADA') {
      nuevoEstado = 'FINALIZADA';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambio de estado de la orden'),
          content: Text('Esta por cambiar el estado de la orden ${orden.ordenTrabajoId}. Esta seguro de querer cambiar el estado de ${orden.estado} a $nuevoEstado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar')
            ),
            TextButton(
              onPressed: () async {
                await OrdenServices().patchOrden(context, orden, nuevoEstado, 0, token);
                await OrdenServices.showDialogs(context, 'Estado cambiado correctamente', true, false);
                setState(() {
                  orden.estado = nuevoEstado;
                });
              },
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    );
  }

  void cambiarTecnico() {
    if(orden.tecnico.tecnicoId != 0){
      selectedTecnicoInicial = tecnicos.firstWhere((tec) => tec.tecnicoId == orden.tecnico.tecnicoId);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambio de Tecnico de la orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Esta por cambiar el tecnico de la orden ${orden.ordenTrabajoId} ${orden.tecnico.nombre}. Esta seguro de querer cambiar el tecnico?'),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 220,
                decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                child: DropdownSearch(
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Seleccione un tecnico'
                    )
                  ),
                  items: tecnicos,
                  selectedItem: selectedTecnicoInicial,
                  popupProps: const PopupProps.menu(showSearchBox: true, searchDelay: Duration.zero),
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
          actions: [
            TextButton(
              onPressed: () {
                selectedTecnico = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar')
            ),
            TextButton(
              onPressed: () async {
                await OrdenServices().cambiarTecnicoDeLaOrden(context, orden, selectedTecnico!.tecnicoId, token);
                await OrdenServices.showDialogs(context, 'Tecnico cambiado correctamente', true, false);
                setState(() {
                  orden.tecnico = selectedTecnico!;
                });
              },
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    );
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
          content: StatefulBuilder(
            builder: (context, setStateBd)=> Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('E d , MMM, yyyy', 'es').format(selectedDateDesde)),
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
                      _dateDesdeController.text = DateFormat.yMd().format(selectedDateDesde);
                      setStateBd(() {});
                    }
                  },
                ),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text('${DateFormat('HH', 'es').format(selectedDateDesde)}:${DateFormat('mm', 'es').format(selectedDateDesde)}'),
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
                    setStateBd(() {});
                  },
                ),
              ],
            ),
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
                  setState(() {});
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
          title: const Text('Seleccionar fecha y hora hasta'),
          content: StatefulBuilder(
            builder: (context, setStateBd) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('E d , MMM, yyyy', 'es').format(selectedDateHasta)),
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
                      setStateBd(() {});
                    }
                  },
                ),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text('${DateFormat('HH', 'es').format(selectedDateHasta)}:${DateFormat('mm', 'es').format(selectedDateHasta)}'),
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
                    setStateBd(() {});
                  },
                ),
              ],
            ),
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
                  setState(() {});
                },
                child: const Text('Confirmar')),
          ],
        );
      },
    );
  }

  abrirPDF(String url, String token) async {
    Dio dio = Dio();
    String link = url += '?authorization=$token';
    print(link);
    try {
      // Realizar la solicitud HTTP con el encabezado de autorización
      Response response = await dio.get(
        link,
        options: Options(
          headers: {
            'Authorization': 'headers $token',
          },
        ),                      
      );
      // Verificar si la solicitud fue exitosa (código de estado 200)
      if (response.statusCode == 200) {
        // Si la respuesta fue exitosa, abrir la URL en el navegador
        Uri uri = Uri.parse(url);
        await launchUrl(uri);
      } else {
        // Si la solicitud no fue exitosa, mostrar un mensaje de error
        print('Error al cargar la URL: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores de solicitud
      print('Error al realizar la solicitud: $e');
    }
  }
}