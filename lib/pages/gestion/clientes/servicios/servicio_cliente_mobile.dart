import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/client_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/add_client_services_dialog.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

class ServicioClienteMobile extends StatefulWidget {
  final Cliente cliente;
  final String token;
  final ServicioCliente? servicio;

  const ServicioClienteMobile({super.key, required this.cliente, required this.token, this.servicio});

  @override
  State<ServicioClienteMobile> createState() => _ServicioClienteMobileState();
}

class _ServicioClienteMobileState extends State<ServicioClienteMobile> {
  List<ServicioCliente> serviciosCliente = [];
  late List<Servicio> servicios = [];
  late bool cargando = false;
  late bool yaCargo = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    final loadedServiciosCliente = await ClientServices().getClienteServices(context, widget.cliente.clienteId, widget.token);
    servicios =  await ServiciosServices().getServicios(context, '', '', '', widget.token);
    serviciosCliente = loadedServiciosCliente ?? [];
    if(serviciosCliente.isNotEmpty){
      for(var i = 0; i < serviciosCliente.length; i++) {
        serviciosCliente[i].frecuencia = await ServiciosServices().getFrecuencias(context, widget.cliente.clienteId, serviciosCliente[i].clienteServicioId, widget.token);
      }
    }
    setState(() {
      cargando = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarMobile(titulo: 'Servicio clientes'),
        body: !cargando ? const Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('Cargando, por favor espere...')
            ],
          ),
        ) : 
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: serviciosCliente.length,
            itemBuilder: (context, i) {
              final servicio = serviciosCliente[i];
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                child: Text(servicio.descripcion, 
                                  style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Text(servicio.comentario),
                            Text(DateFormat('E, d, MMM, yyyy', 'es').format(servicio.desde!)),
                            Text(servicio.hasta == null ? '' : DateFormat('E, d, MMM, yyyy', 'es').format(servicio.hasta!)),
                            for(var frecuencia in servicio.frecuencia)...[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(frecuencia.frecuencia == 'Cada n meses' ? 'Cada ${frecuencia.meses} meses' : frecuencia.frecuencia, style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                                    const SizedBox(width: 5,),
                                    Text(frecuencia.desde == null ? '' : 'Desde: ${DateFormat('E, d, MMM, yyyy', 'es').format(frecuencia.desde!)}'),
                                    const SizedBox(width: 5,),
                                    Text(frecuencia.hasta == null ? '' : 'Hasta: ${DateFormat('E, d, MMM, yyyy', 'es').format(frecuencia.hasta!)}')
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if(frecuencia.d != false)
                                  const Text('Do, '),
                                  if(frecuencia.l != false)
                                  const Text('Lu, '),
                                  if(frecuencia.ma != false)
                                  const Text('Ma, '),
                                  if(frecuencia.mi != false)
                                  const Text('Mi, '),
                                  if(frecuencia.j != false)
                                  const Text('Ju, '),
                                  if(frecuencia.v != false)
                                  const Text('Vi, '),
                                  if(frecuencia.s != false)
                                  const Text('Sá'),
                                ],
                              )
                            ],
                            const SizedBox(height: 5,),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
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
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      popUpBorrar(context, widget.cliente, servicio, widget.token, i);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      Provider.of<OrdenProvider>(context, listen: false).setServicioCliente(servicio);
                                      router.push('/frecuenciaServicios');
                                    }, 
                                    child: const Text('Frecuencias')
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
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
                    await cargarDatos();
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
                    router.pop();
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