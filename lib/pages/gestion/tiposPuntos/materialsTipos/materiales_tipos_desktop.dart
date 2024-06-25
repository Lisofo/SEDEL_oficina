import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/material_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class MaterialesTiposPuntosDesktop extends StatefulWidget {
  const MaterialesTiposPuntosDesktop({super.key});

  @override
  State<MaterialesTiposPuntosDesktop> createState() => _MaterialesTiposPuntosDesktopState();
}

class _MaterialesTiposPuntosDesktopState extends State<MaterialesTiposPuntosDesktop> {

  late List<Materiales> materiales = [];
  late String token = '';
  bool activo = false;
  late List<int> materialesId = [];
  late List<MaterialTipoPto> materialesTipoPto = [];
  late TipoPtosInspeccion tipoSeleccionado = TipoPtosInspeccion.empty();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    tipoSeleccionado = context.read<OrdenProvider>().tiposPuntosGestion;
    materiales = await MaterialesServices().getMateriales(context, '', '', token);
    materialesTipoPto = await TiposPtosInspeccionServices().getMaterialesTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, token);
    for (var material in materiales) {
      activo = materialesTipoPto.any((mate) => mate.materialId == material.materialId);
      material.activo = activo;
      if(activo) {
        materialesId.add(material.materialId);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Materiales del tipo de punto inspección'),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child:ListView.separated(
                    itemCount: materiales.length,
                    itemBuilder: (context, i){
                      return CheckboxListTile(
                        value: materiales[i].activo,
                        onChanged: (value) async {
                          setState(() {
                            materiales[i].activo = value!;
                          });
                          if (value!) {
                            materialesId.add(materiales[i].materialId);
                            await TiposPtosInspeccionServices().postMaterialesTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, materiales[i].materialId, token);
                          } else {
                            materialesId.remove(materiales[i].materialId);
                            await TiposPtosInspeccionServices().deleteMaterialesTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, materiales[i].materialId, token);
                          }
                        },
                        title: Text(materiales[i].descripcion),
                        );
                    }, 
                    separatorBuilder: (BuildContext context, int index) {
                       return const Divider();
                    }
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}