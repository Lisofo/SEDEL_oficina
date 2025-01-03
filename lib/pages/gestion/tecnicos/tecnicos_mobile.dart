import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:intl/intl.dart';

class TecnicosPageMobile extends StatefulWidget {
  const TecnicosPageMobile({super.key});

  @override
  State<TecnicosPageMobile> createState() => _TecnicosPageMobileState();
}

class _TecnicosPageMobileState extends State<TecnicosPageMobile> {
  List<Tecnico> tecnicos = [];
  final _tecnicoServices = TecnicoServices();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _codTecnicoController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Técnicos',
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width *0.9,
          child: Column(
                children: [
                  const SizedBox(height: 10,),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     const Text('Documento: '),
                  //     SizedBox(
                  //       width: MediaQuery.of(context).size.width *0.8,
                  //       child: CustomTextFormField(
                  //         controller: _documentoController,
                  //         maxLines: 1,
                  //         label: 'Documento',
                  //         onFieldSubmitted: (value) async {
                  //           await buscarTecnico(token);
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 5,),
                  // Divider(
                  //   thickness: 0.5,
                  //   color: colors.primary,
                  //   endIndent: 20,
                  //   indent: 20,
                  // ),
                  // const SizedBox(height: 5,),
    
                  // Divider(
                  //   thickness: 0.5,
                  //   color: colors.primary,
                  //   endIndent: 20,
                  //   indent: 20,
                  // ),
                  // const SizedBox(height: 5,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Nombre: '),
                      
                      SizedBox(
                        width: MediaQuery.of(context).size.width *0.8,
                        child: CustomTextFormField(
                          maxLines: 1,
                          label: 'Nombre',
                          controller: _nombreController,
                          onFieldSubmitted: (value) async {
                            await buscarTecnico(token);
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
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedTecnico();
                          router.push('/editTecnicos');
                        break;
                        case 1:
                          await buscarTecnico(token);
                        break;
                      }
                    },
                    showUnselectedLabels: true,
                    selectedItemColor: colors.primary,
                    unselectedItemColor: colors.primary,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box_outlined),
                        label: 'Agregar Técnico',
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
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: tecnicos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Provider.of<OrdenProvider>(context, listen: false).setTecnico(tecnicos[index]);
                        router.push('/editTecnicos');
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(tecnicos[index].codTecnico, style: const TextStyle(color: Colors.white),),
                                    )
                                  ),
                                  const SizedBox(width: 10,),
                                  Text(tecnicos[index].nombre),
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Text('Documento: ${tecnicos[index].documento}'),
                              const SizedBox(height: 5,),
                              Text('Fecha vencimiento del carne de salud: ${DateFormat("E d, MMM, yyyy", 'es').format(tecnicos[index].fechaVtoCarneSalud as DateTime)}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  Future<void> buscarTecnico(String token) async {
    List<Tecnico> results = await _tecnicoServices.getTecnicos(
      context, 
      _documentoController.text,
      _codTecnicoController.text,
      _nombreController.text,
      token);
    setState(() {
      tecnicos = results;
    });
  }
}
