import 'package:flutter/material.dart';

import 'edit_tipos_desktop.dart';
import 'edit_tipos_mobile.dart';


class EditTiposPto extends StatefulWidget {
  const EditTiposPto({super.key});

  @override
  State<EditTiposPto> createState() => _EditTiposPtoState();
}

class _EditTiposPtoState extends State<EditTiposPto> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditTiposPtoMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditTiposPtoDesktop();
          }
          return const EditTiposPtoDesktop();
        },
      )),
    );
  }
}