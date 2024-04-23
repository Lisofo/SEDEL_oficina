import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:sedel_oficina_maqueta/widgets/timetable_desktop.dart';

class PlanDesktop extends StatefulWidget {
  const PlanDesktop({super.key});

  @override
  State<PlanDesktop> createState() => _PlanDesktopState();
}

class _PlanDesktopState extends State<PlanDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Planificador',),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const CustomizedTimetableDesktop(),
          )
        ],
      ),
    );
  }
}
