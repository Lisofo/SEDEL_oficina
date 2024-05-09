import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/control.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/control_services.dart';

import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';

import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class EditControlesMobile extends StatefulWidget {
  const EditControlesMobile({super.key});

  @override
  State<EditControlesMobile> createState() => _EditControlesMobileState();
}

class _EditControlesMobileState extends State<EditControlesMobile> {
  late Control controlSeleccionado = Control.empty();
  late String token = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _grupoController = TextEditingController();
  final TextEditingController _preguntaController = TextEditingController();
  int buttonIndex = 0;

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
    final colors = Theme.of(context).colorScheme;
    _grupoController.text = controlSeleccionado.grupo;
    _preguntaController.text = controlSeleccionado.pregunta;

    return Scaffold(
      appBar: AppBarMobile(
        titulo: 'Controles',
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Grupo"),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: CustomTextFormField(
                      maxLines: 1,
                      label: 'Grupo',
                      controller: _grupoController,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Control    "),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: CustomTextFormField(
                      label: 'Control',
                      controller: _preguntaController,
                      maxLength: 500,
                      maxLines: 5,
                    ),
                  )
                ],
              ),
              const Spacer(),
              if (controlSeleccionado.controlId != 0) ...[
                BottomNavigationBar(
                  currentIndex: buttonIndex,
                  onTap: (index) async {
                    buttonIndex = index;
                    switch (buttonIndex) {
                      case 0:
                        await postPut(context);

                        break;
                      case 1:
                        await borrarControl(controlSeleccionado);
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
                      label: 'Eliminar',
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: colors.primary)),
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: InkWell(
                    onTap: () async {
                      await postPut(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save,
                          color: colors.primary,
                        ),
                        Text(
                          'Guardar',
                          style: TextStyle(color: colors.primary),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  borrarControl(Control control) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Borrar control'),
            content: SizedBox(
                width: 300,
                child: Text(
                    'Esta por borrar el control ${control.pregunta} \n\nEsta seguro de querer borrarlo?')),
            actions: [
              TextButton(
                  onPressed: () {
                    router.pop();
                  },
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () async {
                    await ControlServices()
                        .deleteControl(context, control, token);
                  },
                  child: const Text('Confirmar')),
            ],
          );
        });
  }

  Future<void> postPut(BuildContext context) async {
    controlSeleccionado.pregunta = _preguntaController.text;
    controlSeleccionado.grupo = _grupoController.text;

    if (controlSeleccionado.controlId == 0) {
      await ControlServices().postControl(context, controlSeleccionado, token);
    } else {
      await ControlServices().putControl(context, controlSeleccionado, token);
    }
    setState(() {});
  }
}
