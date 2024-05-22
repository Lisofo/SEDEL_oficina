// ignore_for_file: avoid_print, file_names, use_build_context_synchronously

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/indisponibilidades.dart';
import 'package:sedel_oficina_maqueta/services/indis_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:intl/intl.dart';
import '../../../models/cliente.dart';
import '../../../models/tecnico.dart';
import '../../../provider/orden_provider.dart';

class IndisponibilidadesMobile extends StatefulWidget {
  const IndisponibilidadesMobile({super.key});

  @override
  State<IndisponibilidadesMobile> createState() =>
      _IndisponibilidadesMobileState();
}

class _IndisponibilidadesMobileState extends State<IndisponibilidadesMobile> {
  List<Tecnico> tecnicos = [];

  List<TipoIndisponibilidad> tipoIndisponibilidad = [];
  List<Indisponibilidad> indisponibilidades = [];
  Tecnico? selectedTecnico;
  Cliente? selectedCliente;
  TipoIndisponibilidad? selectedTipo;
  int tecnicoFiltro = 0;
  int clienteFiltro = 0;
  final TextEditingController _comentarioController = TextEditingController();
  final _indisponibilidadServices = IndisponibilidadServices();
  late String token = '';
  late DateTimeRange selectedDate =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  int buttonIndex = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    tipoIndisponibilidad = await IndisponibilidadServices()
        .getTiposIndisponibilidades(context, token);
    tipoIndisponibilidad.insert(
        0,
        TipoIndisponibilidad(
            tipoIndisponibilidadId: 0,
            codTipoIndisponibilidad: '0',
            descripcion: 'TODAS'));
    Provider.of<OrdenProvider>(context, listen: false)
        .clearSelectedCliente('Indisponibilidad');
    selectedCliente = Cliente.empty();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
  }

  Future<void> loadTecnicos() async {
    final loadedTecnicos =
        await TecnicoServices().getAllTecnicos(context, token);
    setState(() {
      tecnicos = loadedTecnicos;
      tecnicos.insert(
          0,
          Tecnico(
              tecnicoId: 0,
              codTecnico: '0',
              nombre: 'TODOS',
              fechaNacimiento: DateTime.now(),
              documento: '',
              fechaIngreso: DateTime.now(),
              fechaVtoCarneSalud: DateTime.now(),
              deshabilitado: false,
              cargo: Cargo.empty(),
              cargoId: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Indisponibilidades',
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Seleccione periodo: '),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(colors.secondary)
                  ),
                    onPressed: () async {
                      final pickedDate = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2025));
        
                      if (pickedDate != null &&
                          pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          print(selectedDate);
                        });
                      }
                      print(pickedDate?.start);
                      print(pickedDate?.end);
                    },
                    child: const Text(
                      'Período',
                      style: TextStyle(color: Colors.black),
                    )),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text: DateFormat('dd/MM/yyyy', 'es')
                              .format(selectedDate.start)),
                      const TextSpan(text: ' - '),
                      TextSpan(
                          text: DateFormat('dd/MM/yyyy', 'es')
                              .format(selectedDate.end)),
                    ]))
              ],
            ),
            const SizedBox(height: 10,),
            Divider(
              color: colors.primary,
              endIndent: 20,
              indent: 20,
            ),
            const SizedBox(height: 10,),
            Column(
              children: [
                const Text('Tecnico: '),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5)),
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
            const SizedBox(height: 10,),
            Divider(
              color: colors.primary,
              endIndent: 20,
              indent: 20,
            ),
            const SizedBox(height: 10,),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Cliente: '),
                ButtonDelegate(
                  colorSeleccionado: Colors.black,
                  nombreProvider: 'Indisponibilidad',
                )
              ],
            ),
            const SizedBox(height: 10,),
            Divider(
              color: colors.primary,
              endIndent: 20,
              indent: 20,
            ),
            const SizedBox(height: 10,),
            Column(
              children: [
                const Text('Tipo de indisponibilidad: '),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: CustomDropdownFormMenu(
                    hint: 'Tipo de indisponibilidad',
                    value: selectedTipo,
                    onChanged: (value) {
                      setState(() {
                        selectedTipo = value;
                      });
                    },
                    items: tipoIndisponibilidad.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.descripcion),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Divider(
              color: colors.primary,
              endIndent: 20,
              indent: 20,
            ),
            const SizedBox(height: 10,),
            Column(
              children: [
                const Text('Comentario'),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: CustomTextFormField(
                    controller: _comentarioController,
                    maxLines: 1,
                  ),
                )
              ],
            ),
            const Spacer(),
            BottomNavigationBar(
                  currentIndex: buttonIndex,
                  onTap: (index) async{   
                    buttonIndex = index;
                    switch (buttonIndex){
                      case 0:
                        Provider.of<OrdenProvider>(context, listen: false).clearSelectedIndisponibilidad();
                        router.push('/editIndisponibilidades');
                      break; 
                      case 1:
                        await buscar(context);
                        router.pop();
                      break;
                      
                    }  
                  },
                  showUnselectedLabels: true,
                  selectedItemColor: colors.primary,
                  unselectedItemColor: colors.primary,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_comment_outlined),
                      label: 'Crear Indisponibilidad',
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
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: indisponibilidades.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setIndisponibilidad(indisponibilidades[i]);
                          router.push('/editIndisponibilidades');
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: CircleAvatar(
                                          backgroundColor: colors.primary,
                                          foregroundColor: Colors.white,
                                          child: Text(indisponibilidades[i]
                                              .indisponibilidadId
                                              .toString()),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          children: [
                                            if (indisponibilidades[i].cliente?.clienteId !=0)
                                              Text('Cliente: ${indisponibilidades[i].cliente!.codCliente} ${indisponibilidades[i].cliente!.nombre}'),
                                            if (indisponibilidades[i].tecnico?.tecnicoId !=0)
                                              Text('Tecnico: ${indisponibilidades[i].tecnico!.nombre}'),
                                            Text('Tipo de indisponibilidad: ${indisponibilidades[i].tipoIndisponibilidad.descripcion}')
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text(DateFormat("E d, MMM, HH:mm", 'es').format(indisponibilidades[i].desde)),
                                      Text(DateFormat("E d, MMM, HH:mm", 'es').format(indisponibilidades[i].hasta)),
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

  Future<void> buscar(BuildContext context) async {
    selectedCliente = context.read<OrdenProvider>().clienteIndisponibilidad;

    String fechaDesde =
        ('${selectedDate.start.year}-${selectedDate.start.month}-${selectedDate.start.day}');
    String fechaHasta =
        ('${selectedDate.end.year}-${selectedDate.end.month}-${selectedDate.end.day} 23:59:59');

    String tecnicoId =
        selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';
    String tipoIndis = selectedTipo != null
        ? selectedTipo!.tipoIndisponibilidadId.toString()
        : '0';

    List<Indisponibilidad> results =
        await _indisponibilidadServices.getIndisponibilidad(
            context,
            _comentarioController.text,
            fechaDesde,
            fechaHasta,
            tipoIndis,
            tecnicoId,
            selectedCliente!.clienteId.toString(),
            token);
    setState(() {
      indisponibilidades = results;
    });
  }
}
