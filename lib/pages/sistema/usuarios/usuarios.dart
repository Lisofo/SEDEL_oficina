// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<Usuario> usuarios = [];
  final _userServices = UserServices();
  final _apellidoController = TextEditingController();
  final _loginTextController = TextEditingController();
  final _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final token = context.watch<OrdenProvider>().token;
    print('pantalla usuarios');
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesign(
          titulo: 'Usuarios',
        ),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Login: '),
                        const SizedBox(
                          width: 60,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _loginTextController,
                            maxLines: 1,
                            label: 'Login',
                            onFieldSubmitted: (value) async {
                              await buscar(context, token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nombre: '),
                        const SizedBox(
                          width: 45,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _nombreController,
                            maxLines: 1,
                            label: 'Nombre',
                            onFieldSubmitted: (value) async {
                              await buscar(context, token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Apellido: '),
                        const SizedBox(
                          width: 44,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            maxLines: 1,
                            label: 'Apellido',
                            controller: _apellidoController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () async {
                            await buscar(context, token);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 52, 120, 62),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () {
                            Provider.of<OrdenProvider>(context, listen: false)
                                .clearSelectedUsuario();
                            router.push('/editUsuarios');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Agregar usuario',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 52, 120, 62),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 52, 120, 62),
                          child: Text(
                            usuarios[index].usuarioId.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('${usuarios[index].nombre} ${usuarios[index].apellido}'),
                        subtitle: Text(usuarios[index].login),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setUsuario(usuarios[index]);
                          router.push('/editUsuarios');
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> buscar(BuildContext context, String token) async {
    List<Usuario> results = await _userServices.getUsers(
      context, 
      _loginTextController.text,
      _nombreController.text,
      _apellidoController.text,
      token);
    setState(() {
      usuarios = results;
    });
  }
}
