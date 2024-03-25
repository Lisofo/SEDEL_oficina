// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';

class PlagaObjetivoServices {
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/plagas-objetivo/';

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

  Future getPlagaObjetivoById(BuildContext context, String id, String token) async {
    String link = apiLink;
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link += id,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final PlagaObjetivo plagaObjetivo = PlagaObjetivo.fromJson(resp.data);

      return plagaObjetivo;
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

  Future getPlagasObjetivo(BuildContext context, String descripcion, String codPlagaObjetivo, String token) async {
    String link = apiLink;
    bool yaTieneFiltro = false;
    if (descripcion != '') {
      link += '?descripcion=$descripcion';
      yaTieneFiltro = true;
    }
    if (codPlagaObjetivo != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'codPlaga=$codPlagaObjetivo';
      yaTieneFiltro = true;
    }

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> plagaList = resp.data;

      return plagaList.map((obj) => PlagaObjetivo.fromJson(obj)).toList();
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

  Future putPlagaObjetivo(BuildContext context, PlagaObjetivo plagaObjetivo, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
          link += plagaObjetivo.plagaObjetivoId.toString(),
          data: plagaObjetivo.toMap(),
          options: Options(method: 'PUT', headers: headers));

      if (resp.statusCode == 200) {
        showDialogs(context, 'Plaga actualizada correctamente', false, false);
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

  Future postPlagaObjetivo(BuildContext context, PlagaObjetivo plagaObjetivo, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link,
          data: plagaObjetivo.toMap(),
          options: Options(method: 'POST', headers: headers));

      if (resp.statusCode == 201) {
        showDialogs(context, 'Plaga creada correctamente', false, false);
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

  Future deletePlagaObjetivo(BuildContext context, PlagaObjetivo plagaObjetivo, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
          link += plagaObjetivo.plagaObjetivoId.toString(),
          options: Options(method: 'DELETE', headers: headers));
      if (resp.statusCode == 204) {
        showDialogs(context, 'Cambio hecho correctamente', true, true);
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
}
