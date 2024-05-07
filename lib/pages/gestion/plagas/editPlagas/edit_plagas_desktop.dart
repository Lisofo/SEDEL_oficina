// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../../services/plaga_services.dart';
import '../../../../widgets/appbar_desktop.dart';
import '../../../../widgets/drawer.dart';

class EditPlagasDesktop extends StatefulWidget {
  const EditPlagasDesktop({super.key});

  @override
  State<EditPlagasDesktop> createState() => _EditPlagasDesktopState();
}

class _EditPlagasDesktopState extends State<EditPlagasDesktop> {
  final _plagaServices = PlagaServices();
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Plaga plagaSeleccionada = Plaga.empty();
  late String token = '';


  @override
  void initState() {
    super.initState();
    plagaSeleccionada =context.read<OrdenProvider>().plaga;
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
    _codController.text = plagaSeleccionada.codPlaga;
    _descripcionController.text = plagaSeleccionada.descripcion;

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Plagas',),
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
                          if(plagaSeleccionada.plagaId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () {
                                borrarPlaga(plagaSeleccionada);
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

  borrarPlaga(Plaga plaga) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar plaga'),
          content: Text('Esta por borrar la plaga ${plaga.descripcion}, esta seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await _plagaServices.deletePlaga(context, plaga, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    plagaSeleccionada.codPlaga = _codController.text;
    plagaSeleccionada.descripcion = _descripcionController.text;
    
    if(plagaSeleccionada.plagaId == 0){
      await _plagaServices.postPlaga(context, plagaSeleccionada, token);
    }else{
      await _plagaServices.putPlaga(context, plagaSeleccionada, token);
    }
    setState(() {});
  }
}
