import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';

import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class EditServiciosMobile extends StatefulWidget {
  const EditServiciosMobile({super.key});

  @override
  State<EditServiciosMobile> createState() => _EditServiciosMobileState();
}

class _EditServiciosMobileState extends State<EditServiciosMobile> {
  final _codController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Servicio servicioSeleccionado = Servicio.empty();
  late String token = '';
  int buttonIndex = 0;

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
    final colors = Theme.of(context).colorScheme;
    _codController.text = servicioSeleccionado.codServicio;
    _descripcionController.text = servicioSeleccionado.descripcion;

    tipoServicioSeleccionado = servicioSeleccionado.tipoServicio;
    late TipoServicio tipoServicioInicialSeleccionado = tipoServicios[0];

    if (tipoServicioSeleccionado!.tipoServicioId != 0) {
      tipoServicioInicialSeleccionado = tipoServicios.firstWhere(
          (tipoServicio) => tipoServicio.tipoServicioId == tipoServicioSeleccionado!.tipoServicioId);
    }

    return Scaffold(
      appBar: AppBarMobile(titulo: 'Servicios',),
      
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Descripcion  "),
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
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Tipo de servicio  "),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
              if (servicioSeleccionado.servicioId != 0) ...[
                BottomNavigationBar(
                  currentIndex: buttonIndex,
                  onTap: (index) async {
                    buttonIndex = index;
                    switch (buttonIndex) {
                      case 0:
                        await postPut(context);
                      break;
                      case 1:
                        await borrarServicio(servicioSeleccionado);
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
