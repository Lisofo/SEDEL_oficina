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

import '../../../../models/cliente.dart';
import '../../../../models/orden.dart';
import '../../../../models/tecnico.dart';
import '../../../../provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';

class OrdenPlanMobile extends StatefulWidget {
  const OrdenPlanMobile({super.key});

  @override
  State<OrdenPlanMobile> createState() => _OrdenPlanMobileState();
}

class _OrdenPlanMobileState extends State<OrdenPlanMobile> {
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
  final ordenServices = OrdenServices();
  // late Cliente _clienteSeleccionado = context.read<OrdenProvider>().cliente;
  late String token = '';
  final TextEditingController nroOrdenController = TextEditingController();
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

  void updateFilteredItems(List<Orden> filteredOrdenes) {
    setState(() {
      ordenesFiltradas = filteredOrdenes; // Actualiza la lista con los elementos filtrados
    });
  }

  Future<void> buscar(String token) async {
    late Cliente clienteSeleccionado = context.read<OrdenProvider>().clienteOrdenes;
    print(clienteSeleccionado.clienteId.toString());
    String fechaDesde = ('${selectedDate.start.year}-${selectedDate.start.month}-${selectedDate.start.day}');
    String fechaHasta = ('${selectedDate.end.year}-${selectedDate.end.month}-${selectedDate.end.day}');

    String tecnicoId = selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';

    List<Orden> results = await ordenServices.getOrden(
      context, 
      clienteSeleccionado.clienteId.toString(),
      tecnicoId,
      fechaDesde,
      fechaHasta,
      nroOrdenController.text,
      selectedEstado!,
      selectedTipo.tipoOrdenId,
      token,
    );
    setState(() {
      ordenesFiltradas = results;
    });
  }


  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    tipoOrden = await OrdenServices().getTipoOrden(context, token);
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
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.95,
        child:Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: colors.primary, width: 15)),  
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Seleccione periodo: '),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(colors.secondary),
                              shape: MaterialStatePropertyAll(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)))
                            ),
                            onPressed: () async {
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
                            // print(pickedDate.start);
                            // print(pickedDate.end);
                            },
                            child: const Text('Período',style: TextStyle(color: Colors.black),),
                          ),
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

                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tecnico: '),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownSearch(
                        dropdownDecoratorProps:
                            const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    hintText: 'Seleccione un tecnico')),
                        items: tecnicos,
                        popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchDelay: Duration.zero),
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
                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Estado: '),
                    const SizedBox(
                      width: 10,
                    ),
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
                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),
                 const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Cliente: '),
                    SizedBox(
                      width: 10,
                    ),
                    ButtonDelegate(
                      colorSeleccionado: Colors.black,
                      nombreProvider: 'Ordenes',
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tipo de orden: '),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 220,
                      child: CustomDropdownFormMenu(
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
                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Nro. Orden:'),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: 200,
                        child: CustomTextFormField(
                          controller: nroOrdenController,
                          maxLines: 1,
                        ))
                  ],
                ),
                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 30,),
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
                        router.pop();
                      break;
                      
                    }  
                  },
                  showUnselectedLabels: true,
                  selectedItemColor: colors.primary,
                  unselectedItemColor: Colors.grey,
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
      ),
      body: Row(
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
                          Row(
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
                              Column(
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
                                  
                                  Text(ordenesFiltradas[i].cliente.codCliente),
                                  
                                  // ignore: sized_box_for_whitespace
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.85,
                                    child: Text(ordenesFiltradas[i].cliente.nombre,softWrap: true,),
                                  ),
                                  Text(
                                      'Tecnico: ${ordenesFiltradas[i].tecnico.nombre}'),
                                  Text(
                                      'Tipo de orden: ${ordenesFiltradas[i].tipoOrden.descripcion}'),
                                  Text(
                                      'Estado: ${ordenesFiltradas[i].estado}'),
                              
                              
                              
                                  const SizedBox(height: 20,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            const TextSpan(text: 'Inicio: '),
                                            TextSpan(
                                              text: DateFormat("E d, MMM HH:mm", 'es').format(ordenesFiltradas[i].fechaDesde),
                                            ),
                              
                                          ]
                                        )
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            const TextSpan(text: 'Finalizacion: '),
                                            TextSpan(
                                              text: DateFormat("E d, MMM HH:mm", 'es').format(ordenesFiltradas[i].fechaHasta),
                                            ),
                              
                                          ]
                                        )
                                      ),
                                    ],
                                  )
                              
                                ],
                              ),
                            ],
                          ),
                          
                          //const Spacer(),
                          // Flexible(
                          //   flex: 2,
                          //   child: Wrap(children: [
                          //     for (var j = 0; j < ordenesFiltradas[i].servicio.length; j++) ...[
                          //       Text('${ordenesFiltradas[i].servicio[j].descripcion} | '),
                          //     ],
                          //   ]),
                          // ),


                          
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}


