import 'package:flutter/material.dart';

import 'edit_clientes_desktop.dart';
import 'edit_clientes_mobile.dart';

class EditClientesPage extends StatefulWidget {
  const EditClientesPage({super.key});

  @override
  State<EditClientesPage> createState() => _EditClientesPageState();
}

class _EditClientesPageState extends State<EditClientesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditClientesMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditClientesDesktop();
          }
          return const EditClientesDesktop();
        },
      )),
    );
  }
}
