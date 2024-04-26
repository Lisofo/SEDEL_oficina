// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/cliente_usuario.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/search/client_delegate.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';

import '../../../../widgets/appbar_desktop.dart';
import '../../../../widgets/drawer.dart';

class EstablecerClientesDesktop extends StatefulWidget {
  const EstablecerClientesDesktop({super.key});

  @override
  State<EstablecerClientesDesktop> createState() => _EstablecerClientesDesktopState();
}

class _EstablecerClientesDesktopState extends State<EstablecerClientesDesktop> {
  final _userServices = UserServices();
  List<ClienteUsuario> clientes = [];
  late Usuario userSeleccionado;
  late String token;
  List<Cliente> historial = [];
  late Cliente selectedCliente;
  @override
  void initState() {
    super.initState();
    userSeleccionado = context.read<OrdenProvider>().usuario;
    selectedCliente = Cliente.empty();
    token = context.read<OrdenProvider>().token;
    getClientes(userSeleccionado, token);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Usuarios',
      ),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              SizedBox(
                  height: 400,
                  child: ListView.separated(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final _clientes = clientes;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 300),
                        child: ListTile(
                          title: Text(
                            _clientes[index].cliente,
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            _clientes[index].codCliente,
                            textAlign: TextAlign.center,
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Confirmar accion'),
                                      content: Text(
                                          'Desea borrar ${_clientes[index].cliente}?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await _userServices
                                                  .deleteClientUsers(
                                                      context,
                                                      userSeleccionado.usuarioId
                                                          .toString(),
                                                      _clientes[index]
                                                          .clienteId
                                                          .toString(),
                                                      token);
                                              await getClientes(
                                                  userSeleccionado, token);
                                            },
                                            child: const Text('Borrar')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancelar'))
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete)),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 300),
                        child: Divider(
                          thickness: 3,
                          color: Colors.green,
                        ),
                      );
                    },
                  )),
            ]),
          ))),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      elevation: MaterialStatePropertyAll(10),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50))))),
                  onPressed: () async {
                    final cliente = await showSearch(
                        context: context,
                        delegate: ClientSearchDelegate(
                            'Buscar Cliente', historial, ''));
                    if (cliente != null) {
                      setState(() {
                        selectedCliente = cliente;
                        final int clienteExiste = historial.indexWhere(
                            (element) => element.nombre == cliente.nombre);
                        if (clienteExiste == -1) {
                          historial.insert(0, cliente);
                        }
                      });
                    } else {
                      setState(() {
                        selectedCliente = Cliente.empty();
                      });
                    }
                    if (selectedCliente.clienteId != 0) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirmacion'),
                            content: Text(
                                'Desea agregar al cliente ${selectedCliente.nombre}?'),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await _userServices.postClientUsers(
                                        context,
                                        userSeleccionado.usuarioId.toString(),
                                        selectedCliente.clienteId.toString(),
                                        token);
                                    await getClientes(userSeleccionado, token);
                                  },
                                  child: const Text('Agregar')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar')),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(
                      'Agregar cliente',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ClienteUsuario>> getClientes(Usuario user, String token) async {
    clientes =
        await _userServices.getClientUsers(context, user.usuarioId.toString(), token);
    setState(() {});
    return clientes;
  }
}
