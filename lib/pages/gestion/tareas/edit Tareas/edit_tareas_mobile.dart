// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tareas_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class EditTareasMobile extends StatefulWidget {
  const EditTareasMobile({super.key});

  @override
  State<EditTareasMobile> createState() => _EditTareasMobileState();
}

class _EditTareasMobileState extends State<EditTareasMobile> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Tarea tareaSeleccionada = Tarea.empty();
  late String token = '';
  int buttonIndex = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos(){
    tareaSeleccionada = context.read<OrdenProvider>().tarea;
    token = context.read<OrdenProvider>().token;
  }

  @override
  void dispose() {
    _codController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    _codController.text = tareaSeleccionada.codTarea;
    _descripcionController.text = tareaSeleccionada.descripcion;

    return Scaffold(
      appBar: AppBarMobile(titulo: 'Tareas',),      
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 20,),
                const Text("Codigo  "),
                const SizedBox(height: 10,),
                const SizedBox(
                  width: 27,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: CustomTextFormField(
                    controller: _codController,
                    maxLines: 1,
                    label: 'Codigo',
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                const Text("Descripcion  "),
                const SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: CustomTextFormField(
                    label: 'Descripcion',
                    controller: _descripcionController,
                    maxLines: 4,
                    maxLength: 100,
                  ),
                )
              ],
            ),
            const Spacer(),
            if(tareaSeleccionada.tareaId != 0)... [
              BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0:
                      await postPut(context);
                    break;
                    case 1:
                      await borrarTarea(tareaSeleccionada);
                    break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.save),
                    label: 'Guardar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.delete),
                    label: 'Borrar',
                  ),
          
                ],
              ),
            ]else ... [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary)
                ),
                height: MediaQuery.of(context).size.height *0.1,
                child: InkWell(
        
                  onTap: () async{
                   await postPut(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: colors.primary,),
                        Text('Guardar', style: TextStyle(color: colors.primary),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  borrarTarea(Tarea tarea) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar tarea'),
          content: Text('Esta por borrar la tarea ${tarea.descripcion}, esta seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await TareasServices().deleteTarea(context, tarea, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    tareaSeleccionada.codTarea = _codController.text;
    tareaSeleccionada.descripcion = _descripcionController.text;
    
    if(tareaSeleccionada.tareaId == 0){
      await TareasServices().postTarea(context, tareaSeleccionada, token);
    }else{
      await TareasServices().putTarea(context, tareaSeleccionada, token);
    }
    setState(() {});
  }
}
