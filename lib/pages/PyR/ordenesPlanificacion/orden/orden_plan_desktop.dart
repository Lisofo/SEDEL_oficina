// ignore_for_file: avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';

import '../../../../models/cliente.dart';
import '../../../../models/orden.dart';
import '../../../../models/tecnico.dart';
import '../../../../provider/orden_provider.dart';
import '../../../../widgets/drawer.dart';

class OrdenPlanDesktop extends StatefulWidget {
  const OrdenPlanDesktop({super.key});

  @override
  State<OrdenPlanDesktop> createState() => _OrdenPlanDesktopState();
}

class _OrdenPlanDesktopState extends State<OrdenPlanDesktop> {
  List<Tecnico> tecnicos = [];
  List<Orden> ordenes = [];
  List<String> estados = [
    '',
    'Pendiente',
    'En Proceso',
    'Finalizada',
    'Revisada',
    'Descartada'
  ];
  List<String> servicios = [];
  List<String> materiales = [];
  late List<TipoOrden> tipoOrden = [];
  List<Orden> ordenesFiltradas = [];
  String? selectedServicio;
  String? selectedMaterial;
  late DateTimeRange selectedDate = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  Tecnico? selectedTecnico;
  String? selectedEstado = '';
  late TipoOrden selectedTipo = TipoOrden.empty();
  int tecnicoFiltro = 0;
  int clienteFiltro = 0;
  final _ordenServices = OrdenServices();
  // late Cliente _clienteSeleccionado = context.read<OrdenProvider>().cliente;
  late String token = '';
  final TextEditingController _nroOrdenController = TextEditingController();
  int buttonIndex = 0;

  void filtro() {
    ordenesFiltradas = ordenes
        .where((e) =>
            (clienteFiltro > 0 ? e.cliente.clienteId == clienteFiltro : true) &&
            (tecnicoFiltro > 0 ? e.tecnico.tecnicoId == tecnicoFiltro : true) &&
            (selectedEstado != 'Todos' ? e.estado == selectedEstado : true) &&
            (selectedTipo.descripcion != 'Todos' ? e.tipoOrden == selectedTipo : true))
        .toList();
    print(ordenes.length);
    print("ordenesFiltradas después de filtro: ${ordenesFiltradas.length}");
  }

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
    tipoOrden = await OrdenServices().getTipoOrden(context, token);
    tipoOrden.insert(
      0,
      TipoOrden(
        tipoOrdenId: 0, 
        codTipoOrden: '0', 
        descripcion: 'TODAS'
      )
    );
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
          cargo: null
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Ordenes de trabajo',),
      drawer: const Drawer(child: BotonesDrawer(),),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: Card(
              elevation: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Seleccione periodo: '),
                          const SizedBox(width: 10,),
                          IconButton(
                            color: colors.secondary,
                            onPressed: () async{
                              final pickedDate = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2025)
                              );
                              if (pickedDate != null && pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                  print(selectedDate);
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_month)
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.start)
                            ),
                            const TextSpan(text: ' - '),
                            TextSpan(
                              text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.end)
                            ),
                          ]
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Divider(
                    thickness: 0.5,
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  const SizedBox(height: 3,),
                  Column(
                    children: [
                      const Text('Tecnico: '),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownSearch(
                          dropdownDecoratorProps:
                          const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Seleccione un tecnico'
                            )
                          ),
                          items: tecnicos,
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchDelay: Duration.zero
                          ),
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
                  const SizedBox(height: 3,),
                  Divider(
                    thickness: 0.5,
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Estado: '),
                      const SizedBox(width: 10,),
                      DropdownButton(
                        hint: const Text('Estado'),
                        value: selectedEstado,
                        onChanged: (value) {
                          setState(() {
                            selectedEstado = value;
                          });
                        },
                        items: estados.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Divider(
                    thickness: 0.5,
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  const SizedBox(height: 3,),
                  const Column(
                    children: [
                      Text('Cliente: '),
                      ButtonDelegate(
                        colorSeleccionado: Colors.black,
                        nombreProvider: 'Ordenes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Divider(
                    thickness: 0.5,
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  const SizedBox(height: 3,),
                  // Row(
                  //   children: [
                  //     Text('Servicios: '),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     DropdownButton(
                  //       hint: Text('Servicios'),
                  //       itemHeight: null,
                  //       value: selectedServicio,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           selectedServicio = value;
                  //         });
                  //       },
                  //       items: servicios.map((e) {
                  //         return DropdownMenuItem(
                  //           child: SizedBox(
                  //             width: 300,
                  //             child: Text(
                  //               e,
                  //               overflow: TextOverflow.fade,
                  //             ),
                  //           ),
                  //           value: e,
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Row(
                  //   children: [
                  //     Text('Materiales: '),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     DropdownButton(
                  //       hint: Text('Materiales'),
                  //       value: selectedMaterial,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           selectedMaterial = value;
                  //         });
                  //       },
                  //       items: materiales.map((e) {
                  //         return DropdownMenuItem(
                  //           child: SizedBox(width: 300, child: Text(e)),
                  //           value: e,
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Column(
                    children: [
                      const Text('Tipo de orden: '),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 220,
                        child: CustomDropdownFormMenu(
                          isDense: true,
                          items: tipoOrden.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e.descripcion));
                          }).toList(),
                          onChanged: (value){
                            selectedTipo = value;
                          }
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Divider(
                    thickness: 0.5,
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    children: [
                      const Text('Nro. Orden:'),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                          width: 200,
                          child: CustomTextFormField(
                            controller: _nroOrdenController,
                            maxLines: 1,
                          ))
                    ],
                  ),
                  
              
                  const Spacer(),
              
                  BottomNavigationBar(
                    currentIndex: buttonIndex,
                    onTap: (index) async{   
                      buttonIndex = index;
                      switch (buttonIndex){
                        case 0: 
                          Provider.of<OrdenProvider>(context,listen: false).clearSelectedOrden();
                          router.push('/editOrden');
                          setState(() {});
                        case 1:
                          await buscar(token);
                          updateFilteredItems(ordenesFiltradas);
                          setState(() {});
                        break;
                        
                      }  
                    },
                    showUnselectedLabels: true,
                    selectedItemColor: colors.primary,
                    unselectedItemColor: colors.primary,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_comment_outlined),
                        label: 'Crear Orden',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: 'Buscar'
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: ordenesFiltradas.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setOrden(ordenesFiltradas[i]);
                          router.push('/editOrden');
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Flexible(
                                      //   flex: 1,
                                      //   child: CircleAvatar(
                                      //     minRadius: 10,
                                      //     maxRadius: 30,
                                      //     backgroundColor: colors.primary,
                                      //     foregroundColor: Colors.white,
                                      //     child: Text(ordenesFiltradas[i].ordenTrabajoId.toString()),
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   width: 30,
                                      // ),
                                      Flexible(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('${ordenesFiltradas[i].ordenTrabajoId}', style: const TextStyle(color: Colors.white),),
                                              )
                                            ),
                                            const SizedBox(height: 30,),
                                            Text(
                                                '${ordenesFiltradas[i].cliente.codCliente} ${ordenesFiltradas[i].cliente.nombre}'),
                                            Row(
                                              children: [
                                                Text(
                                                    'Tecnico: ${ordenesFiltradas[i].tecnico.nombre}'),
                                              ],
                                            ),
                                            Text(
                                                'Tipo de orden: ${ordenesFiltradas[i].tipoOrden.descripcion}'),
                                            Text(
                                                'Estado: ${ordenesFiltradas[i].estado}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  flex: 2,
                                  child: Wrap(children: [
                                    for (var j = 0; j < ordenesFiltradas[i].servicio.length; j++) ...[
                                      Text('${ordenesFiltradas[i].servicio[j].descripcion} | '),
                                    ],
                                  ]),
                                ),
                                const Spacer(),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text(DateFormat("E d, MMM HH:mm", 'es').format(
                                          ordenesFiltradas[i].fechaDesde)),
                                      Text(DateFormat("E d, MMM HH:mm", 'es').format(
                                          ordenesFiltradas[i].fechaHasta)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  void updateFilteredItems(List<Orden> filteredOrdenes) {
    setState(() {
      ordenesFiltradas = filteredOrdenes; // Actualiza la lista con los elementos filtrados
    });
  }




  Future<void> buscar(String token) async {
    late Cliente clienteSeleccionado = context.read<OrdenProvider>().clienteOrdenes;
    print(clienteSeleccionado.clienteId.toString());
    String fechaDesde = DateFormat('yyyy-MM-dd', 'es').format(selectedDate.start);
    String fechaHasta = DateFormat('yyyy-MM-dd', 'es').format(selectedDate.end);
    String tecnicoId = selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';
    
    List<Orden> results = await _ordenServices.getOrden(
      context, 
      clienteSeleccionado.clienteId.toString(),
      tecnicoId,
      fechaDesde,
      fechaHasta,
      _nroOrdenController.text,
      selectedEstado!,
      selectedTipo.tipoOrdenId,
      token,
    );
    setState(() {
      ordenesFiltradas = results;
    });
  }
}
