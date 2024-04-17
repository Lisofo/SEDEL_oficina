// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class AppBarMobile extends StatefulWidget implements PreferredSizeWidget {
  late String titulo;

  AppBarMobile({super.key, required this.titulo});

  @override
  State<AppBarMobile> createState() => _AppBarMobileState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _AppBarMobileState extends State<AppBarMobile> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colors.primary,
      title: Text(
        widget.titulo,
        style: const TextStyle(color: Colors.white),
      ),
      iconTheme: IconThemeData(color: colors.onPrimary),
      
    );
  }
}
