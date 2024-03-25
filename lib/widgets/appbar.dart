// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class AppBarDesign extends StatefulWidget implements PreferredSizeWidget {
  late String titulo;

  AppBarDesign({super.key, required this.titulo});

  @override
  State<AppBarDesign> createState() => _AppBarDesignState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _AppBarDesignState extends State<AppBarDesign> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colors.primary,
      title: Text(
        widget.titulo,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ))
      ],
    );
  }
}
