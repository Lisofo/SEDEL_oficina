import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class ServiciosDesktop extends StatefulWidget {
  const ServiciosDesktop({super.key});

  @override
  State<ServiciosDesktop> createState() => _ServiciosDesktopState();
}

class _ServiciosDesktopState extends State<ServiciosDesktop> {
  List<Servicio> servicios = [];
  final _servicioServices = ServiciosServices();
  final _descripcionController = TextEditingController();
  final _codServicioController = TextEditingController();
  final _tipoServicioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Servicios',
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
                        const Text('Descripción: '),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _descripcionController,
                            maxLines: 1,
                            label: 'Descripción',
                            onFieldSubmitted: (value) async {
                              await buscar(context, token);
                            },
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Row(
                    //   children: [
                    //     const Text('Tipo: '),
                    //     const SizedBox(
                    //       width: 44,
                    //     ),
                    //     SizedBox(
                    //       width: 300,
                    //       child: CustomTextFormField(
                    //         maxLines: 1,
                    //         label: 'Tipo',
                    //         controller: _tipoServicioController,
                    //         onFieldSubmitted: (value) async {
                    //           await buscar(context, token);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: CustomButton(
                        onPressed: () async {
                          await buscar(context, token);
                        },
                        text: 'Buscar',
                        tamano: 20,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedServicio();
                          router.push('/editServicios');
                        },
                        text: 'Agregar Servicio',
                        tamano: 20,
                      ),
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
                  itemCount: servicios.length,
                  itemBuilder: (context, i) {
                    return Card(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(servicios[i].codServicio, style: const TextStyle(color: Colors.white),),
                          )
                        ),
                        title: Text(servicios[i].descripcion),
                        subtitle:
                            Text(servicios[i].tipoServicio.descripcion),
                        trailing: Text(servicios[i].codServicio),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setServicio(servicios[i]);
                          router.push('/editServicios');
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> buscar(BuildContext context, String token) async {
    List<Servicio> results = await _servicioServices.getServicios(
        context,
        _descripcionController.text,
        _codServicioController.text,
        _tipoServicioController.text,
        token);
    setState(() {
      servicios = results;
    });
  }
}
