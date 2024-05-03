import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/lotes/lotes_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/lotes/lotes_mobile.dart';


class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const LotesPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const LotesPageDesktop();
          }
          return const LotesPageDesktop();
        },
      )),
    );
  }
}