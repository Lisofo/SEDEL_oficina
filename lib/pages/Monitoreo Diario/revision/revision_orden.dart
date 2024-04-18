import 'package:flutter/material.dart';

import 'package:sedel_oficina_maqueta/pages/Monitoreo%20Diario/revision/revision_orden_desktop.dart';

import 'package:sedel_oficina_maqueta/pages/Monitoreo%20Diario/revision/revision_orden_mobile.dart';


class RevisionOrdenMain extends StatefulWidget {
  const RevisionOrdenMain({super.key});

  @override
  State<RevisionOrdenMain> createState() => _RevisionOrdenMainState();
}

class _RevisionOrdenMainState extends State<RevisionOrdenMain> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const RevisionOrdenMobile();
          } else if (constraints.maxWidth > 900) {
            return const RevisionOrdenDesktop();
          }
          return const RevisionOrdenDesktop();
        },
      )),
    );
  }
}
