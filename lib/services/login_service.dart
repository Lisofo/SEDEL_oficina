// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

class LoginServices {
  int? statusCode;
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/auth/login';

  Future<void> login(String login, password, BuildContext context) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"login": login, "password": password});
    var dio = Dio();
    String link = apiLink;
    try {
      var response = await dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      statusCode = response.statusCode;

      if (statusCode == 200) {
        print(response.data['token']);
        print(response.data['name']);
        Provider.of<OrdenProvider>(context, listen: false).setToken(response.data['token']);
        Provider.of<OrdenProvider>(context, listen: false).setUsername(response.data['name']);
      } else { 
        print(response.statusMessage);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<int?> getStatusCode() async {
    return statusCode;
  }
}
