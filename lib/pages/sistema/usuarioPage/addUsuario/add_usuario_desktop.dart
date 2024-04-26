// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import '../../../../widgets/drawer.dart';

class AddUsuarioDesktop extends StatefulWidget {
  const AddUsuarioDesktop({super.key});

  @override
  State<AddUsuarioDesktop> createState() => _AddUsuarioDesktopState();
}

class _AddUsuarioDesktopState extends State<AddUsuarioDesktop> {
  final _userServices = UserServices();
  final _loginController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late Usuario userSeleccionado = context.watch<OrdenProvider>().usuario;
    final token = context.watch<OrdenProvider>().token;

    _loginController.text = userSeleccionado.login;
    _nombreController.text = userSeleccionado.nombre;
    _apellidoController.text = userSeleccionado.apellido;
    _direccionController.text = userSeleccionado.direccion;
    _telefonoController.text = userSeleccionado.telefono;

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Usuarios',),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Login  "),
                      const SizedBox(
                        width: 27,
                      ),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          maxLines: 1,
                          label: 'login',
                          controller: _loginController,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text("Nombre  "),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          label: 'Nombre',
                          controller: _nombreController,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text("Apellido  "),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          label: 'Apellido',
                          controller: _apellidoController,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text("Direccion  "),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          label: 'Direccion',
                          controller: _direccionController,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text("Telefono  "),
                      const SizedBox(
                        width: 4,
                      ),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          label: 'Telefono',
                          controller: _telefonoController,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  if (userSeleccionado.usuarioId != 0) ...[
                    botonesConId(userSeleccionado, context, token)
                  ] else ...[
                    botonesSinId(userSeleccionado, context, token)
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomAppBar botonesConId(Usuario userSeleccionado, BuildContext context, String token) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            CustomButton(
              text: 'Establecer perfiles',
              onPressed: (){
                router.push('/establecerPerfiles');
              },
              tamano: 20,
            ),
            const SizedBox(width: 30,),
            CustomButton(
              onPressed: () {
                router.push('/establecerClientes');
              },
              text: 'Establecer clientes',
              tamano: 20,
            ),
            const SizedBox(width: 30,),
            CustomButton(
              onPressed: () {
                router.push('/editPwdPin');
              },
              text: 'Establecer contraseña',
              tamano: 20,
            ),
            const SizedBox(width: 30,),
            CustomButton(
              onPressed: () {
                userSeleccionado.login = _loginController.text;
                userSeleccionado.nombre = _nombreController.text;
                userSeleccionado.apellido = _apellidoController.text;
                userSeleccionado.direccion = _direccionController.text;
                userSeleccionado.telefono = _telefonoController.text;
                if (userSeleccionado.usuarioId != 0) {
                  _userServices.putUsuario(context, userSeleccionado, token);
                } else {
                  _userServices.postUsuario(context, userSeleccionado, token);
                }
              },
              text: 'Guardar',
              tamano: 20,
            ),
            const SizedBox(width: 30,),
            CustomButton(
              onPressed: () async {
                await borrarUserDialog(context, userSeleccionado, token);
                Navigator.of(context).pop();
              },
              text: 'Eliminar',
              tamano: 20,
            ),
          ]
        )
      )
    );
  }

  BottomAppBar botonesSinId(
      Usuario userSeleccionado, BuildContext context, String token) {
        final colors = Theme.of(context).colorScheme;
    return BottomAppBar(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      elevation: MaterialStatePropertyAll(10),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50))))),
                  onPressed: () async {
                    userSeleccionado.login = _loginController.text;
                    userSeleccionado.nombre = _nombreController.text;
                    userSeleccionado.apellido = _apellidoController.text;
                    userSeleccionado.direccion = _direccionController.text;
                    userSeleccionado.telefono = _telefonoController.text;

                    if (userSeleccionado.usuarioId != 0) {
                      _userServices.putUsuario(
                          context, userSeleccionado, token);
                    } else {
                      await _userServices.postUsuario(
                          context, userSeleccionado, token);
                      setState(() {
                        botonesConId(userSeleccionado, context, token);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(
                      'Guardar',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      elevation: MaterialStatePropertyAll(10),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50))))),
                  onPressed: () async {
                    await borrarUserDialog(context, userSeleccionado, token);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )),
            ])));
  }

  Future<dynamic> borrarUserDialog(BuildContext context, Usuario userSeleccionado, String token) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar accion'),
          content: const Text('Desea borrar el usuario?'),
          actions: [
            TextButton(
                onPressed: () async {
                  router.pop();
                  await _userServices.deleteUser(
                      context, userSeleccionado, token);
                  router.pop(context);
                },
                child: const Text('Borrar')),
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Cancelar'))
          ],
        );
      },
    );
  }
}
