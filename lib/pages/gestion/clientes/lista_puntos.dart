// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/models/plano.dart';
import 'package:sedel_oficina_maqueta/models/pto_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/zona.dart';
import 'package:sedel_oficina_maqueta/services/planos_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class ListaPuntos extends StatefulWidget {
  List<Ptoinspeccion> puntos;
  List<TipoPtosInspeccion> tiposDePuntos;
  TipoPtosInspeccion selectedTipoPto = TipoPtosInspeccion.empty();
  List<PlagaObjetivo> plagasObjetivo;
  Cliente cliente;
  Plano plano;
  String token;

  Function(TipoPtosInspeccion) onTipoPtoChanged;
  final Function(List<Ptoinspeccion>) actualizarListaPuntos;



  ListaPuntos({
    super.key, 
    required this.puntos, 
    required this.selectedTipoPto, 
    required this.tiposDePuntos, 
    required this.onTipoPtoChanged, 
    required this.plagasObjetivo,
    required this.cliente,
    required this.plano,
    required this.token,
    required this.actualizarListaPuntos,
  });


  @override
  State<ListaPuntos> createState() => _ListaPuntosState();
}

class _ListaPuntosState extends State<ListaPuntos> {
  List<ZonaPI> zonas = [
    ZonaPI(zona: 'Interior', codZona: 'I'),
    ZonaPI(zona: 'Exterior', codZona: 'E'),
  ];
  late ZonaPI zonaSeleccionada = ZonaPI.empty();
  late PlagaObjetivo plagaObjetivoSeleccionada = PlagaObjetivo.empty();
  late TextEditingController comentarioController = TextEditingController();
  late TextEditingController sectorController = TextEditingController();
  late TextEditingController descripcionController = TextEditingController();
  late TextEditingController codPuntoInspeccionController = TextEditingController();
  late TextEditingController codPlanoController = TextEditingController();
  late TextEditingController codigoBarraController = TextEditingController();


  List<Ptoinspeccion> get ptosFiltrados {
    if(widget.selectedTipoPto.tipoPuntoInspeccionId > 0){
      return widget.puntos
          .where((pto) =>
              pto.tipoPuntoInspeccionId == widget.selectedTipoPto.tipoPuntoInspeccionId)
          .toList();
    }else{
      return widget.puntos.toList();
    }
  }

  List<Ptoinspeccion> get puntosSeleccionados {
    return ptosFiltrados.where((pto) => pto.seleccionado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: Constantes().ancho,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: colors.primary),
              borderRadius: BorderRadius.circular(5)),
          child: DropdownButtonFormField(
            decoration: const InputDecoration(border: InputBorder.none),
            hint: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text('Ptos de Inspeccion'),
            ),
            items: widget.tiposDePuntos.map((e) {
              return DropdownMenuItem(
                value: e,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    e.descripcion,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            isDense: true,
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                widget.onTipoPtoChanged(value!);
              });
            },
          ),
        ),
        SizedBox(
          width: Constantes().ancho,
          height: 495,
          child: ListView.separated(
            itemCount: ptosFiltrados.length,
            itemBuilder: (context, i) {
              var punto = ptosFiltrados[i];
              return ListTile(
                title: Text('Punto ${punto.codPuntoInspeccion}'),
                subtitle: Row(
                  children: [
                    Text('Zona: ${punto.zona}'),
                    const SizedBox(
                      width: 20,
                    ),
                    Text('Sector: ${punto.sector}'),

                  ],
                ),
                trailing: Checkbox(
                  activeColor: colors.primary,
                  value: punto.seleccionado,
                  splashRadius: 40,
                  onChanged: (bool? newValue) {
                    setState(() {
                      punto.seleccionado = newValue ?? false;
                    });
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
        SizedBox(
          width: Constantes().ancho,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: 'Editar estado/sub estado', 
                onPressed: () {}
              ),
              const SizedBox(width: 10,),
              CustomButton(
                text: 'Borrar punto', 
                onPressed: (){
                  borrarPunto(puntosSeleccionados);
                }
              ),
              const SizedBox(width: 10,),
              CustomButton(
                onPressed: (){
                  editarPunto(puntosSeleccionados);
                }, 
                text: 'Editar punto'
              ),
            ],
          ),
        )
      ],
    );
  }

  editarPunto(List<Ptoinspeccion> puntos){
    if(puntosSeleccionados.length == 1){
      codPuntoInspeccionController.text = puntosSeleccionados[0].codPuntoInspeccion;
      zonaSeleccionada = zonas.firstWhere((element) =>
        element.codZona == puntosSeleccionados[0].zona);
      sectorController.text = puntosSeleccionados[0].sector;
      plagaObjetivoSeleccionada = widget.plagasObjetivo.firstWhere(
                    (element) => element.plagaObjetivoId == puntosSeleccionados[0].plagaObjetivoId);
      comentarioController.text = puntosSeleccionados[0].comentario;
      codigoBarraController.text = puntosSeleccionados[0].codigoBarra;
    }else{
      codPuntoInspeccionController.text  = '';
      zonaSeleccionada = ZonaPI.empty();
      sectorController.text = '';
      plagaObjetivoSeleccionada = PlagaObjetivo.empty();
      comentarioController.text = '';
      codigoBarraController.text = '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Editar Punto'),
            content: SizedBox(
              width: Constantes().ancho,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(puntosSeleccionados.length == 1)
                  CustomTextFormField(
                    controller: codPuntoInspeccionController,
                    maxLines: 1,
                    hint: 'Codigo punto de inspeccion',
                    label: 'Codigo punto de inspeccion',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdownFormMenu(
                      hint: 'Zona',
                      value: zonaSeleccionada.codZona != ''
                          ? zonaSeleccionada
                          : null,
                      items: zonas.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.zona,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        zonaSeleccionada = value;
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: sectorController,
                    maxLines: 1,
                    hint: 'Sector',
                    label: "Sector",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdownFormMenu(
                      hint: 'Plaga objetivo',
                      value:
                          plagaObjetivoSeleccionada.plagaObjetivoId != 0
                              ? plagaObjetivoSeleccionada
                              : null,
                      items: widget.plagasObjetivo.map((e) {
                        return DropdownMenuItem<PlagaObjetivo>(
                          value: e,
                          child: SizedBox(
                            width: 180,
                            child: Text(
                              e.descripcion,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        plagaObjetivoSeleccionada = value;
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                      controller: comentarioController,
                      maxLines: 1,
                      hint: 'Comentario',
                      label: 'Comentario'),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: codigoBarraController,
                    maxLines: 1,
                    hint: 'Codigo de barras',
                    label: 'Codigo de barras',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  router.pop(context);
                },
              ),
              TextButton(
                child: const Text('Confirmar'),
                onPressed: () async {
                  for (var i = 0; i < puntosSeleccionados.length; i++) {
                    Ptoinspeccion nuevoPtoInspeccion = Ptoinspeccion(
                        puntoInspeccionId: puntosSeleccionados[i].puntoInspeccionId,                        
                        planoId: puntosSeleccionados[i].planoId,
                        tipoPuntoInspeccionId: puntosSeleccionados[i].tipoPuntoInspeccionId,
                        codTipoPuntoInspeccion: puntosSeleccionados[i].codTipoPuntoInspeccion,
                        plagaObjetivoId: puntosSeleccionados[i].plagaObjetivoId,
                        codPuntoInspeccion: codPuntoInspeccionController.text,
                        codigoBarra: codigoBarraController.text,
                        zona: zonaSeleccionada.codZona,
                        sector: sectorController.text,
                        comentario: comentarioController.text,
                        seleccionado: puntosSeleccionados[i].seleccionado,
                        codPlagaObjetivo: puntosSeleccionados[i].codPlagaObjetivo,
                        descPlagaObjetivo: puntosSeleccionados[i].descPlagaObjetivo,
                        descTipoPunto: puntosSeleccionados[i].descTipoPunto,
                        desde: puntosSeleccionados[i].desde,
                        estado: puntosSeleccionados[i].estado,
                        subEstado: puntosSeleccionados[i].subEstado
                      );

                        if (puntosSeleccionados[i].puntoInspeccionId != 0) {
                          await PlanosServices().putPtoInspeccion(context, widget.cliente, widget.plano, nuevoPtoInspeccion, widget.token);
                        } 
                      }
                  widget.actualizarListaPuntos(puntos);
                  
                },
              ),
            ],
          ),
        );
      }
    );
  }

  borrarPunto(List<Ptoinspeccion> puntos) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar Punto'),
          content: SizedBox(
            child: Text(
              puntos.length == 1 ? 'Esta por borrar el punto ${puntos[0].codPuntoInspeccion}. Esta seguro de borrarlo?' 
                : 'Esta por borrar multiples puntos seleccionados. Esta seguro de borrarlos?' )
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                router.pop(context);
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {

                if(puntos.length == 1 ) {
                  await PlanosServices().deletePtoInspeccion(context, widget.cliente, widget.plano, puntos[0], widget.token);
                  await PlanosServices.showDialogs(context, 'Punto borrado correctamente', true, false);
                  widget.actualizarListaPuntos(puntos);
                }else {
                  for (var punto in puntos) {
                    await PlanosServices().deletePtoInspeccion(context, widget.cliente, widget.plano, punto, widget.token);
                    await PlanosServices.showDialogs(context, 'Puntos borrados correctamente', true, false);
                  }
                  widget.actualizarListaPuntos(puntos);
                }

              },
            ),
          ],
        );
      }
    );
  }


}
