// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tareas_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../../widgets/appbar_desktop.dart';
import '../../../../widgets/drawer.dart';

class EditTareasDesktop extends StatefulWidget {
  const EditTareasDesktop({super.key});

  @override
  State<EditTareasDesktop> createState() => _EditTareasDesktopState();
}

class _EditTareasDesktopState extends State<EditTareasDesktop> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Tarea tareaSeleccionada = Tarea.empty();
  late String token = '';

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
    _codController.text = tareaSeleccionada.codTarea;
    _descripcionController.text = tareaSeleccionada.descripcion;

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Tareas',),      
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Codigo  "),
                      const SizedBox(
                        width: 27,
                      ),
                      SizedBox(
                        width: 300,
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
                  Row(
                    children: [
                      const Text("Descripcion  "),
                      SizedBox(
                        width: 800,
                        child: CustomTextFormField(
                          label: 'Descripcion',
                          controller: _descripcionController,
                          maxLines: 1,
                          maxLength: 100,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  BottomAppBar(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            onPressed: () async {
                              await postPut(context);
                            },
                            text: 'Guardar',
                            tamano: 20,
                          ),
                          if(tareaSeleccionada.tareaId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                            onPressed: () async {
                              borrarTarea(tareaSeleccionada);
                            },
                            text: 'Eliminar',
                            tamano: 20,
                            ),
                          ]   
                        ]
                      )
                    )
                  )
                ],
              ),
            ),
          ),
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
