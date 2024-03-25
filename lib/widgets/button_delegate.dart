import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

import '../models/cliente.dart';
import '../search/client_delegate.dart';

class ButtonDelegate extends StatefulWidget {
  final Color colorSeleccionado;
  final String nombreProvider;

  const ButtonDelegate(
      {super.key, required this.colorSeleccionado, required this.nombreProvider});

  @override
  State<ButtonDelegate> createState() => _ButtonDelegateState();
}

class _ButtonDelegateState extends State<ButtonDelegate> {
  late Cliente selectedCliente = Cliente.empty();
  List<Cliente> historial = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          child: selectedCliente.nombre == ''
              ? Text(
                  'Seleccione cliente',
                  style: TextStyle(color: widget.colorSeleccionado),
                )
              : Text(
                  selectedCliente.nombre,
                  style: TextStyle(color: widget.colorSeleccionado),
                ),
          onPressed: () async {
            final cliente = await showSearch(
                context: context,
                delegate: ClientSearchDelegate(
                    'Buscar Cliente', historial, widget.nombreProvider));
            if (cliente != null) {
              setState(() {
                selectedCliente = cliente;
                final int clienteExiste = historial
                    .indexWhere((element) => element.nombre == cliente.nombre);
                if (clienteExiste == -1) {
                  historial.insert(0, cliente);
                }
              });
            } else {
              setState(() {
                selectedCliente = Cliente.empty();
              });
            }
          },
        ),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          tooltip: 'Limpiar filtro cliente',
          onPressed: () {
            Provider.of<OrdenProvider>(context, listen: false)
                .clearSelectedCliente(widget.nombreProvider);
            setState(() {
              selectedCliente = Cliente.empty();
            });
          },
          icon: Icon(Icons.clear, color: widget.colorSeleccionado,)
        )
      ],
    );
  }
}
