import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/services/client_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/add_client_services_dialog.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class ServicioClienteDesktop extends StatefulWidget {
  final Cliente cliente;
  final String token;
  final ServicioCliente? servicio;
  
  const ServicioClienteDesktop({super.key, required this.cliente, required this.token, this.servicio});

  @override
  State<ServicioClienteDesktop> createState() => _ServicioClienteDesktopState();
}

class _ServicioClienteDesktopState extends State<ServicioClienteDesktop> {
  List<ServicioCliente> serviciosCliente = [];
  late List<Servicio> servicios = [];


  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    final loadedServiciosCliente = await ClientServices().getClienteServices(context, widget.cliente.clienteId.toString(), widget.token);
    servicios =  await ServiciosServices().getServicios(context, '', '', '', widget.token);
    setState(() {
      serviciosCliente = loadedServiciosCliente ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Servicio clientes'),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Expanded(
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
                    const SizedBox(width: 5,),
                    IconButton(
                      onPressed: () {
                        popUpBorrar(context, widget.cliente, servicio, widget.token, i);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddClientServicesDialog(
                              servicioClienteSeleccionado: serviciosCliente[i],
                              cliente: widget.cliente,
                              token: widget.token
                            );
                          },
                        );
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
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'Agregar servicio', 
                  tamano: 20,
                  onPressed: () async{
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddClientServicesDialog(servicioClienteSeleccionado: null, cliente: widget.cliente, token: widget.token);
                      },
                    );
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void popUpBorrar(BuildContext context, Cliente cliente, ServicioCliente servicio, String token, int i) {
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
                    context.pop();
                  },
                  child: const Text('Cancelar')
                ),
                TextButton(
                  onPressed: () async {
                    router.pop();
                    await ClientServices().deleteClienteServices(
                      context,
                      cliente.clienteId.toString(),
                      servicio.clienteServicioId.toString(),
                      token
                    );
                    serviciosCliente.removeAt(i);
                    setState(() {}); 
                  },
                  child: const Text(
                    'Borrar',
                    style: TextStyle(color: Colors.red),
                  )
                ),
              ],
            )
          ],
        );
      },
    );
  }

}