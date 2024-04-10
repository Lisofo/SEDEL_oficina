// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sedel_oficina_maqueta/services/login_service.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  late bool isObscured;
  final _formKey = GlobalKey<FormState>();
  final passwordFocusNode = FocusNode();
  final userFocusNode = FocusNode();
    String user = '';
  String pass = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _loginServices = LoginServices();



  @override
  void initState() {
    super.initState();
    isObscured = true;
  }

   @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'images/logo.png',
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido',
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia Sesion en tu cuenta',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 35),
                Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius: BorderRadius.circular(20)),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.person),
                          prefixIconColor:  colors.primary,
                          hintText: 'Ingrese su usuario'),
                          validator: (value) {
                            if (value!.isEmpty || value.trim().isEmpty){
                              return 'Ingrese un usuario valido';
                            }
                            return null;
                          },
                          onSaved:(newValue) => user = newValue!,
                    )
                  ),
                const SizedBox(height: 20),
                Form(
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: isObscured,
                    focusNode: passwordFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(20)),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.lock),
                      prefixIconColor: colors.primary,
                      suffixIcon: IconButton(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        icon: isObscured
                            ? const Icon(
                                Icons.visibility_off,
                                color: Colors.black,
                              )
                            : const Icon(Icons.visibility, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      ),
                      hintText: 'Ingrese su contraseña'),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value.trim().isEmpty) {
                          return 'Ingrese su contraseña';
                        }
                        if (value.length < 6) {
                          return 'Contraseña invalida';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) async {
                        await login(context);
                      },
                      onSaved: (newValue) => pass = newValue!,
                )),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        elevation: MaterialStatePropertyAll(10),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(50),
                                right: Radius.circular(50))))),
                    onPressed: () async{
                      await login(context);
                    },
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> login(BuildContext context) async {
    await _loginServices.login(
      usernameController.text,
      passwordController.text,
      context,
    );

    if (_formKey.currentState?.validate() == true) {
      var statusCode = await _loginServices.getStatusCode();

      if (statusCode == 200) {
        context.push('/menu');
      } else if (statusCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales inválidas. Intente nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
        print('Credenciales inválidas. Intente nuevamente.');
      }
    }
  }




}
