import 'package:flutter/material.dart';

import 'menu_desktop.dart';
import 'menu_mobile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MenuMobile();
          } else if (constraints.maxWidth > 900) {
            return const MenuDesktop();
          }
          return const MenuDesktop();
        },
      )),
    );
  }
} 
