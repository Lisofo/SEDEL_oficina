// ignore_for_file: avoid_init_to_null

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/estado_cliente.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

import '../../../../models/cliente.dart';
import '../../../../provider/orden_provider.dart';
import '../../../../services/client_services.dart';

class ClientesDesktop extends StatefulWidget {
  const ClientesDesktop({super.key});

  @override
  State<ClientesDesktop> createState() => _ClientesDesktopState();
}

class _ClientesDesktopState extends State<ClientesDesktop> {
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
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Clientes',
      ),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Codigo: '),
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
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text('Nombre: '),
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
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Estado  '),
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
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text('Tecnico: '),
                      SizedBox(
                        width: 300,
                        child: DropdownSearch(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                            hintText: 'Seleccione un tecnico')
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
                  const SizedBox(height: 20,),
                  Center(
                    child: CustomButton(
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
                    )
                  ),
                  const Spacer(),
                  Center(
                    child: CustomButton(
                      onPressed: () {
                        Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('');
                        router.push('/editClientes');
                      },
                      text: 'Crear Cliente',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: [Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
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
            ),
            ]
          )
        ],
      )
    );
  }

  Future<void> buscar(String nombre, String codigo, String? estado, String tecnicoId, String token) async {
    List<Cliente> results = await _clientServices.getClientes(context, nombre, codigo, estado, tecnicoId, token);
    setState(() {
      searchResults = results;
    });
  }
}
