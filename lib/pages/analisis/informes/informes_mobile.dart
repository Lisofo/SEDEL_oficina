import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/informes.dart';
import 'package:sedel_oficina_maqueta/models/informes_values.dart';
import 'package:sedel_oficina_maqueta/models/parametro.dart';
import 'package:sedel_oficina_maqueta/models/reporte.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/search/parametro_cliente_values.dart';
import 'package:sedel_oficina_maqueta/services/informes_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:url_launcher/url_launcher.dart';

class InformesMobile extends StatefulWidget {
  const InformesMobile({super.key});

  @override
  State<InformesMobile> createState() => _InformesMobileState();
}

class _InformesMobileState extends State<InformesMobile> {
  bool showSnackBar = false;
  bool expandChildrenOnReady = true;
  TreeViewController? _controller;
  late String token = '';
  late List<Informe> informes = [];
  TreeNode sampleTree = TreeNode.root();
  dynamic selectedNodeData; // Variable para guardar los datos del nodo seleccionado
  late List<Parametro> parametros = [];
  late ParametrosValues campoCliente = ParametrosValues.empty();
  late ParametrosValues campoPlagaObjetivo = ParametrosValues.empty();
  late String campoFecha = '';
  late String campoFechaDesde = '';
  late String campoFechaHasta = '';
  late String campoOrdenTrabajo = '';
  late String campoIdRevision = '';
  List<ParametrosValues> historial = [];
  List<ParametrosValues> parametrosValues = [];
  final Map<String, TextEditingController> _controllers = {};
  late String nombreInforme = '';
  int buttonIndex = 0;
  late dynamic selectedInforme = InformeHijo.empty();
  late String tipo = '';
  List<TiposImpresion> tipos = [];
  late MaskTextInputFormatter maskFormatter;
  late int rptGenId = 0;
  late Reporte reporte = Reporte.empty();
  late bool generandoInforme = false;
  late bool informeGeneradoEsS = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    informes = await InformesServices().getInformes(context, token);
    setState(() {
      sampleTree = convertInformesToTreeNode(informes);
    });
  }

  abrirUrl(String url, String token) async {
    Dio dio = Dio(); 
    String link = url += '?authorization=$token';
    print(link);
    try {
      // Realizar la solicitud HTTP con el encabezado de autorización
      Response response = await dio.get(
        link,
        options: Options(
          headers: {
            'Authorization': 'headers $token',
          },
        ),
      );
      // Verificar si la solicitud fue exitosa (código de estado 200)
      if (response.statusCode == 200) {
        // Si la respuesta fue exitosa, abrir la URL en el navegador
        Uri uri = Uri.parse(url);
        await launchUrl(uri);
      } else {
        // Si la solicitud no fue exitosa, mostrar un mensaje de error
        print('Error al cargar la URL: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores de solicitud
      print('Error al realizar la solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      onDrawerChanged: (isOpened) async {
        await cargarDatos();
      },
      appBar: AppBarDesktop(titulo: 'Informes'),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: 
        Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.8,
            child: TreeView.simple(
              tree: sampleTree,
              showRootNode: false,
              expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
                tree: node,
                color: Colors.black,
                padding: const EdgeInsets.all(8),
              ),
              indentation: const Indentation(style: IndentStyle.squareJoint),
              onItemTap: (item) async {
                if(item.data.objetoArbol == 'informe'){
                  parametros = await InformesServices().getParametros(context, token, item.data.informeId);
                  // print(parametros[0].parametroId);
                  nombreInforme = item.key;
                  selectedInforme = item.data;
                  // print(selectedInforme.informe);
                  tipos = selectedInforme.tiposImpresion;
                  tipo = tipos[0].tipo;
                  print('nodo seleccionado: $selectedNodeData');
                  print('lista: $tipos');
                }

                for (var param in parametros) {
                  if (param.control == 'T') {
                    _controllers[param.parametro] = TextEditingController();
                  }
                }
                setState(() {
                  selectedNodeData = item.data;
                });
                if(item.data.objetoArbol == 'informe' && item.children.isEmpty){
                  router.pop();
                }
              },
              onTreeReady: (controller) {
                _controller = controller;
                //if (expandChildrenOnReady) controller.expandAllChildren(sampleTree);
              },
              builder: (context, node) => Card(
                color: colors.tertiary,
                child: 
                node.data.objetoArbol == 'informe' ?
                ListTile(
                  title: Text(node.key),
                  leading: Icon(Icons.file_copy_outlined, color: colors.primary,),
                ) :
                ListTile(
                  title: Text(node.key),
                )
                
              ),
            ),
          ),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          if(!generandoInforme) ... [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Text('Parametros del informe: $nombreInforme'),
                  Divider(
                    color: colors.primary,
                    endIndent: 20,
                    indent: 20,
                  ),
                  if (selectedNodeData != null) ...[
                    if(parametros.isNotEmpty)...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.builder(
                            itemCount: parametros.length,
                            itemBuilder: (context, i) {
                              var parametro = parametros[i];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      if (parametro.control == 'D') {
                                        await _selectDate(context, parametro.parametro, parametro.tipo, parametro);
                                        print(parametro.parametro);
                                      } else if(parametro.control == 'L'){
                                        final cliente = await showSearch(
                                          context: context, 
                                          delegate: ParametroClientSearchDelegate('Buscar cliente', historial, parametro.informeId, parametro.parametroId, parametro.dependeDe, parametros)
                                        );
                                        if(cliente != null) {
                                          parametro.valor = cliente.id.toString();
                                          parametro.valorAMostrar = cliente.descripcion;
                                          setState(() {});
                                          
                                        } else{
                                          parametro.valor = '';
                                          parametro.valorAMostrar = '';
                                        }
                                      } else {
                                        await _showPopup(context, parametro);
                                        print(parametro.valor);
                                        print(parametro.valorAMostrar);
                                      }
                                    },
                                    
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: Text(parametro.obligatorio == 'S' ? '* ${parametro.parametro}': parametro.parametro, 
                                        textAlign: TextAlign.center
                                      ),
                                    ),
                                  ),
                                  Text(parametro.comparador,),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Text(parametro.valorAMostrar.toString(), textAlign: TextAlign.center)
                                  )
                                ],
                              );
                            }
                          ),
                        ),
                      ),
                      if(selectedNodeData.objetoArbol == 'informe')...[
                        const Spacer(),
                        const Center(
                          child: Text('Seleccione formato de generacion del Informe'),
                        ),
                        
                        const SizedBox(height: 5,),
                        Center(
                          child:SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: CustomDropdownFormMenu(
                              value: tipos[0],
                              isDense: true,
                              items: tipos.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.descripcion),
                                );
                              }).toList(),
                              onChanged: (value) {
                                tipo = (value as TiposImpresion).tipo;
                              },
                              
                            ),
                          ) ,
                        ),
                        const SizedBox(height: 20,),
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(color: colors.primary)),
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: InkWell(
                            onTap: () async {
                              int contador = 0;
                              bool encontreVacios = false;
                              while (contador < parametros.length && !encontreVacios){
                                Parametro parametro = parametros[contador];
                                if (parametro.obligatorio == 'S' && parametro.valor == ''){
                                  encontreVacios = true;
                                }
                                contador++;
                              }
                              if(!encontreVacios){
                                await postInforme(selectedInforme);
                                await generarInformeCompleto(context);
                                informeGeneradoEsS = false;
                                setState(() {});
                                tipo = tipos[0].tipo;
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hay campos obligatorios sin completar'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save,
                                  color: colors.primary,
                                ),
                                Text(
                                  'Generar Informe',
                                  style: TextStyle(color: colors.primary),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]
                    ]
                  ],
                ],
              ),
            ),
          ]else... [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                      strokeWidth: 5,
                    ),
                  ),
                  const Text('Generando Informe, espere por favor.'),
                  TextButton(
                    onPressed: () async {
                      await InformesServices().patchInforme(context, reporte, 'D', token);
                      generandoInforme = false;
                      setState(() {});
                    }, 
                    child: const Text('Cancelar'))
                ],
              ),
            )
          ]
        ]
      ),
    );
  }

  Future<void> generarInformeCompleto(BuildContext context) async {
    int contador = 0;
    generandoInforme = true;
    
    setState(() {});
    while (contador < 15 && informeGeneradoEsS == false && generandoInforme){
      print(contador);
      
      reporte = await InformesServices().getReporte(context, rptGenId, token);

      if(reporte.generado == 'S'){
        informeGeneradoEsS = true;
        await abrirUrl(reporte.archivoUrl, token);
        generandoInforme = false;
        
      }else{
        await Future.delayed(const Duration(seconds: 1));
      }
      contador++;
    }
    if(informeGeneradoEsS != true && generandoInforme){
      await popUpInformeDemoro(context);
      
      print('informe demoro en generarse');
    }
    
  }

  Future<void> popUpInformeDemoro(BuildContext context) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Su informe esta tardando demasiado en generarse, quiere seguir esperando?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                generandoInforme = false;
                await InformesServices().patchInforme(context, reporte, 'D', token);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('No'),
            ),
            TextButton(
              child: const Text('Si'),
              onPressed: () async {
                Navigator.of(context).pop();
                print('dije SI');
                await generarInformeInfinite(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> generarInformeInfinite(BuildContext context) async {
    
    generandoInforme = true;
    
    while (informeGeneradoEsS == false){
      reporte = await InformesServices().getReporte(context, rptGenId, token);
      if(reporte.generado == 'S'){
        informeGeneradoEsS = true;
        await abrirUrl(reporte.archivoUrl, token);
        generandoInforme = false;
      }else{
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    setState(() {});

  }



  void generarInformePopup(BuildContext context, dynamic informe) {
    print(selectedNodeData);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccione un forma de impresion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 370,
                child: CustomDropdownFormMenu(
                  items: tipos.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e.descripcion),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tipo = (value as TiposImpresion).tipo;
                  },
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                router.pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              child: const Text('Generar'),
              onPressed: () async {
                await postInforme(informe);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPopup(BuildContext context, Parametro parametro,) async {
    if (parametro.control == 'T') {
      _controllers[parametro.parametro] = TextEditingController();
    }
    if (parametro.sql != '') {
      parametrosValues = await InformesServices().getParametrosValues(context, token, parametro.informeId, parametro.parametroId, '', '', parametro.dependeDe.toString(), parametros);
    }
    if (parametro.control == 'T' && parametro.tipo == 'N') {
      maskFormatter = MaskTextInputFormatter(mask: '###############', filter: { "#": RegExp(r'[0-9]') });
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(parametro.parametro),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (parametro.control == 'C') ...[
                SizedBox(
                  width: 300,
                  child: DropdownSearch(
                    items: parametrosValues,
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchDelay: Duration.zero
                    ),
                    onChanged: (value) {
                      parametro.valor = (value as ParametrosValues).id.toString();
                      parametro.valorAMostrar = (value).descripcion;
                    },
                  )
                ),
              ] else if (parametro.control == 'T') ...[
                SizedBox(
                  width: 370,
                  child: CustomTextFormField(
                    controller: _controllers[parametro.parametro],
                    hint: parametro.parametro,
                    mascara: parametro.tipo == 'N' ? [maskFormatter] : [],
                    maxLines: 1,
                    onFieldSubmitted: (value) async {
                      bool existe = false;
                      if (_controllers[parametro.parametro]?.text != '' && parametro.control == 'T') {
                        if(parametro.control == 'T' && parametro.tieneLista == 'S'){
                          existe = await InformesServices().getExisteParametro(context, token, parametro.informeId, parametro, _controllers[parametro.parametro]?.text);
                          if(existe){
                            parametro.valor = _controllers[parametro.parametro]?.text;
                            parametro.valorAMostrar = _controllers[parametro.parametro]?.text;
                          }
                        }
                      }else{
                        router.pop();
                      }
                      setState(() {});
                    },
                  ),
                )
              ]
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                router.pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                bool existe = false;
                if (_controllers[parametro.parametro]?.text != '' && parametro.control == 'T') {
                  if(parametro.control == 'T' && parametro.tieneLista == 'S'){
                    existe = await InformesServices().getExisteParametro(context, token, parametro.informeId, parametro, _controllers[parametro.parametro]?.text);
                    if(existe){
                      parametro.valor = _controllers[parametro.parametro]?.text;
                      parametro.valorAMostrar = _controllers[parametro.parametro]?.text;
                    }
                  }
                }else{
                  router.pop();
                }
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, String title, String tipo, Parametro parametro) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        if (tipo == 'D') {
          parametro.valor = DateFormat('yyyy-MM-dd HH:mm:ss.SSS', 'es').format(DateTime(picked.year, picked.month, picked.day, 0,0,0,0));
          parametro.valorAMostrar = DateFormat('y/M/d', 'es').format(picked);
        } else if (tipo == 'Dd') {
          parametro.valor = DateFormat('yyyy-MM-dd HH:mm:ss.SSS', 'es').format(DateTime(picked.year, picked.month, picked.day, 0,0,0,0));
          parametro.valorAMostrar = DateFormat('y/M/d', 'es').format(picked);
        } else if (tipo == 'Dh') {
          parametro.valor = DateFormat('yyyy-MM-dd HH:mm:ss.SSS', 'es').format(DateTime(picked.year, picked.month, picked.day, 23,59,59,0));
          parametro.valorAMostrar = DateFormat('y/M/d', 'es').format(picked);
        }
      });
    }
  }

  TreeNode convertInformesToTreeNode(List<Informe> informes) {
    TreeNode root = TreeNode.root();
    for (int i = 0; i < informes.length; i++) {
      var informe = informes[i];
      TreeNode node = TreeNode(
        key: informe.nombre,
        data: informe,
      );
      node.addAll(_convertInformeHijosToTreeNode(informe.hijos, '${informe.objetoArbol}-${informe.nombre}'));
      root.add(node);
    }
    return root;
  }

  List<TreeNode> _convertInformeHijosToTreeNode(List<InformeHijo> hijos, String parentKey) {
    List<TreeNode> nodes = [];
    for (int i = 0; i < hijos.length; i++) {
      var hijo = hijos[i];
      TreeNode node = TreeNode(
        key: hijo.objetoArbol == 'informe' ? '${hijo.informe}' : '${hijo.nombre}',
        data: hijo,
      );
      node.addAll(_convertHijoHijosToTreeNode(hijo.hijos, '${hijo.objetoArbol}-${hijo.nombre}'));
      nodes.add(node);
    }
    return nodes;
  }

  List<TreeNode> _convertHijoHijosToTreeNode(List<HijoHijo> hijos, String parentKey) {
    List<TreeNode> nodes = [];
    for (int i = 0; i < hijos.length; i++) {
      var hijo = hijos[i];
      TreeNode node = TreeNode(
        key: hijo.informe,
        data: hijo,
      );
      node.addAll(_convertHijoHijosToTreeNode(hijo.hijos, '${hijo.objetoArbol}-${hijo.informe}'));
      nodes.add(node);
    }
    return nodes;
  }

  postInforme(dynamic informe) async{
    await InformesServices().postGenerarInforme(context, informe, parametros, tipo, token);
    rptGenId = context.read<OrdenProvider>().rptGenId;
  }

}
