import 'package:flutter/material.dart';

import 'informes_desktop.dart';
import 'informes_mobile.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
    @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const InformesMobile();
          } else if (constraints.maxWidth > 900) {
            return const InformesDesktop();
          }
          return const InformesDesktop();
        },
      )),
    );
  }
}