// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls, avoid_print, avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/models/plano.dart';
import 'package:sedel_oficina_maqueta/models/pto_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/zona.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/plagas_objetivo_services.dart';
import 'package:sedel_oficina_maqueta/services/planos_services.dart';
import 'package:sedel_oficina_maqueta/services/ptos_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class PtosInspeccionClientesMobile extends StatefulWidget {
  const PtosInspeccionClientesMobile({super.key});

  @override
  State<PtosInspeccionClientesMobile> createState() => _PtosInspeccionClientesMobileState();
}

class _PtosInspeccionClientesMobileState extends State<PtosInspeccionClientesMobile> {
  late List<Plano> planos = [];
  late Plano nuevoPlanoACrear = Plano.empty();
  late String token = '';
  late Cliente cliente = Cliente.empty();
  late List<Ptoinspeccion> puntos = [];
  List<TipoPtosInspeccion> tiposDePuntos = [];
  late TipoPtosInspeccion selectedTipoPto = TipoPtosInspeccion.empty();
  bool mostrarLista = false;
  List<ZonaPI> zonas = [
    ZonaPI(zona: 'Interior', codZona: 'I'),
    ZonaPI(zona: 'Exterior', codZona: 'E'),
  ];
  late DateTime? fechaDesdePatch = DateTime.now();
  late DateTime? fechaDesdePlano = DateTime.now();
  late DateTime? fechaHastaPlano = DateTime.now();

  late List<PlagaObjetivo> plagasObjetivo = [];
  late ZonaPI zonaSeleccionada = ZonaPI.empty();
  late PlagaObjetivo plagaObjetivoSeleccionada = PlagaObjetivo.empty();
  late TextEditingController comentarioController = TextEditingController();
  late TextEditingController sectorController = TextEditingController();
  late TextEditingController descripcionController = TextEditingController();
  late TextEditingController codPuntoInspeccionController = TextEditingController();
  late TextEditingController codPlanoController = TextEditingController();
  late TextEditingController codigoBarraController = TextEditingController();
  late Plano planoSeleccionado = Plano.empty();
  late Plano? planoSeleccionadoACopiar = null;
  bool copiando = false;
  List<String> estadosPuntos = [
    'ACTIVO / TRASLADADO',
	  'ACTIVO / SINACCESO',
	  'INACTIVO / DESINSTALADO'
  ];
  List<String> estadosPlano = [
    'PENDIENTE',
    'ACTIVO',
    'INACTIVO'
  ];

  late String estadoPuntoSeleccionado = '';
  late String estadoPlanoSeleccionado = '';
  late List<Orden> ordenesCliente = [];
  late Orden ordenSeleccionada = Orden.empty();
  late DateTime hoy = DateTime.now();
  late DateTime desde = hoy.subtract(const Duration(days: 30));
  late DateTime hasta = DateTime(hoy.year,hoy.month,hoy.day,0,0,0);
  int buttonIndex = 0;



  List<Ptoinspeccion> get ptosFiltrados {
    if(selectedTipoPto.tipoPuntoInspeccionId > 0){
      return puntos
          .where((pto) =>
              pto.tipoPuntoInspeccionId == selectedTipoPto.tipoPuntoInspeccionId)
          .toList();
    }else{
      return puntos.toList();
    }
  }

  List<Ptoinspeccion> get puntosSeleccionados {
    return ptosFiltrados.where((pto) => pto.seleccionado).toList();
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void actualizarListaPuntos(List<Ptoinspeccion> nuevaListaPuntos) {
    setState(() {
      puntos = nuevaListaPuntos;
    });
  }


  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    cliente = context.read<OrdenProvider>().cliente;
    tiposDePuntos = await PtosInspeccionServices().getTiposPtosInspeccion(context,token);
    planos = await PlanosServices().getClientPlano(context, cliente, token);
    plagasObjetivo = await PlagaObjetivoServices().getPlagasObjetivo(context, '', '', token);
    tiposDePuntos.insert(0, TipoPtosInspeccion(tipoPuntoInspeccionId: 0, codTipoPuntoInspeccion: '0', descripcion: 'Todos'));
    

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ptos de inspección', style: TextStyle(color: Colors.white),),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(
          color: colors.background
        ),
        actions: [
          IconButton(
            onPressed: (){
              router.pop();
            }, 
            icon: const Icon(Icons.arrow_back_ios_new)
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'editar_estado',
                child: Text('Editar estado/sub estado'),
              ),
              const PopupMenuItem<String>(
                value: 'borrar_punto',
                child: Text('Borrar punto'),
              ),
              const PopupMenuItem<String>(
                value: 'editar_punto',
                child: Text('Editar punto'),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'editar_estado':
                  cambiarEstadoPunto(puntosSeleccionados);
                  break;
                case 'borrar_punto':
                  borrarPunto(puntosSeleccionados);
                  break;
                case 'editar_punto':
                  editarPunto(puntosSeleccionados);
                  break;
              }
            },
          )
        ],  
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: colors.primary, width: 15)),  
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: planos.length,
                  itemBuilder: (context, i) {
                    var plano = planos[i];
                    return ListTile(
                      title: Text('Plano ${plano.codPlano}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Desde: ${DateFormat('d/MM/yyyy').format(plano.desde)}'),
                          const SizedBox(width: 30,),
                          Text('Hasta: ${plano.hasta == null ? '' : DateFormat('d/MM/yyyy').format(plano.hasta!)}'),
                          const SizedBox(width: 30,),
                          Text('Estado: ${plano.estado}')
                        ],
                      ),
                      trailing: IconButton(
                      onPressed: () {
                        nuevoPlano(plano);
                      }, 
                      icon: const Icon(Icons.edit)),
                      onTap: () async {
                        mostrarLista = true;
                        planoSeleccionado = plano;
                        puntos = await PlanosServices().getPuntosPlano(context, cliente, plano, token);
                        setState(() {});
                      },
                    );
                  }, 
                  separatorBuilder: (BuildContext context, int index) { 
                    return Divider(color: colors.primary,);
                  },
                )
              ),
              BottomNavigationBar(
                elevation: 0,
                currentIndex: buttonIndex,
                onTap: (index) async{   
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0: 
                      nuevoPlano(nuevoPlanoACrear);
                    case 1:
                      cambiarEstadoPlano(planoSeleccionado);
                    break;
                  }  
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_comment_outlined),
                    label: 'Nuevo plano',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Cambiar estado del plano'
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (mostrarLista)
            copiando ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Cargando',style: TextStyle(fontSize: 24),),
                  SizedBox(height: 20,),
                  CircularProgressIndicator()
                ],
              ),
            ) 
            : Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: colors.primary),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: CustomDropdownFormMenu(
                    hint: 'Ptos de Inspeccion',
                    items: tiposDePuntos.map((e) {
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
                        selectedTipoPto = value!;
                        for (var i = 0; i < ptosFiltrados.length; i++) {
                          ptosFiltrados[i].seleccionado = false;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.separated(
                    itemCount: ptosFiltrados.length,
                    itemBuilder: (context, i) {
                      var punto = ptosFiltrados[i];
                      return ListTile(
                        title: Text('Punto ${punto.codPuntoInspeccion}'),
                        subtitle: FittedBox(
                          fit: BoxFit.contain,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Zona: ${punto.zona}'),
                              const SizedBox(width: 15,),
                              Text('Sector: ${punto.sector}'),
                              const SizedBox(width: 15,),
                              Text('Estado: ${punto.estado}'),
                              const SizedBox(width: 15,),
                              Text('Subestado: ${punto.subEstado}'),
                            ],
                          ),
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
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,        
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(mostrarLista)...[
              CustomButton(
                text: 'Guardar puntos', 
                onPressed: (){
                  confirmacion();
                },
                tamano: 15,
                disabled: planoSeleccionadoACopiar == null,  
              ),
              const SizedBox(width: 10,),
              CustomButton(
                text: 'Nuevo punto', 
                onPressed: (){
                  nuevoPuntoDeInspeccion();
                },
                disabled: selectedTipoPto.tipoPuntoInspeccionId == 0,
                tamano: 15,
              ),
            ]
          ],
        ),
      ),
    );
  }

  nuevoPuntoDeInspeccion(){
    codPuntoInspeccionController.text = '';
    sectorController.text = '';
    comentarioController.text = '';
    codigoBarraController.text = '';
    plagaObjetivoSeleccionada = PlagaObjetivo.empty();
    zonaSeleccionada = ZonaPI.empty();

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Nuevo Punto'),
            content: SizedBox(
              width: Constantes().ancho,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    }
                  ),
                  const SizedBox(height: 10,),
                  CustomTextFormField(
                    controller: sectorController,
                    maxLines: 1,
                    hint: 'Sector',
                    label: "Sector",
                  ),
                  const SizedBox(height: 10,),
                  CustomDropdownFormMenu(
                    hint: 'Plaga objetivo',
                    value: plagaObjetivoSeleccionada.plagaObjetivoId != 0 ? plagaObjetivoSeleccionada : null,
                    items: plagasObjetivo.map((e) {
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
                    }
                  ),
                  const SizedBox(height: 10,),
                  CustomTextFormField(
                    controller: comentarioController,
                    maxLines: 1,
                    hint: 'Comentario',
                    label: 'Comentario'
                  ),
                  const SizedBox(height: 10,),
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
                  router.pop(context);
                  crearNuevoPunto();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  crearNuevoPunto() async {
    Ptoinspeccion nuevoPuntoInspeccion = Ptoinspeccion(
      puntoInspeccionId: 0, 
      planoId: planoSeleccionado.planoId, 
      codPuntoInspeccion: codPuntoInspeccionController.text, 
      zona: zonaSeleccionada.codZona, 
      sector: sectorController.text, 
      codigoBarra: codigoBarraController.text, 
      tipoPuntoInspeccionId: selectedTipoPto.tipoPuntoInspeccionId, 
      codTipoPuntoInspeccion: selectedTipoPto.codTipoPuntoInspeccion, 
      descTipoPunto: '', 
      plagaObjetivoId: plagaObjetivoSeleccionada.plagaObjetivoId, 
      codPlagaObjetivo: plagaObjetivoSeleccionada.codPlagaObjetivo, 
      descPlagaObjetivo: plagaObjetivoSeleccionada.descripcion, 
      desde: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,0,0,0), 
      estado: 'ACTIVO', 
      subEstado: 'NUEVO', 
      comentario: comentarioController.text,
      seleccionado: false,
    );

    await PlanosServices().postPtoInspeccion(context, cliente, planoSeleccionado, nuevoPuntoInspeccion, token);
    await PlanosServices.showDialogs(context, 'Punto creado correctamente',false,false);
    setState(() {
      actualizar(puntos);
    });
  }

  nuevoPlano(Plano plano){
    
    if(plano.planoId != 0){
      codPlanoController.text = plano.codPlano;
      descripcionController.text = plano.descripcion;
      fechaDesdePlano = plano.desde;
      fechaHastaPlano = plano.hasta;

    }else{
      codPlanoController.text = '';
      descripcionController.text = '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text(plano.planoId == 0 ? 'Nuevo plano' : 'Editar plano'),
            content: StatefulBuilder(
              builder: (context, setStateBd) => SizedBox(
                width: Constantes().ancho,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      controller: codPlanoController,
                      maxLines: 1,
                      hint: 'Codigo del plano',
                      label: 'Codigo del plano',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: descripcionController,
                      maxLines: 1,
                      hint: 'Descripcion',
                      label: "Descripcion",
                    ),
                    const SizedBox(height: 10,),
                    if(plano.planoId != 0)
                    CustomDropdownFormMenu(
                      hint: 'Plano a copiar',
                      items: planos.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.codPlano));
                      }).toList(),
                      onChanged: (value) async {
                        planoSeleccionadoACopiar = value;
                        print(planoSeleccionadoACopiar!.codPlano);
                      },
                    ),
                    const SizedBox(height: 10,),
                    ListTile(
                      title: Text('Fecha desde ${DateFormat('d/MM/yyyy').format(fechaDesdePlano!)}'),
                      onTap: () async {
                        await _selectFechaDesdePlano(context);
                        setStateBd((){});
                      },
                    ),
                    const SizedBox(height: 10,),
                    ListTile(
                      title: Text('Fecha hasta ${fechaHastaPlano != null ? DateFormat('d/MM/yyyy').format(fechaHastaPlano!) : ''}'),
                      onTap: () async {
                        await _selectFechaHastaPlano(context);
                        setStateBd((){});
                      },
                    ),
                  ],
                ),
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
                  if(plano.planoId == 0){
                    crearNuevoPlano();
                  }else if(plano.planoId > 0) {
                    editarPlano(plano);
                    if(planoSeleccionadoACopiar?.planoId != null){
                      traerPuntosDeOtroPlano();
                    }
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  crearNuevoPlano() async {
    var nuevoPlanoACrear = Plano(
      planoId: 0, 
      clienteId: cliente.clienteId, 
      codPlano: codPlanoController.text, 
      descripcion: descripcionController.text, 
      desde: DateTime(fechaDesdePlano!.year,fechaDesdePlano!.month,fechaDesdePlano!.day,0,0,0), 
      hasta: DateTime(fechaHastaPlano!.year,fechaHastaPlano!.month,fechaHastaPlano!.day,0,0,0),
      estado: ''
    );

    await PlanosServices().postPlano(context, cliente, nuevoPlanoACrear, token);
    planos = await PlanosServices().getClientPlano(context, cliente, token);
    setState(() {});
  }

  editarPlano(Plano plano) async {
   var planoAEditar = plano;
    planoAEditar.codPlano = codPlanoController.text;
    planoAEditar.descripcion = descripcionController.text;
    planoAEditar.desde = DateTime(fechaDesdePlano!.year,fechaDesdePlano!.month,fechaDesdePlano!.day,0,0,0);
    planoAEditar.hasta = plano.hasta == null ? null : DateTime(fechaHastaPlano!.year,fechaHastaPlano!.month,fechaHastaPlano!.day,0,0,0
  );

    await PlanosServices().putPlano(context, cliente, planoAEditar, token);
    planos = await PlanosServices().getClientPlano(context, cliente, token);
    setState(() {});
  }

  traerPuntosDeOtroPlano() async {
    puntos = await PlanosServices().getPuntosPlano(context, cliente, planoSeleccionadoACopiar!, token);
    puntos.forEach((element) => element.puntoInspeccionId = 0);
    setState(() {});
  }

  confirmacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Copiar Puntos'),
          content: SizedBox(
            width: Constantes().ancho,
            child: Text('Esta por copiar los puntos de inspección del plano ${planoSeleccionadoACopiar!.codPlano} al plano ${planoSeleccionado.codPlano}. Desea continuar con la accion?')
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
                router.pop(context);
                copiarPuntos(planoSeleccionado, puntos);
              },
            ),
          ],
        );
      }
    );
  }
  
  copiarPuntos(Plano plano, List<Ptoinspeccion> puntos) async {
    setState(() {
      copiando = true;
    });
    for(int i = 0; i < puntos.length; i++){
      await PlanosServices().postPtoInspeccion(context, cliente, plano, puntos[i], token);
    }
    setState(() {
      copiando = false;
    });
  }

  editarPunto(List<Ptoinspeccion> puntos){
    if(puntosSeleccionados.length == 1){
      codPuntoInspeccionController.text = puntosSeleccionados[0].codPuntoInspeccion;
      zonaSeleccionada = zonas.firstWhere((element) => element.codZona == puntosSeleccionados[0].zona);
      sectorController.text = puntosSeleccionados[0].sector;
      plagaObjetivoSeleccionada = plagasObjetivo.firstWhere((element) => element.plagaObjetivoId == puntosSeleccionados[0].plagaObjetivoId);
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
                  const SizedBox(height: 10,),
                  CustomDropdownFormMenu(
                    hint: 'Zona',
                    value: zonaSeleccionada.codZona != '' ? zonaSeleccionada : null,
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
                    }
                  ),
                  const SizedBox(height: 10,),
                  CustomTextFormField(
                    controller: sectorController,
                    maxLines: 1,
                    hint: 'Sector',
                    label: "Sector",
                  ),
                  const SizedBox(height: 10,),
                  CustomDropdownFormMenu(
                    hint: 'Plaga objetivo',
                    value: plagaObjetivoSeleccionada.plagaObjetivoId != 0 ? plagaObjetivoSeleccionada : null,
                    items: plagasObjetivo.map((e) {
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
                    }
                  ),
                  const SizedBox(height: 10,),
                  CustomTextFormField(
                    controller: comentarioController,
                    maxLines: 1,
                    hint: 'Comentario',
                    label: 'Comentario'
                  ),
                  const SizedBox(height: 10,),
                  if(puntosSeleccionados.length == 1)
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
                      codPuntoInspeccion: puntosSeleccionados.length == 1 ? codPuntoInspeccionController.text : puntosSeleccionados[i].codPuntoInspeccion,
                      codigoBarra: puntosSeleccionados.length == 1 ? codigoBarraController.text : puntosSeleccionados[i].codigoBarra,
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
                      await PlanosServices().putPtoInspeccion(context, cliente, planoSeleccionado, nuevoPtoInspeccion, token);
                    } 
                  }
                  if(puntosSeleccionados.length == 1){
                   await PlanosServices.showDialogs(context, 'Punto actualizado correctamente', true, false);
                  }else{
                   await PlanosServices.showDialogs(context, 'Puntos actualizados correctamente', true, false);
                  }
                  await actualizar(puntos);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> actualizar(List<Ptoinspeccion> puntos) async {
    puntos = await PlanosServices().getPuntosPlano(context, cliente, planoSeleccionado, token);
    setState(() {
      this.puntos = puntos;
    });
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
                  await PlanosServices().deletePtoInspeccion(context, cliente, planoSeleccionado, puntos[0], token);
                  await PlanosServices.showDialogs(context, 'Punto borrado correctamente', true, false);
                }else {
                  for (var punto in puntos) {
                    await PlanosServices().deletePtoInspeccion(context, cliente, planoSeleccionado, punto, token);
                  }
                  await PlanosServices.showDialogs(context, 'Puntos borrados correctamente', true, false);
                }
                await actualizar(puntos);
              },
            ),
          ],
        );
      }
    );
  }

  cambiarEstadoPunto(List<Ptoinspeccion> puntos) async {
    desde = DateTime(desde.year, desde.month, desde.day);
    ordenesCliente = await OrdenServices().getOrden(context, cliente.clienteId.toString(), '', desde.toIso8601String(), hasta.toIso8601String(), '', '', 0, token);
    if(puntos.length == 1){
      comentarioController.text = puntos[0].comentario;
    }else{
      comentarioController.text = '';
    }

    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Cambiar estado y subestado'),
          content: StatefulBuilder(
            builder: (context, setStateBd) => SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    puntos.length == 1 ? 'Esta por cambiar el estado del punto ${puntos[0].codPuntoInspeccion} del tipo ${selectedTipoPto.descripcion}' 
                    : 'Esta por cambiar el estado a multiples puntos'
                  ),
                  const SizedBox(height: 10,),
                  CustomDropdownFormMenu(
                    hint: 'Estado / Subestado',
                    items: estadosPuntos.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (value){
                      estadoPuntoSeleccionado = value;
                    }
                  ),
                  const SizedBox(height: 10,),
                  CustomTextFormField(
                    controller: comentarioController,
                    maxLines: 1,
                    hint: 'Comentario',
                  ),
                  const SizedBox(height: 10,),
                  ListTile(
                    title: Text('Fecha desde ${DateFormat('dd/MM/yyyy').format(fechaDesdePatch!)}'),
                    onTap: () async {
                      await _selectFechaDesdePatch(context);
                      setStateBd((){});
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomDropdownFormMenu(
                    hint:'Seleccione una orden si corresponde',
                    onChanged: (value){
                      ordenSeleccionada = value;
                    },
                    items: ordenesCliente.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text('Orden ${e.ordenTrabajoId} - ${DateFormat('dd/MM/yyyy').format(e.fechaOrdenTrabajo)}')
                      );
                    }).toList(),
                  )
                ],
              ),
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
              var estadoYSubEstado = estadoPuntoSeleccionado.split(' / ');
                
                for (var i = 0; i < puntosSeleccionados.length; i++) {
                  await PlanosServices().patchEstadoPunto(
                    context, 
                    cliente, 
                    planoSeleccionado, 
                    puntosSeleccionados[0],
                    estadoYSubEstado[0],
                    estadoYSubEstado[1],
                    comentarioController.text, 
                    fechaDesdePatch,
                    ordenSeleccionada.ordenTrabajoId, 
                    token
                  );
                }
                PlanosServices.showDialogs(context, 'Estado y subestado cambiados correctamente', true, false);
                await actualizar(puntos);
              },
            ),
          ],
        );      
      }
    );
  }

  Future<Null> _selectFechaDesdePatch(BuildContext context) async {
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        fechaDesdePatch = picked;
      });
    }
  }
  Future<Null> _selectFechaDesdePlano(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        fechaDesdePlano = picked;
      });
      
    }
  }
  Future<Null> _selectFechaHastaPlano(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        fechaHastaPlano = picked;
      });
    }
  }

  cambiarEstadoPlano(Plano plano){
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Cambiar estado del plano'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Esta por cambiar el estado del plano ${plano.codPlano}'),
              const SizedBox(height: 10,),
              CustomDropdownFormMenu(
                hint: 'Estado',
                items: estadosPlano.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value){
                  estadoPlanoSeleccionado = value;
                }
              ),
            ],
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
                await PlanosServices().patchEstadoPlano(context, cliente, plano, estadoPlanoSeleccionado, token);
                PlanosServices.showDialogs(context, 'Estado cambiado correctamente', true, false);
                setState(() {});
              },
            ),
          ],
        );
      }
    );
  }

}