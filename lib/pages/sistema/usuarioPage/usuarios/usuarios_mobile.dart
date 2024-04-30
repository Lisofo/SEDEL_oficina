// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class UsuariosMobile extends StatefulWidget {
  const UsuariosMobile({super.key});

  @override
  State<UsuariosMobile> createState() => _UsuariosMobileState();
}

class _UsuariosMobileState extends State<UsuariosMobile> {
  List<Usuario> usuarios = [];
  final _userServices = UserServices();
  final _apellidoController = TextEditingController();
  final _loginTextController = TextEditingController();
  final _nombreController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    print('pantalla usuarios');
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Usuarios',
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.95,
          child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Login: '),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Nombre: '),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Apellido: '),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
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
                  const Spacer(),
                  BottomNavigationBar(
                    currentIndex: buttonIndex,
                    onTap: (index) async{   
                      buttonIndex = index;
                      switch (buttonIndex){
                        case 0: 
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedUsuario();
                          router.push('/editUsuarios');
                        case 1:
                          await buscar(context, token);
                          router.pop();
                        break;
                        
                      }  
                    },
                    showUnselectedLabels: true,
                    selectedItemColor: colors.primary,
                    unselectedItemColor: Colors.grey,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_comment_outlined),
                        label: 'Agregar Usuario',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: 'Buscar'
                  ),
                ],
              ),
                  
                ],
              ),
            ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
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
                        backgroundColor: colors.primary,
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
          ),
          ]
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
