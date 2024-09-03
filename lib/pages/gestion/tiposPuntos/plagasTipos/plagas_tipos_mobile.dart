import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/plaga_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';

class PlagasTiposPuntosMobile extends StatefulWidget {
  const PlagasTiposPuntosMobile({super.key});

  @override
  State<PlagasTiposPuntosMobile> createState() => _PlagasTiposPuntosMobileState();
}

class _PlagasTiposPuntosMobileState extends State<PlagasTiposPuntosMobile> {
  late List<Plaga> plagas = [];
  late String token = '';
  bool activo = false;
  late List<int> plagasId = [];
  late List<PlagaTipoPto> plagasTipoPto = [];
  late TipoPtosInspeccion tipoSeleccionado = TipoPtosInspeccion.empty();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    tipoSeleccionado = context.read<OrdenProvider>().tiposPuntosGestion;
    plagas = await PlagaServices().getPlagas(context, '', '', token);
    plagasTipoPto = await TiposPtosInspeccionServices().getPlagasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, token);
    for (var plaga in plagas) {
      activo = plagasTipoPto.any((plag) => plag.plagaId == plaga.plagaId);
      plaga.activo = activo;
      if(activo) {
        plagasId.add(plaga.plagaId);
      }
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarMobile(titulo: 'Plagas del tipo de punto inspección'),
        body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Expanded(
          child: ListView.separated(
            itemCount: plagas.length,
            itemBuilder: (context, i){
              return CheckboxListTile(
                value: plagas[i].activo,
                onChanged: (value) async {
                  setState(() {
                    plagas[i].activo = value!;
                  });
                  if (value!) {
                    plagasId.add(plagas[i].plagaId);
                    await TiposPtosInspeccionServices().postPlagasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, plagas[i].plagaId, token);
                  } else {
                    plagasId.remove(plagas[i].plagaId);
                    await TiposPtosInspeccionServices().deletePlagasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, plagas[i].plagaId, token);
                  }
                },
                title: Text(plagas[i].descripcion),
              );
            }, 
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            }
          ),
        ),
      ),
      ),
    );
  }
}