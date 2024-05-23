import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/informes.dart';
import 'package:sedel_oficina_maqueta/models/informes_values.dart';
import 'package:sedel_oficina_maqueta/models/parametro.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/search/parametro_cliente_values.dart';
import 'package:sedel_oficina_maqueta/services/informes_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

class InformesDesktop extends StatefulWidget {
  const InformesDesktop({super.key});

  @override
  State<InformesDesktop> createState() => _InformesDesktopState();
}

class _InformesDesktopState extends State<InformesDesktop> {
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
  late MaskTextInputFormatter maskFormatter;

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Informes'),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
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
                }
                for (var param in parametros) {
                  if (param.control == 'T') {
                    _controllers[param.parametro] = TextEditingController();
                  }
                }
                setState(() {
                  selectedNodeData = item.data; // Actualizar los datos del nodo seleccionado
                });
              },
              onTreeReady: (controller) {
                _controller = controller;
                if (expandChildrenOnReady) controller.expandAllChildren(sampleTree);
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
          VerticalDivider(
            color: colors.secondary,
            width: 1,
          ),
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
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.builder(
                          itemCount: parametros.length,
                          itemBuilder: (context, i) {
                            var parametro = parametros[i];
                            return Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (parametro.control == 'D') {
                                      await _selectDate(context, parametro.parametro, parametro.tipo, parametro);
                                      print(parametro.parametro);
                                    } else if(parametro.control == 'L'){
                                      final cliente = await showSearch(
                                        context: context, 
                                        delegate: ParametroClientSearchDelegate('Buscar cliente', historial, parametro.informeId, parametro.parametroId)
                                      );
                                      if(cliente != null) {
                                        setState(() {
                                          parametro.valor = cliente.descripcion;
                                        });
                                      } else{
                                        parametro.valor = '';
                                      }
                                    } else {
                                      await _showPopup(context, parametro);
                                      print(parametro.valor);
                                    }
                                  },
                                  child: Text(parametro.parametro),
                                ),
                                const SizedBox(width: 30,),
                                Text(parametro.comparador),
                                const SizedBox(width: 30,),
                                // if(parametro.parametro == 'Orden de Trabajo')...[
                                //   Text(campoOrdenTrabajo)
                                // ] else if (parametro.parametro == 'Id de Revision')...[
                                //   Text(campoIdRevision)
                                // ] else if(parametro.parametro == 'Cliente')...[
                                //   Text(campoCliente.descripcion)
                                // ] else if(parametro.parametro == 'Plaga Objetivo')...[
                                //   Text(campoPlagaObjetivo.descripcion)
                                // ] else if (parametro.parametro == 'Fecha Hasta')...[
                                //   Text(campoFechaHasta)
                                // ]
                                Text(parametro.valor.toString())
                              ],
                            );
                          }
                        ),
                      ),
                    ),
                    if(selectedNodeData.objetoArbol == 'informe')...[
                      const Spacer(),
                      BottomNavigationBar(
                        showUnselectedLabels: true,
                        selectedItemColor: colors.primary,
                        unselectedItemColor: colors.primary,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.save_as),
                            label: 'Guardar',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.save),
                            label: 'Generar informe',
                          ),
                        ],
                      ),
                    ]
                  ]
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPopup(BuildContext context, Parametro parametro,) async {
    if (parametro.control == 'T') {
      _controllers[parametro.parametro] = TextEditingController();
    }
    if (parametro.sql != '') {
      parametrosValues = await InformesServices().getParametrosValues(context, token, parametro.informeId, parametro.parametroId, '', '');
    }
    if (parametro.control == 'T' && parametro.tipo == 'N') {
      maskFormatter = MaskTextInputFormatter(mask: '########', filter: { "#": RegExp(r'[0-9]') });
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
                  width: 370,
                  child: CustomDropdownFormMenu(
                    items: parametrosValues.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.descripcion),
                      );
                    }).toList(),
                    onChanged: (value) {
                      parametro.valor = (value as ParametrosValues).descripcion;
                    },
                  ),
                )
              ] else if (parametro.control == 'T') ...[
                SizedBox(
                  width: 370,
                  child: CustomTextFormField(
                    controller: _controllers[parametro.parametro],
                    hint: parametro.parametro,
                    mascara: parametro.tipo == 'N' ? [maskFormatter] : [],
                    maxLines: 1,
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
              onPressed: () {
                if (_controllers[parametro.parametro]?.text != '' && parametro.control == 'T') {
                  parametro.valor = _controllers[parametro.parametro]?.text;
                }
                router.pop();
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
          parametro.valor = DateFormat('d/M/y', 'es').format(picked);
        } else if (tipo == 'Dd') {
          parametro.valor = DateFormat('d/M/y', 'es').format(picked);
        } else if (tipo == 'Dh') {
          parametro.valor = DateFormat('d/M/y', 'es').format(picked);
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

}