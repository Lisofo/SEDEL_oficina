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
          titulo: 'Tecnicos',
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width *0.9,
          child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Documento: '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width *0.6,
                        child: CustomTextFormField(
                          controller: _documentoController,
                          maxLines: 1,
                          label: 'Documento',
                          onFieldSubmitted: (value) async {
                            await buscarTecnico(token);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Divider(color: colors.primary,),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Codigo: '),
                      
                      SizedBox(
                        width: MediaQuery.of(context).size.width *0.6,
                        child: CustomTextFormField(
                          controller: _codTecnicoController,
                          maxLines: 1,
                          label: 'Codigo',
                          onFieldSubmitted: (value) async {
                            await buscarTecnico(token);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Divider(color: colors.primary,),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Nombre: '),
                      
                      SizedBox(
                        width: MediaQuery.of(context).size.width *0.6,
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
                  const SizedBox(height: 10,),
                  Divider(color: colors.primary,),
                  const SizedBox(height: 10,),
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
                    unselectedItemColor: Colors.grey,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box_outlined),
                        label: 'Agregar Tecnico',
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
                  itemCount: tecnicos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                             colors.primary,
                          child: Text(
                            tecnicos[index].codTecnico,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tecnicos[index].nombre),
                        subtitle:
                            Text('Documento: ${tecnicos[index].documento}'),
                        trailing: Text(
                            'Fecha vencimiento del carne de salud: ${DateFormat("E d, MMM, yyyy", 'es').format(tecnicos[index].fechaVtoCarneSalud as DateTime)}'),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setTecnico(tecnicos[index]);
                          router.push('/editTecnicos');
                        },
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
