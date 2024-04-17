import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import '../../../widgets/drawer.dart';

class EditServiciosPage extends StatefulWidget {
  const EditServiciosPage({super.key});

  @override
  State<EditServiciosPage> createState() => _EditServiciosPageState();
}

class _EditServiciosPageState extends State<EditServiciosPage> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Servicio servicioSeleccionado = Servicio.empty();
  late String token = '';

  late List<TipoServicio> tipoServicios = [
    TipoServicio(tipoServicioId: 1, codTipoServicio: '1', descripcion: 'COMUN'),
    TipoServicio(tipoServicioId: 2, codTipoServicio: '2', descripcion: 'EVENTUAL'),
  ];
  TipoServicio? tipoServicioSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() {
    servicioSeleccionado = context.read<OrdenProvider>().servicio;
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
    _codController.text = servicioSeleccionado.codServicio;
    _descripcionController.text = servicioSeleccionado.descripcion;

    tipoServicioSeleccionado = servicioSeleccionado.tipoServicio;
    late TipoServicio tipoServicioInicialSeleccionado = tipoServicios[0];

    if (tipoServicioSeleccionado!.tipoServicioId != 0) {
      tipoServicioInicialSeleccionado = tipoServicios.firstWhere(
          (tipoServicio) => tipoServicio.tipoServicioId == tipoServicioSeleccionado!.tipoServicioId);
    }

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Servicios',),
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
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text("Tipo de servicio  "),
                      SizedBox(
                        width: 300,
                        child: CustomDropdownFormMenu(
                          value: tipoServicioInicialSeleccionado,
                          hint: 'Seleccione cargo',
                          items: tipoServicios.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e.descripcion),
                            );
                          }).toList(),
                          onChanged: (value) {
                            tipoServicioSeleccionado = value;
                          },
                        ),
                      ),
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
                          if(servicioSeleccionado.servicioId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () {
                                borrarServicio(servicioSeleccionado);
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

  borrarServicio(Servicio servicio) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar servicio'),
          content: Text('Esta por borrar el servicio ${servicio.descripcion}, esta seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await ServiciosServices().deleteServicio(context, servicio, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    servicioSeleccionado.codServicio =  _codController.text;
    servicioSeleccionado.descripcion =  _descripcionController.text;
    servicioSeleccionado.tipoServicio.tipoServicioId = tipoServicioSeleccionado!.tipoServicioId;
    servicioSeleccionado.tipoServicioId = tipoServicioSeleccionado!.tipoServicioId;
    
    if(servicioSeleccionado.servicioId == 0){
      await ServiciosServices().postServicio(context, servicioSeleccionado, token);
    }else{
      await ServiciosServices().putServicios(context, servicioSeleccionado, token);
    }
    setState(() {});
  }
}
