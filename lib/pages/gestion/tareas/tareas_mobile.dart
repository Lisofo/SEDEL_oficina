// ignore_for_file: avoid_print



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tareas_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class TareasMobile extends StatefulWidget {
  const TareasMobile({super.key});

  @override
  State<TareasMobile> createState() => _TareasMobileState();
}

class _TareasMobileState extends State<TareasMobile> {
  List<Tarea> tareas = [];
  final _tareaServices = TareasServices();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codTareaController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Tareas',
        ),
        drawer:  Drawer(
          width: MediaQuery.of(context).size.width *0.9,
          child: Column(
              children: [
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Descripción: '),
                    const SizedBox(width: 1,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width *0.6,
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
                const Spacer(),
                BottomNavigationBar(
                   currentIndex: buttonIndex,
                   onTap: (index) async {
                     buttonIndex = index;
                     switch (buttonIndex){
                       case 0:
                        Provider.of<OrdenProvider>(context, listen: false).clearSelectedTarea();
                        router.push('/editTareas');
                       break;
                       case 1:
                         await buscar(context, token);
                       break;
                     }
                   },
                   showUnselectedLabels: true,
                   selectedItemColor: colors.primary,
                   unselectedItemColor: colors.primary,
                   items: const [
                     BottomNavigationBarItem(
                       icon: Icon(Icons.add_box_outlined),
                       label: 'Agregar Tarea',
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
                  itemCount: tareas.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            tareas[index].codTarea,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tareas[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setTarea(tareas[index]);
                          router.push('/editTareas');
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
    print(_descripcionController.text);
    print(_codTareaController.text);
    List<Tarea> results = await _tareaServices.getTareas(context, _descripcionController.text, _codTareaController.text, token);
    setState(() {
      tareas = results;
    });
  }
}
