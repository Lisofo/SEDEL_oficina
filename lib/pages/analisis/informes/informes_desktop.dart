import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/informes.dart';
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
  late List<Informes> informes = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos () async {
    token = context.read<OrdenProvider>().token;
    informes = await InformesServices().getInformes(context, token);
    print(informes.length);
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
            child: Card(
              child: TreeView.simple(
                tree: sampleTree,
                showRootNode: true,
                expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
                  tree: node,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
                indentation: const Indentation(style: IndentStyle.squareJoint),
                onItemTap: (item) {
                  if (kDebugMode) print("Item tapped: ${item.key}");
              
                  if (showSnackBar) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Item tapped: ${item.key}"),
                        duration: const Duration(milliseconds: 750),
                      ),
                    );
                  }
                },
                onTreeReady: (controller) {
                  _controller = controller;
                  if (expandChildrenOnReady) controller.expandAllChildren(sampleTree);
                },
                builder: (context, node) => Card(
                  color: colors.primary,
                  child: ListTile(
                    title: Text("Item ${node.level}-${node.key}"),
                    subtitle: Text('Level ${node.level}'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            child: Column(
              children: [
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
                Text('data'),
              ],
            ),
          )
        ],
      ),
    );
  }

  final sampleTree = TreeNode.root()
  ..addAll([
    TreeNode(key: "0A")..add(TreeNode(key: "0A1A")),
    TreeNode(key: "0C")
      ..addAll([
        TreeNode(key: "0C1A"),
        TreeNode(key: "0C1B"),
        TreeNode(key: "0C1C")
          ..addAll([
            TreeNode(key: "0C1C2A")
              ..addAll([
                TreeNode(key: "0C1C2A3A"),
                TreeNode(key: "0C1C2A3B"),
                TreeNode(key: "0C1C2A3C"),
              ]),
          ]),
      ]),
    TreeNode(key: "0D"),
    TreeNode(key: "0E"),
  ]);
}