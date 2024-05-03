import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import '../../../../config/router/app_router.dart';

class EditMetodosAplicacionMobile extends StatefulWidget {
  const EditMetodosAplicacionMobile({super.key});

  @override
  State<EditMetodosAplicacionMobile> createState() => _EditMetodosAplicacionMobileState();
}

class _EditMetodosAplicacionMobileState extends State<EditMetodosAplicacionMobile> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late MetodoAplicacion metodoSeleccionado = MetodoAplicacion.empty();
  late String token = '';
  int buttonIndex = 0;

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
    final colors = Theme.of(context).colorScheme;
    _codController.text = metodoSeleccionado.codMetodoAplicacion;
    _descripcionController.text = metodoSeleccionado.descripcion;


    return Scaffold(
      appBar: AppBarMobile(titulo: 'Metodos de aplicación'),
      
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text("Codigo  "),
                const SizedBox(
                  width: 1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *0.7,
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
                  width: MediaQuery.of(context).size.width *0.7,
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
            BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0: 
                      await postPut(context);
                    break;
                    case 1:
                      await borrarMetodo(metodoSeleccionado);
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
          ],
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