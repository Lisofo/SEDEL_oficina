// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plagas_objetivo_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import '../../../widgets/drawer.dart';

class EditPlagasObjetivoPage extends StatefulWidget {
  const EditPlagasObjetivoPage({super.key});

  @override
  State<EditPlagasObjetivoPage> createState() => _EditPlagasObjetivoPageState();
}

class _EditPlagasObjetivoPageState extends State<EditPlagasObjetivoPage> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late PlagaObjetivo plagaSeleccionada = PlagaObjetivo.empty();
  late String token = '';


  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos(){
    plagaSeleccionada = context.read<OrdenProvider>().plagaObjetivo;
    token = context.watch<OrdenProvider>().token;
  }

  @override
  void dispose() {
    _codController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _codController.text = plagaSeleccionada.codPlagaObjetivo;
    _descripcionController.text = plagaSeleccionada.descripcion;

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Plagas objetivo',),
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
                          if(plagaSeleccionada.plagaObjetivoId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () async {
                                await borrarPlaga(plagaSeleccionada);
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

  borrarPlaga(PlagaObjetivo plaga) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar plaga objetivo'),
          content: Text('Esta por borrar la plaga objetivo ${plaga.descripcion}, esta seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await PlagaObjetivoServices().deletePlagaObjetivo(context, plaga, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    plagaSeleccionada.codPlagaObjetivo = _codController.text;
    plagaSeleccionada.descripcion = _descripcionController.text;
    
    if(plagaSeleccionada.plagaObjetivoId == 0){
      await PlagaObjetivoServices().postPlagaObjetivo(context, plagaSeleccionada, token);
    }else{
      await PlagaObjetivoServices().putPlagaObjetivo(context, plagaSeleccionada, token);
    }
    setState(() {});
  }
}
