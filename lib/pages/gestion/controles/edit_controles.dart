import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/control.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class EditControlesPage extends StatefulWidget {
  const EditControlesPage({super.key});

  @override
  State<EditControlesPage> createState() => _EditControlesPageState();
}

class _EditControlesPageState extends State<EditControlesPage> {
  late Control controlSeleccionado = Control.empty();
  late String token = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _grupoController = TextEditingController();
  final TextEditingController _preguntaController = TextEditingController();



  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() {
    controlSeleccionado = context.read<OrdenProvider>().control;
    token = context.read<OrdenProvider>().token;
  }

  @override
  void dispose() {
    _grupoController.dispose();
    _preguntaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _grupoController.text = controlSeleccionado.grupo;
    _preguntaController.text = controlSeleccionado.pregunta;

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Controles',),
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
                      const Text("Grupo"),
                      const SizedBox(width: 23,),
                      SizedBox(
                        width: 390,
                        child: CustomTextFormField(
                          maxLines: 1,
                          label: 'Grupo',
                          controller: _grupoController,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("Control    "),
                      SizedBox(
                        width: 800,
                        child: CustomTextFormField(
                          label: 'Control',
                          controller: _preguntaController,
                          maxLength: 500,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  BottomAppBar(
                    color: Colors.transparent,
                    elevation: 0,
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
                          if(controlSeleccionado.controlId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () async {
                                await borrarControl(controlSeleccionado);
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

  borrarControl(Control control) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar control'),
          content: SizedBox(
            width: 300,
            child: Text('Esta por borrar el control ${control.pregunta} \n\nEsta seguro de querer borrarlo?')),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await ControlServices().deleteControl(context, control, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    controlSeleccionado.pregunta = _preguntaController.text;
    controlSeleccionado.grupo = _grupoController.text;
    
    if(controlSeleccionado.controlId == 0){
      await ControlServices().postControl(context, controlSeleccionado, token);
    }else{
      await ControlServices().putControl(context, controlSeleccionado, token);
    }
    setState(() {});
  }
}