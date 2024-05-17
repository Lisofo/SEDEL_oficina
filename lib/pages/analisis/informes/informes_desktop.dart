import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/informes.dart';
import 'package:sedel_oficina_maqueta/models/parametro.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/informes_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
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
  late String campoCliente = 'Cliente';
  late String campoPlagaObjetivo = 'Plaga Objetivo';
  late String campoFecha = 'Fecha';
  late String campoFechaDesde = 'Fecha desde';
  late String campoFechaHasta = 'Fecha hasta';
  late String campoOrdenTrabajo = 'Orden de trabajo';
  late String campoIdRevision = 'Id de Revision';

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
                child: ListTile(
                  title: Text(node.key),
                  // subtitle: Text('Level ${node.level}'),
                ),
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
                const Text('Detalles del nodo seleccionado:'),
                Divider(
                  color: colors.primary,
                  endIndent: 20,
                  indent: 20,
                ),
                if (selectedNodeData != null) ...[
                  // if (selectedNodeData is Informe) ...[
                  //   Text('Nombre: ${selectedNodeData.nombre}'),
                  //   Text('Objeto Arbol: ${selectedNodeData.objetoArbol}'),
                  //   Text('Rol: ${selectedNodeData.rol}'),
                  //   Text('Sistema: ${selectedNodeData.sistema}'),
                  // ] else if (selectedNodeData is InformeHijo) ...[
                  //   Text('Nombre: ${selectedNodeData.nombre ?? ''}'),
                  //   Text('Objeto Arbol: ${selectedNodeData.objetoArbol}'),
                  //   Text('Informe ID: ${selectedNodeData.informeId}'),
                  //   Text('Archivo: ${selectedNodeData.archivo ?? ''}'),
                  //   // Agrega más campos si es necesario
                  // ] else if (selectedNodeData is HijoHijo) ...[
                  //   Text('Informe: ${selectedNodeData.informe}'),
                  //   Text('Objeto Arbol: ${selectedNodeData.objetoArbol}'),
                  //   Text('Informe ID: ${selectedNodeData.informeId}'),
                  //   Text('Archivo: ${selectedNodeData.archivo}'),
                  //   // Agrega más campos si es necesario
                  // ],
                  if(parametros.isNotEmpty)...[
                    SizedBox(
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.builder(
                          itemCount: parametros.length,
                          itemBuilder: (context, i) {
                            var parametro = parametros[i];
                            return Row(
                              children: [
                                TextButton(onPressed: (){}, child: Text(parametro.parametro)),
                                const SizedBox(width: 30,),
                                Text(parametro.comparador),
                                const SizedBox(width: 30,),
                                if(parametro.parametro == 'Orden de Trabajo')...[
                                  Text(campoOrdenTrabajo)
                                ] else if (parametro.parametro == 'Id de Revision')...[
                                  Text(campoIdRevision)
                                ] else if(parametro.parametro == 'Cliente')...[
                                  Text(campoCliente)
                                ] else if(parametro.parametro == 'Plaga Objetivo')...[
                                  Text(campoPlagaObjetivo)
                                ] else if (parametro.parametro == 'Fecha Hasta')...[
                                  Text(campoFechaHasta)
                                ]
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
                        unselectedItemColor: Colors.grey,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.save_as),
                            label: 'Guardar',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.place),
                            label: 'Puntos de inspeccion',
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
}