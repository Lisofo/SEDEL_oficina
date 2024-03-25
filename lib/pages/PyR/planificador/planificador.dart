import 'package:flutter/material.dart';

import 'plan_desktop.dart';
import 'planMobile.dart';

class PlanificadorPage extends StatefulWidget {
  const PlanificadorPage({super.key});

  @override
  State<PlanificadorPage> createState() => _PlanificadorPageState();
}

class _PlanificadorPageState extends State<PlanificadorPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const PlanMobile();
          } else if (constraints.maxWidth > 900) {
            return const PlanDesktop();
          }
          return const PlanDesktop();
        },
      )),
    );
  }
}
