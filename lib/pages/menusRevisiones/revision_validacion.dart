import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/control_orden.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/orden_control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

class RevisionValidacionMenu extends StatefulWidget {
  const RevisionValidacionMenu({super.key});

  @override
  State<RevisionValidacionMenu> createState() => _RevisionValidacionMenuState();
}

class _RevisionValidacionMenuState extends State<RevisionValidacionMenu> {
  late Orden orden = Orden.empty();

  List<ControlOrden> controles = [];
  String token = '';
  late String validacion = '';
  int count = 0;
  int desaprueba = 0;
  List<ControlOrden> listaGenerica = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    orden = context.read<OrdenProvider>().orden;
    controles = await OrdenControlServices().getControlOrden(context, orden, token);
    listaGenerica = controles.where((element) => element.controlRegId == 0).toList();
    count = listaGenerica.length;
    if(count == 0){
      listaGenerica = controles.where((element) => element.respuesta == 'DESAPRUEBA').toList();
      desaprueba = listaGenerica.length;
    }

    validacion = count > 0 ? 'Complete el cuestionario' : desaprueba == 0 ? 'Se valida' : 'No se valida';


    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 500,
          width: Constantes().ancho,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Card(
                  elevation: 10,
                  child: Text(
                    validacion,
                    style: TextStyle(fontSize: 35, color: count > 0 ? Colors.red : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                width: Constantes().ancho,
                child: ListView.builder(
                  itemCount: listaGenerica.length,
                  itemBuilder: (context, i){
                    var control = listaGenerica[i];
                    return SizedBox(
                      width: Constantes().ancho,
                      child: Card(
                        child: ListTile(
                          title: Text(control.grupo),
                          subtitle: Text(control.pregunta),
                        ),
                      ),
                    );
                  },
                ),
              ),
              BottomAppBar(
                notchMargin: 10,
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                color: Colors.transparent,
                child: CustomButton(
                  onPressed: () {},
                  text: 'Confirmar',
                  tamano: 20,
                ),
              )
            ],
          ),
        ),
      );
      
  }
}
