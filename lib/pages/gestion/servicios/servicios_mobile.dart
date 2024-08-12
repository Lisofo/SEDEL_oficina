import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';

import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class ServiciosMobile extends StatefulWidget {
  const ServiciosMobile({super.key});

  @override
  State<ServiciosMobile> createState() => _ServiciosMobileState();
}

class _ServiciosMobileState extends State<ServiciosMobile> {
  List<Servicio> servicios = [];
  final _servicioServices = ServiciosServices();
  final _descripcionController = TextEditingController();
  final _codServicioController = TextEditingController();
  final _tipoServicioController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Servicios',
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Descripción: '),
                  const SizedBox(
                    width: 1,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
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
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     const Text('Tipo: '),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width * 0.6,
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
              const Spacer(),
              BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex) {
                    case 0:
                      Provider.of<OrdenProvider>(context, listen: false)
                          .clearSelectedServicio();
                      router.push('/editServicios');
                      break;
                    case 1:
                      await buscar(context, token);
                      router.pop();
                      break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.primary,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    label: 'Agregar Control',
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
        body: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: servicios.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(servicios[index].codServicio.toString(), style: const TextStyle(color: Colors.white),),
                          )
                        ),
                        title: Text(servicios[index].descripcion),
                        subtitle:
                            Text(servicios[index].tipoServicio.descripcion),
                        trailing: Text(servicios[index].codServicio),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setServicio(servicios[index]);
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
