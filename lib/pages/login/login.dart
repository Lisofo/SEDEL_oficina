import 'package:flutter/material.dart';
import 'login_desktop.dart';
import 'login_mobile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const LoginMobile();
          } else if (constraints.maxWidth > 900) {
            return const LoginDesktop();
          }
          return const LoginDesktop();
        },
      )),
    );
  }
}
