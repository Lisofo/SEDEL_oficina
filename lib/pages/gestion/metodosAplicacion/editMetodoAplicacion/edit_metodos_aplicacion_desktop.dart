import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

import '../../../../config/router/app_router.dart';

class EditMetodosAplicacionDesktop extends StatefulWidget {
  const EditMetodosAplicacionDesktop({super.key});

  @override
  State<EditMetodosAplicacionDesktop> createState() => _EditMetodosAplicacionDesktopState();
}

class _EditMetodosAplicacionDesktopState extends State<EditMetodosAplicacionDesktop> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late MetodoAplicacion metodoSeleccionado = MetodoAplicacion.empty();
  late String token = '';

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    metodoSeleccionado = context.read<OrdenProvider>().metodoAplicacion;
    token = context.read<OrdenProvider>().token;
  }

  @override
  Widget build(BuildContext context) {
    _codController.text = metodoSeleccionado.codMetodoAplicacion;
    _descripcionController.text = metodoSeleccionado.descripcion;


    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Metodos de aplicación'),
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
                          maxLines: 1,
                          label: 'Codigo',
                          controller: _codController,
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
                          maxLines: 1,
                          controller: _descripcionController,
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
                          if(metodoSeleccionado.metodoAplicacionId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () async {
                               await borrarMetodo(metodoSeleccionado);
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

  borrarMetodo(MetodoAplicacion metodo) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar metodo de aplicación'),
          content: Text('Esta por borrar el metodo ${metodo.descripcion}, esta seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MaterialesServices().deleteMetodo(context, metodo, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    metodoSeleccionado.codMetodoAplicacion = _codController.text;
    metodoSeleccionado.descripcion = _descripcionController.text;
    
    if(metodoSeleccionado.metodoAplicacionId == 0){
      await MaterialesServices().postMetodo(context, metodoSeleccionado, token);
    }else{
      await MaterialesServices().putMetodo(context, metodoSeleccionado, token);
    }
    setState(() {});
  }
}