// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sedel_oficina_maqueta/services/login_service.dart';

class LoginDesktop extends StatefulWidget {
  const LoginDesktop({super.key});

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.962,
                width: MediaQuery.of(context).size.width / 2,
                child: Image.asset(
                  'images/logo.png',
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bienvenido',
                        style: GoogleFonts.inter(
                            fontSize: 28,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia Sesion en tu cuenta',
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            color: colors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 35),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: const Icon(Icons.person),
                                      prefixIconColor:
                                          colors.primary,
                                      hintText: 'Ingrese su usuario'),
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        value.trim().isEmpty) {
                                      return 'Ingrese un usuario valido';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) => user = newValue!
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                  controller: passwordController,
                                  obscureText: isObscured,
                                  focusNode: passwordFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: const Icon(Icons.lock),
                                      prefixIconColor:
                                          //const Color.fromARGB(255, 41, 146, 41)
                                          colors.primary,
                                      suffixIcon: IconButton(
                                        padding: const EdgeInsetsDirectional.only(
                                            end: 12.0),
                                        icon: isObscured
                                            ? const Icon(
                                                Icons.visibility_off,
                                                color: Colors.black,
                                              )
                                            : const Icon(Icons.visibility,
                                                color: Colors.black),
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
                                  onSaved: (newValue) => pass = newValue!),
                              const SizedBox(
                                height: 40,
                              ),
                              ElevatedButton(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  elevation: WidgetStatePropertyAll(10),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(50),
                                        right: Radius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  await login(context);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.5),
                                  child: Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
//todo aca
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
