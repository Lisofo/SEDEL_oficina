// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/ubicacion.dart';

class UbicacionesServices {
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/ordenes/';

  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
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
      },
    );
  }

  Future getUbicaciones(BuildContext context, int tecnicoId, String fechaDesde, String fechaHasta, String token) async {
    String link = apiLink += 'ubicaciones?tecnicoId=$tecnicoId&fechaDesde=$fechaDesde&fechaHasta=$fechaHasta';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> ubicacionList = resp.data;

      return ubicacionList.map((obj) => Ubicacion.fromJson(obj)).toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }
}
