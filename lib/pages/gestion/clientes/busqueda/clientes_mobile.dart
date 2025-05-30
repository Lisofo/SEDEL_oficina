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
  int buttonIndex = 0;

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
          firmaPath: '' ,
          firmaMd5: '' ,
          avatarPath: '' ,
          avatarMd5: '' ,
          cargo: null, verDiaSiguiente: null,
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
        width: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: colors.primary, width: 15)),  
          ),
          child: Column(
            children: [
              Column(
                children: [
                  const Text('Código: '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: CustomTextFormField(
                      controller: _codController,
                      maxLines: 1,
                      hint: 'Buscar código del cliente',
                      onFieldSubmitted: (value) async {
                        String query = value;
                        await buscar(
                          _nombreController.text,
                          query,
                          estadoSeleccionado?.codEstado,
                          tecnicoFiltro.toString(),
                          token
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5,),
              Divider(
                thickness: 0.5,
                color: colors.primary,
                endIndent: 20,
                indent: 20,
              ),
              const SizedBox(height: 5,),
              Column(
                children: [
                  const Text('Nombre: ', style: TextStyle(
                    fontSize: 18,
                  ),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
              const SizedBox(height: 5,),
              Divider(
                thickness: 0.5,
                color: colors.primary,
                endIndent: 20,
                indent: 20,
              ),
              const SizedBox(height: 5,),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Estado:  ', style: TextStyle(
                    fontSize: 18,
                  ),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: CustomDropdownFormMenu(
                      isDense: true,
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
              const SizedBox(height: 5,),
              Divider(
                thickness: 0.5,
                color: colors.primary,
                endIndent: 20,
                indent: 20,
              ),
              const SizedBox(height: 5,),
              Column(
                children: [
                  const Text('Técnico: ', style: TextStyle(
                    fontSize: 18,
                  ),),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: DropdownSearch(
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        textAlignVertical: TextAlignVertical.center,
                        baseStyle: TextStyle(color: Colors.white),
                        dropdownSearchDecoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: 'Seleccione un técnico',
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

              const Spacer(),

              BottomNavigationBar(
              currentIndex: buttonIndex,
              onTap: (index) async {
                buttonIndex = index;
                switch (buttonIndex){
                  case 0: 
                    Provider.of<OrdenProvider>(context, listen: false).clearSelectedCliente('');
                    router.push('/editClientes');
                  break;
                  case 1:
                    String query = _nombreController.text;
                        await buscar(
                          query,
                          _codController.text,
                          estadoSeleccionado?.codEstado,
                          tecnicoFiltro.toString(),
                          token
                        );
                  break;
                }
              },
              showUnselectedLabels: true,
              selectedItemColor: colors.primary,
              unselectedItemColor: colors.primary,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_comment_outlined),
                  label: 'Crear Cliente',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
        
              ],
            ),
              
              
            ],
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