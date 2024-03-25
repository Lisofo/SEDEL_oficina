// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/estado_cliente.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/clientes/edit_clientes.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

import '../../../models/cliente.dart';
import '../../../provider/orden_provider.dart';
import '../../../services/client_services.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
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

  @override
  void initState() {
    super.initState();
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
    estados.insert(0, EstadoCliente(codEstado: '', descripcion: 'Todos'));
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<OrdenProvider>().token;

    return Scaffold(
        appBar: AppBarDesign(
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
                                  token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                                  token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                                    value: e, child: Text(e.descripcion));
                              }).toList(),
                              onChanged: (newValue) {
                                estadoSeleccionado = newValue;
                              },
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text('Tecnico: '),
                        SizedBox(
                          width: 300,
                          child: CustomDropdownFormMenu(
                            hint: 'Tecnico',
                            value: selectedTecnico,
                            onChanged: (value) async {
                              setState(() {
                                selectedTecnico = value;
                                tecnicoFiltro = value!.tecnicoId;
                              });
                            },
                            items: tecnicos.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e.nombre),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () async {
                            String query = _nombreController.text;
                            await buscar(
                                query,
                                _codController.text,
                                estadoSeleccionado?.codEstado,
                                tecnicoFiltro.toString(),
                                token);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 52, 120, 62),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () {
                            Provider.of<OrdenProvider>(context, listen: false)
                                .clearSelectedCliente('');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditClientesPages(),
                                ));
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Crear Cliente',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 52, 120, 62),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(searchResults[index].nombre),
                        subtitle: Text(
                            'Codigo: ${searchResults[index].codCliente} \nTelefono: ${searchResults[index].telefono1}'),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setCliente(searchResults[index], '');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditClientesPages(),
                              ));
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }

  Future<void> buscar(String nombre, String codigo, String? estado,
      String tecnicoId, String token) async {
    List<Cliente> results = await _clientServices.getClientes(context, nombre, codigo, estado, tecnicoId, token);
    setState(() {
      searchResults = results;
    });
  }
}
