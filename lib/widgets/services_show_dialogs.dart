// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ServiceShowDialog extends StatelessWidget {
  late String errorMessage;

  ServiceShowDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mensaje'),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
