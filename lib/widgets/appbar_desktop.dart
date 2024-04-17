// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class AppBarDesktop extends StatefulWidget implements PreferredSizeWidget {
  late String titulo;

  AppBarDesktop({super.key, required this.titulo});

  @override
  State<AppBarDesktop> createState() => _AppBarDesktopState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _AppBarDesktopState extends State<AppBarDesktop> {
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
