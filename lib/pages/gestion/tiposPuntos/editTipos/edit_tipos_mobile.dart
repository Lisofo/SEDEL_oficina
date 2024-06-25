import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class EditTiposPtoMobile extends StatefulWidget {
  const EditTiposPtoMobile({super.key});

  @override
  State<EditTiposPtoMobile> createState() => _EditTiposPtoMobileState();
}

class _EditTiposPtoMobileState extends State<EditTiposPtoMobile> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TipoPtosInspeccion tipoPtoSeleccionado = TipoPtosInspeccion.empty();
  late String token = '';
  int buttonIndex = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos(){
    tipoPtoSeleccionado = context.read<OrdenProvider>().tiposPuntosGestion;
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
    _codController.text = tipoPtoSeleccionado.codTipoPuntoInspeccion;
    _descripcionController.text = tipoPtoSeleccionado.descripcion;

    return Scaffold(
      appBar: AppBarMobile(titulo: 'Tipos de puntos de Inspección',),      
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
            if(tipoPtoSeleccionado.tipoPuntoInspeccionId != 0)... [
              BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0:
                      await postPut(context);
                    break;
                    case 1:
                      await borrarTarea(tipoPtoSeleccionado);
                    break;
                    case 2:
                      router.push('/materialesTiposPunto');
                    break;
                    case 3:
                      router.push('/plagasTiposPunto');
                    break;
                    case 4:
                      router.push('/tareasTiposPunto');
                    break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.primary,
                type: BottomNavigationBarType.shifting,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.save),
                    label: 'Guardar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.delete),
                    label: 'Borrar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grading),
                    label: 'Materiales',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bug_report),
                    label: 'Plagas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.task),
                    label: 'Tareas',
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
                  //  await postPut(context);
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
  //ToDo cambiar de tarea a TipoPTo
  
  borrarTarea(TipoPtosInspeccion pto) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar tarea'),
          content: Text('Esta por borrar la tarea ${pto.descripcion}, esta seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await TiposPtosInspeccionServices().deleteTipoPto(context, pto, token);
              },
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    tipoPtoSeleccionado.codTipoPuntoInspeccion = _codController.text;
    tipoPtoSeleccionado.descripcion = _descripcionController.text;
    
    if(tipoPtoSeleccionado.tipoPuntoInspeccionId == 0){
      await TiposPtosInspeccionServices().postTipoPto(context, tipoPtoSeleccionado, token);
    }else{
      await TiposPtosInspeccionServices().putTipoPto(context, tipoPtoSeleccionado, token);
    }
    setState(() {});
  }
}