// ignore_for_file: avoid_init_to_null

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/estado_cliente.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/client_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../../models/cliente.dart';
import '../../../../services/tecnico_services.dart';

class ClientesMobile extends StatefulWidget {
  const ClientesMobile({super.key});

  @override
  State<ClientesMobile> createState() => _ClientesMobileState();
}

class _ClientesMobileState extends State<ClientesMobile> {
  final _clientServices = ClientServices();
  final _nombreController = TextEditingController();
  final _codController = TextEditingController();
  List<Tecnico> tecnicos = [];
  List<Cliente> searchResults = [];
  Tecnico? selectedTecnico;
  int tecnicoFiltro = 0;
  late List<EstadoCliente> estados = [
    EstadoCliente(codEstado: 'A', descripcion: 'Activo'),
    EstadoCliente(codEstado: 'S', descripcion: 'Suspendido'),
    EstadoCliente(codEstado: 'D', descripcion: 'Deshabilitado'),
  ];
  late EstadoCliente? estadoSeleccionado = null;
  late String token = '';

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

  @override
  void dispose() {
    _nombreController.dispose();
    _codController.dispose();
    super.dispose();
  }

  Future<void> loadTecnicos() async {
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
    estados.insert(0, EstadoCliente(codEstado: '', descripcion: 'Todos'));
  }

  cargarDatos() {
    token = context.read<OrdenProvider>().token;
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Clientes',
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
                    const Text('Codigo: ', style: TextStyle(
                      fontSize: 18,
                    ),),
                    SizedBox(
                      width: 300,
                      child: CustomTextFormField(
                        hint: 'Buscar codigo de cliente',
                        maxLines: 1,
                        controller: _codController,
                        onFieldSubmitted: (value) async {
                          value = _codController.text;
                          await buscar(
                            _nombreController.text,
                            value,
                            estadoSeleccionado?.codEstado,
                            tecnicoFiltro.toString(),
                            token
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 50,),
                Column(
                  children: [
                    const Text('Nombre: ', style: TextStyle(
                      fontSize: 18,
                    ),),
                    SizedBox(
                      width: 300,
                      child: CustomTextFormField(
                        controller: _nombreController,
                        maxLines: 1,
                        hint: 'Buscar nombre de cliente',
                        onFieldSubmitted: (value) async {
                          String query = value;
                          await buscar(
                            query,
                            _codController.text,
                            estadoSeleccionado?.codEstado,
                            tecnicoFiltro.toString(),
                            token
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 50,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Estado  ', style: TextStyle(
                      fontSize: 18,
                    ),),
                    SizedBox(
                      width: 300,
                      child: CustomDropdownFormMenu(
                        value: estadoSeleccionado,
                        hint: 'Seleccione un estado',
                        items: estados.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.descripcion)
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          estadoSeleccionado = newValue;
                        },
                      )
                    ),
                  ],
                ),
                const Divider(height: 50,),
                Column(
                  children: [
                    const Text('Tecnico: ', style: TextStyle(
                      fontSize: 18,
                    ),),
                    SizedBox(
                      width: 300,
                      child: DropdownSearch(
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          baseStyle: TextStyle(color: Colors.white),
                          dropdownSearchDecoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un tecnico',
                            hintStyle: TextStyle(color: Colors.black)
                          )
                        ),
                        items: tecnicos,
                        selectedItem: selectedTecnico,
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
                const Divider(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      onPressed: () async {
                        String query = _nombreController.text;
                          await buscar(
                            query,
                            _codController.text,
                            estadoSeleccionado?.codEstado,
                            tecnicoFiltro.toString(),
                            token
                          );
                        },
                      text:'Buscar',
                    ),
                    CustomButton(
                      onPressed: () {
                        Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('');
                        router.push('/editClientes');
                      },
                      text: 'Crear Cliente',
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(searchResults[index].nombre),
                    subtitle: Text('Codigo: ${searchResults[index].codCliente} \nTelefono: ${searchResults[index].telefono1}'),
                    onTap: () {
                      Provider.of<OrdenProvider>(context, listen: false).setCliente(searchResults[index], '');
                      router.push('/editClientes');
                    },
                  ),
                );
              },
            ),
          ),
        ]
      )
    );
  }

  Future<void> buscar(String nombre, String codigo, String? estado, String tecnicoId, String token) async {
    List<Cliente> results = await _clientServices.getClientes(context, nombre, codigo, estado, tecnicoId, token);
    setState(() {
      searchResults = results;
    });
    router.pop();
  }
}