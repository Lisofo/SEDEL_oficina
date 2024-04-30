// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/estado_cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/models/usuarios_x_clientes.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/client_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/add_client_services_dialog.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class EditClientesMobile extends StatefulWidget {
  const EditClientesMobile({super.key});

  @override
  State<EditClientesMobile> createState() => _EditClientesMobileState();
}

class _EditClientesMobileState extends State<EditClientesMobile> {
  List<Map<ServicioCliente, dynamic>> serviciosSeleccionados = [];
  ServicioCliente? servicioSeleccionado;
  List<UsuariosXCliente> usuariosXClientes = [];
  List<ServicioCliente> serviciosCliente = [];
  var dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  late List<Servicio> servicios = [];

  final _codController = TextEditingController();
  final _nombreController = TextEditingController();
  final _nombFantasiaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _barrioController = TextEditingController();
  final _localidadController = TextEditingController();
  final _coordenadasController = TextEditingController();
  final _tel1Controller = TextEditingController();
  final _tel2Controller = TextEditingController();
  final _rucController = TextEditingController();
  final _emailController = TextEditingController();
  final _notasClienteController = TextEditingController();
  late Cliente cliente = Cliente.empty();
  late List<Tecnico> tecnicos = [];
  late Tecnico selectedTecnico;
  late List<Departamento> departamentos = [];
  late Departamento selectedDepartamento;
  late final PageController _pageController = PageController(initialPage: 0);
  int _pageIndex = 0;
  int buttonIndex = 0;
  bool tieneId = false;

  late List<EstadoCliente> estados = [
    EstadoCliente(codEstado: 'A', descripcion: 'Activo'),
    EstadoCliente(codEstado: 'S', descripcion: 'Suspendido'),
    EstadoCliente(codEstado: 'D', descripcion: 'Deshabilitado'),
  ];
  late EstadoCliente estadoSeleccionado;

  late List<TipoCliente> tipoClientes = [
    TipoCliente(tipoClienteId: 1, codTipoCliente: '1', descripcion: 'ABONADO'),
    TipoCliente(tipoClienteId: 2, codTipoCliente: '2', descripcion: 'EVENTUAL'),
    TipoCliente(tipoClienteId: 3, codTipoCliente: '3', descripcion: 'PROSPECT'),
  ];
  late TipoCliente tipoClienteSeleccionado;
  late String token = '';

  @override
  void initState() {
    super.initState();
    loadDatos();
  }

  @override
  void dispose() {
    super.dispose();
    _codController.dispose();
    _nombreController.dispose();
    _nombFantasiaController.dispose();
    _direccionController.dispose();
    _barrioController.dispose();
    _localidadController.dispose();
    _coordenadasController.dispose();
    _tel1Controller.dispose();
    _tel2Controller.dispose();
    _rucController.dispose();
    _emailController.dispose();
    _notasClienteController.dispose();
  }

  Future<void> loadDatos() async {
    token = context.read<OrdenProvider>().token;
    cliente = context.read<OrdenProvider>().cliente;
    if(cliente.clienteId != 0){
      tieneId = true;
    }
    final List<Tecnico> loadedTecnicos = await TecnicoServices().getAllTecnicos(context,token);
    final List<Departamento> loadedDepartamentos = await ClientServices().getClientesDepartamentos(context,token);
    servicios =  await ServiciosServices().getServicios(context, '', '', '', token);
    if (cliente.clienteId != 0) {
      final loadedUsuarios = await ClientServices().getUsuariosXCliente(context, cliente.clienteId.toString(), token);
      final loadedServiciosCliente = await ClientServices().getClienteServices(context, cliente.clienteId.toString(), token);
      setState(() {
        usuariosXClientes = loadedUsuarios ?? [];
        serviciosCliente = loadedServiciosCliente ?? [];
        tecnicos = loadedTecnicos;
        departamentos = loadedDepartamentos;
      });
    } else {
      setState(() {
        usuariosXClientes = [];
        serviciosCliente = [];
        tecnicos = loadedTecnicos;
        departamentos = loadedDepartamentos;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    cargarValoresDeCampo(cliente);
    final colors = Theme.of(context).colorScheme;
    late Departamento? departamentoIncialSeleccionado = departamentos.isNotEmpty ? departamentos[0] : null;
    late TipoCliente? tipoInicialSeleccionado = tipoClientes[0];
    late Tecnico? tecnicoIncialSeleccionado = tecnicos.isNotEmpty ? tecnicos[0] : null;
    late EstadoCliente? estadoInicialSeleccionado = estados[0];

    if (cliente.clienteId > 0) {
      if (selectedTecnico.tecnicoId != 0 && tecnicos.isNotEmpty) {
        tecnicoIncialSeleccionado = tecnicos.firstWhere((tec) => tec.tecnicoId == selectedTecnico.tecnicoId);
      }
      if (selectedDepartamento.departamentoId != 0 && departamentos.isNotEmpty) {
        departamentoIncialSeleccionado = departamentos.firstWhere(
          (departamento) => departamento.departamentoId == selectedDepartamento.departamentoId);
      }
      if (tipoClienteSeleccionado.tipoClienteId != 0) {
        tipoInicialSeleccionado = tipoClientes.firstWhere((tipo) =>
          tipo.tipoClienteId == tipoClienteSeleccionado.tipoClienteId);
      }
      if (estadoSeleccionado.codEstado != '') {
        estadoInicialSeleccionado = estados.firstWhere(
          (estado) => estado.codEstado == estadoSeleccionado.codEstado);
      }
    } else {
      tecnicoIncialSeleccionado = null;
      departamentoIncialSeleccionado = null;
      tipoInicialSeleccionado = null;
      estadoInicialSeleccionado = null;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBarMobile(titulo: 'Clientes'),
        //ToDo poner drawer
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
          scrollDirection: Axis.horizontal,
          children: [
            _datosCliente(
              departamentoIncialSeleccionado, 
              tipoInicialSeleccionado, 
              tecnicoIncialSeleccionado, 
              estadoInicialSeleccionado
            ),
            
            _serviciosCliente(servicios),
            _usuariosCliente(usuariosXClientes),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: buttonIndex,
          onTap: (index) async {
            buttonIndex = index;
            switch (buttonIndex){
              case 0: 
                establecerValoresDeCampo(cliente, estadoSeleccionado);
                
              if (cliente.clienteId != 0) {
                await ClientServices().putCliente(context, cliente, token);
              } else {
                await ClientServices().postCliente(context, cliente, token);
                setState(() {});
              }
              break;
              case 1:
                if(tieneId){
                  router.push('/ptosInspeccionCliente');
                }
              break;
              case 2:
                await borrarClientDialog(context, cliente, token);
              break;
            }
          },
          showUnselectedLabels: true,
          selectedItemColor: colors.primary,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.save_as),
              label: 'Guardar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Puntos de inspeccion',
            ),
            if(tieneId)...[
              const BottomNavigationBarItem(
                icon: Icon(Icons.delete),
                label: 'Eliminar',
              ),
            ]
          ],
        ),
      )
    );
  }

  Widget _datosCliente(Departamento? departamento, TipoCliente? tipoInicial, Tecnico? tecnicoInicial, EstadoCliente? estadoInicial) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(5)),
                  height: 30,
                  child: const Center(
                    child: Text(
                      'Datos del cliente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Codigo '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: CustomTextFormField(
                      controller: _codController,
                      label: 'Codigo',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nombre '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _nombreController,
                      label: 'Nombre',
                      maxLines: 1,
                    )
                  ),
                ],
              ),
              SizedBox(
                height: 20,
                child: TextButton(
                  onPressed: () {
                    MapsLauncher.launchQuery(_nombreController.text);
                  },
                  child: const Text('Buscar por nombre'),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nombre Fantasia  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: CustomTextFormField(
                      controller: _nombFantasiaController,
                      label: 'Nombre Fantasia',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Email  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Direccion  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _direccionController,
                      label: 'Direccion',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              SizedBox(
                height: 20,
                child: TextButton(
                  onPressed: () {
                    MapsLauncher.launchQuery('${_direccionController.text}, ${_localidadController.text}');
                  },
                  child: const Text('Buscar por direccion'),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Coordenadas  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _coordenadasController,
                      hint: 'Latitud, longitud',
                      maxLines: 1,
                      label: 'Coordenadas'
                    )
                  )
                ],
              ),
              SizedBox(
                height: 20,
                child: TextButton(
                  onPressed: () {
                    buscarPorCoordenadas(_coordenadasController.text);
                  },
                  child: const Text('Buscar por coordenadas'),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Barrio  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _barrioController,
                      label: 'Barrio',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Localidad  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _localidadController,
                      label: 'Localidad',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Departamento  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: CustomDropdownFormMenu(
                      value: departamento,
                      hint: 'Seleccione departamento',
                      items: departamentos.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedDepartamento = value;
                        cliente.departamentoId = (value as Departamento).departamentoId;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Telefono1  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _tel1Controller,
                      label: 'Telefono1',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Telefono2  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _tel2Controller,
                      label: 'Telefono2',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('RUC  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomTextFormField(
                      controller: _rucController,
                      label: 'RUC',
                      maxLines: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Estado  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomDropdownFormMenu(
                      value: estadoInicial,
                      hint: 'Seleccione un estado',
                      items: estados.map((e) {
                        return DropdownMenuItem(
                          value: e, child: Text(e.descripcion)
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        estadoSeleccionado = newValue;
                        cliente.estado = (newValue as EstadoCliente).codEstado;
                      },
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tipo de cliente '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomDropdownFormMenu(
                      value: tipoInicial,
                      hint: 'Seleccione tipo de cliente',
                      onChanged: (newValue) {
                        tipoClienteSeleccionado = newValue;
                        cliente.tipoClienteId = (newValue as TipoCliente).tipoClienteId;
                      },
                      items: tipoClientes.map((e) {
                        return DropdownMenuItem(
                          value: e, child: Text(e.descripcion)
                        );
                      }).toList()
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Tecnico  '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CustomDropdownFormMenu(
                      value: tecnicoInicial,
                      hint: 'Seleccione tecnico',
                      items: tecnicos.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedTecnico = value;
                        cliente.tecnicoId =
                            (value as Tecnico).tecnicoId;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: CustomTextFormField(
                  minLines: 2,
                  maxLines: 12,
                  label: 'Notas del cliente',
                  controller: _notasClienteController,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviciosCliente(List<Servicio> servicios){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Servicios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              popUpServicios(
                context,
                cliente.clienteId.toString(),
                cliente,
                servicios,
                token
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: serviciosCliente.length,
              itemBuilder: (context, i) {
                final servicio = serviciosCliente[i];
                return ListTile(
                  title: Text(servicio.servicio),
                  subtitle: Text(servicio.comentario),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(DateFormat('E, d , MMM, yyyy', 'es').format(servicio.desde!)),
                          Text(servicio.hasta == null ? '' : DateFormat('E, d , MMM, yyyy', 'es').format(servicio.hasta!)),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        onPressed: () {
                          popUpBorrar(context, cliente, servicio, token, i);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 5,),
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddClientServicesDialog(
                                servicioClienteSeleccionado: serviciosCliente[i],
                                cliente: cliente,
                                token: token
                              );
                            },
                          );
                          loadDatos();
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _usuariosCliente(List<UsuariosXCliente> usuarios) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
       Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(5)),
            height: 30,
            child: const Center(
              child: Text(
                'Usuarios asociados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20,),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primary,
                  child: Text(
                    usuarios[index].usuarioId.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(usuarios[index].usuario),
                subtitle: Text(
                  usuarios[index].login,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void popUpBorrar(BuildContext context, Cliente cliente,
      ServicioCliente servicio, String token, int i) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Desea borrar el servicio?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      router.pop();
                    },
                    child: const Text('Cancelar')),
                TextButton(
                    onPressed: () async {
                      router.pop();
                      await ClientServices().deleteClienteServices(
                          context,
                          cliente.clienteId.toString(),
                          servicio.clienteServicioId.toString(),
                          token);
                      serviciosCliente.removeAt(i);
                      setState(() {});
                    },
                    child: const Text(
                      'Borrar',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            )
          ],
        );
      },
    );
  }

  void establecerValoresDeCampo(Cliente cliente, selectedValue) {
    cliente.barrio = _barrioController.text;
    cliente.codCliente = _codController.text;
    cliente.coordenadas = _coordenadasController.text;
    cliente.direccion = _direccionController.text;
    cliente.email = _emailController.text;
    cliente.estado = estadoSeleccionado.codEstado;
    cliente.localidad = _localidadController.text;
    cliente.nombre = _nombreController.text;
    cliente.nombreFantasia = _nombFantasiaController.text;
    cliente.ruc = _rucController.text;
    cliente.telefono1 = _tel1Controller.text;
    cliente.telefono2 = _tel2Controller.text;
    cliente.departamento = selectedDepartamento;
    cliente.tipoCliente = tipoClienteSeleccionado;
    cliente.tecnico = selectedTecnico;
    cliente.notas = _notasClienteController.text;
  }

  void cargarValoresDeCampo(Cliente cliente) {
    _codController.text = cliente.codCliente;
    _nombreController.text = cliente.nombre;
    _nombFantasiaController.text = cliente.nombreFantasia;
    _direccionController.text = cliente.direccion;
    _coordenadasController.text = cliente.coordenadas;
    _barrioController.text = cliente.barrio;
    _localidadController.text = cliente.localidad;
    _tel1Controller.text = cliente.telefono1;
    _tel2Controller.text = cliente.telefono2;
    _rucController.text = cliente.ruc;
    _emailController.text = cliente.email;
    selectedDepartamento = cliente.departamento;
    tipoClienteSeleccionado = cliente.tipoCliente;
    selectedTecnico = cliente.tecnico;
    estadoSeleccionado = cliente.estado != ''
        ? estados.firstWhere((estado) => estado.codEstado == cliente.estado)
        : EstadoCliente(codEstado: '', descripcion: '');
    if (cliente.clienteId > 0) {
      cliente.tecnicoId = cliente.tecnico.tecnicoId;
      cliente.departamentoId = cliente.departamento.departamentoId;
      cliente.tipoClienteId = cliente.tipoCliente.tipoClienteId;
    }
    _notasClienteController.text = cliente.notas;
  }

  void buscarPorCoordenadas(String coordenadas) {
    var coord = coordenadas.split(',');
    MapsLauncher.launchCoordinates(double.parse(coord[0]), double.parse(coord[1]));
  }

  Widget popUpServicios(BuildContext context, String clienteId, Cliente cliente, List servicios, String token) {
    return InkWell(
      onTap: () async {
        if (clienteId != '0') {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddClientServicesDialog(
                servicioClienteSeleccionado: null,
                cliente: cliente,
                token: token
              );
            },
          );
          loadDatos();
        }
      },
      child: const Icon(Icons.add),
    );
  }

  Future<dynamic> borrarClientDialog(BuildContext context, Cliente clienteSeleccionado, String token) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar accion'),
          content: const Text('Desea borrar el cliente?'),
          actions: [
            TextButton(
              onPressed: () async {
                ClientServices().deleteCliente(context, clienteSeleccionado, token);
              },
              child: const Text('Borrar')),
            TextButton(
              onPressed: () {
                router.pop();
              },
              child: const Text('Cancelar')
            )
          ],
        );
      },
    );
  }
}