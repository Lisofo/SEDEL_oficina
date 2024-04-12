import 'package:flutter/material.dart';

import 'monitore_mobile.dart';
import 'monitoreo_desktop.dart';

class Monitoreo extends StatefulWidget {
  const Monitoreo({super.key});

  @override
  State<Monitoreo> createState() => _MonitoreoState();
}

class _MonitoreoState extends State<Monitoreo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MonitoreoMobile();
          } else if (constraints.maxWidth > 900) {
            return const MonitoreoDesktop();
          }
          return const MonitoreoDesktop();
        },
      )),
    );
  }
}
