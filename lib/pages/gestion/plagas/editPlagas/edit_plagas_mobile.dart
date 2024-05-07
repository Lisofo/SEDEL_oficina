// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../../services/plaga_services.dart';


class EditPlagasMobile extends StatefulWidget {
  const EditPlagasMobile({super.key});

  @override
  State<EditPlagasMobile> createState() => _EditPlagasMobileState();
}

class _EditPlagasMobileState extends State<EditPlagasMobile> {
  final _plagaServices = PlagaServices();
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Plaga plagaSeleccionada = Plaga.empty();
  late String token = '';
  int buttonIndex = 0;


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
    final colors = Theme.of(context).colorScheme;
    _codController.text = plagaSeleccionada.codPlaga;
    _descripcionController.text = plagaSeleccionada.descripcion;

    return Scaffold(
      appBar: AppBarMobile(titulo: 'Plagas',),
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
                  const Text("Codigo  "),
                  const SizedBox(
                    width: 1,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Descripcion  "),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: CustomTextFormField(
                      label: 'Descripcion',
                      maxLines: 4,
                      controller: _descripcionController,
                      maxLength: 100,
                    ),
                  )
                ],
              ),
              const Spacer(),
              if(plagaSeleccionada.plagaId != 0)...[
                BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0: 
                      await postPut(context);
                    break;
                    case 1:
                      borrarPlaga(plagaSeleccionada);
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
              ] else ... [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary)
                  ),
                  height: MediaQuery.of(context).size.height *0.1,
                  child: InkWell(
                    onTap: () async{
                      await postPut(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: colors.primary,),
                        Text('Guardar', style: TextStyle(color: colors.primary),)
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
