// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/marca.dart';

class MarcaServices{
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/marcas/';
  final _dio = Dio();
  int? statusCode;
  
  static Future<void> showDialogs(BuildContext context, String errorMessage, bool doblePop, bool triplePop) async {
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
                if (doblePop) {
                  Navigator.of(context).pop();
                }
                if (triplePop) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

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

  Future<int?> getStatusCode () async {
    return statusCode;
  }

  Future<void> resetStatusCode () async {
    statusCode = null;
  }
  
  Future getMarca(BuildContext context, String tecnicoId, String desde, String hasta, String token) async {
    bool yaTieneFiltro = false;
    String link = apiLink;
    String linkFiltrado = link;
    
    if (tecnicoId != '' && tecnicoId != '0') {
      linkFiltrado += '?tecnicoId=$tecnicoId';
      yaTieneFiltro = true;
    }
    if (desde != '') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'desde=$desde';
      yaTieneFiltro = true;
    }
    if (hasta != '') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'hasta=$hasta';
      yaTieneFiltro = true;
    }

    print(linkFiltrado);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        linkFiltrado,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> marcaList = resp.data;
      print('print desde el get: ${resp.data[0]["desde"]}');
      var retorno = marcaList.map((obj) => Marca.fromJson(obj)).toList();
      print(retorno.length);
      return retorno;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future putMarca(BuildContext context, Marca marca, String token) async {
    try {
      String link = '$apiLink${marca.marcaId}';
      var headers = {'Authorization': token};
      print(marca.desde.toIso8601String());

      final resp = await _dio.request(
        link,
        data: marca.toMap(),
        options: Options(
          method: 'PUT', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        showDialogs(context, 'Marca actualizada correctamente', false, false);
      }
      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future postMarca(BuildContext context, Marca marca, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        data: marca.toMap(),
        options: Options(
          method: 'POST', 
          headers: headers
        )
      );


      statusCode = 1;
      if (resp.statusCode == 201) {
        marca.marcaId = resp.data['marcaId'];
        showDialogs(context, 'Marca creada correctamente', false, false);
      }

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future deleteMarca(BuildContext context, Marca marca, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link += marca.marcaId.toString(),
        options: Options(
          method: 'DELETE', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        showDialogs(context, 'Marca borrada correctamente', true, true);
      }
      return resp.statusCode;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

}