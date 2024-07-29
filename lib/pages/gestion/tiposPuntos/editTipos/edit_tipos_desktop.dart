import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class EditTiposPtoDesktop extends StatefulWidget {
  const EditTiposPtoDesktop({super.key});

  @override
  State<EditTiposPtoDesktop> createState() => _EditTiposPtoDesktopState();
}

class _EditTiposPtoDesktopState extends State<EditTiposPtoDesktop> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TipoPtosInspeccion tipoPtoSeleccionado = TipoPtosInspeccion.empty();
  late String token = '';

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
    _codController.text = tipoPtoSeleccionado.codTipoPuntoInspeccion;
    _descripcionController.text = tipoPtoSeleccionado.descripcion;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Tipos de puntos de Inspección',),
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
                        const Text("Código  "),
                        const SizedBox(
                          width: 27,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _codController,
                            enabled: false,
                            maxLines: 1,
                            label: 'Código',
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
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
                            if(tipoPtoSeleccionado.tipoPuntoInspeccionId != 0)...[
                              CustomButton(
                              onPressed: () async {
                                router.push('/tareasTiposPunto');
                              },
                              text: 'Tareas',
                              tamano: 20,
                              ),
                              const SizedBox(width: 30,),
                              CustomButton(
                              onPressed: () async {
                                router.push('/plagasTiposPunto');
                              },
                              text: 'Plagas',
                              tamano: 20,
                              ),
                              const SizedBox(width: 30,),
                              CustomButton(
                              onPressed: () async {
                                router.push('/materialesTiposPunto');
                              },
                              text: 'Materiales',
                              tamano: 20,
                              ),
                              const SizedBox(width: 30,),
                            ],
                            CustomButton(
                              onPressed: () async {
                                await postPut(context);
                              },
                              text: 'Guardar',
                              tamano: 20,
                            ),
                            if(tipoPtoSeleccionado.tipoPuntoInspeccionId != 0)...[
                              const SizedBox(width: 30,),
                              CustomButton(
                              onPressed: () async {
                                borrarTipoPto(tipoPtoSeleccionado);
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
      ),
    );
  }

  borrarTipoPto(TipoPtosInspeccion tipoPto) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar tarea'),
          content: Text('Esta por borrar la tarea ${tipoPto.descripcion}, esta seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await TiposPtosInspeccionServices().deleteTipoPto(context, tipoPto, token);
              },
              child: const Text('Confirmar')),
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