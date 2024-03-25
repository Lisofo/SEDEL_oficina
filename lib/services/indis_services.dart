// ignore_for_file: avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/indisponibilidades.dart';

class IndisponibilidadServices {
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/indisponibilidades/';

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

  Future getIndisponibilidadById(BuildContext context, String id, String token) async {
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        apiLink += id,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final Indisponibilidad inidisponibilidad = Indisponibilidad.fromJson(resp.data);

      return inidisponibilidad;
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

  Future getIndisponibilidad( BuildContext context, String comentario, String desde, String hasta, String tipoIndisponibilidadId, String tecnicoId, String clienteId, String token) async {
    bool yaTieneFiltro = false;
    var link = apiLink;
    if (comentario != '') {
      link += '?comentario=$comentario';
      yaTieneFiltro = true;
    }
    if (desde != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'desde=$desde';
      yaTieneFiltro = true;
    }
    if (hasta != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'hasta=$hasta';
      yaTieneFiltro = true;
    }
    if (tipoIndisponibilidadId != '0' && tipoIndisponibilidadId != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'tipoIndisponibilidadId=$tipoIndisponibilidadId';
      yaTieneFiltro = true;
    }
    if (tecnicoId != '' && tecnicoId != '0') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'tecnicoId=$tecnicoId';
      yaTieneFiltro = true;
    }
    if (clienteId != '0' && clienteId != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'clienteId=$clienteId';
      yaTieneFiltro = true;
    }
    print(link);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final List<dynamic> indisList = resp.data;

      return indisList.map((obj) => Indisponibilidad.fromJson(obj)).toList();
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

  Future putIndisponibilidad(BuildContext context,
      Indisponibilidad indisponibilidad, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};
      var xx = indisponibilidad.toMap();
      final resp = await _dio.request(
          link += indisponibilidad.indisponibilidadId.toString(),
          data: indisponibilidad.toMap(),
          options: Options(method: 'PUT', headers: headers));

      if (resp.statusCode == 200) {
        showErrorDialog(context, 'Indisponibilidad actualizada correctamente');
      }

      return;
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

  Future postIndisponibilidad(BuildContext context, Indisponibilidad indisponibilidad, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};
      //var xx = indisponibilidad.toMap();
      final resp = await _dio.request(link,
          data: indisponibilidad.toMap(),
          options: Options(method: 'POST', headers: headers));

      indisponibilidad.indisponibilidadId = resp.data['indisponibilidadId'];

      if (resp.statusCode == 201) {
        showErrorDialog(context, 'Indisponibilidad creada correctamente');
      }

      return;
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

  Future deleteindisponibilidad(BuildContext context, Indisponibilidad indisponibilidad, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
          link += indisponibilidad.indisponibilidadId.toString(),
          options: Options(method: 'DELETE', headers: headers));

      if (resp.statusCode == 204) {
        showDialogs(
            context, 'Indisponibilidad borrada correctamente', true, true);
      }
      return resp.statusCode;
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

  Future getTiposIndisponibilidades(BuildContext context, String token) async {
    String link = apiLink += 'tipos';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final List<dynamic> tiposIndisponibilidades = resp.data;

      return tiposIndisponibilidades.map((obj) => TipoIndisponibilidad.fromJson(obj)).toList();
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
