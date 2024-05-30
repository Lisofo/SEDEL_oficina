// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/informes.dart';
import 'package:sedel_oficina_maqueta/models/informes_values.dart';
import 'package:sedel_oficina_maqueta/models/parametro.dart';
import 'package:sedel_oficina_maqueta/models/reporte.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

class InformesServices {
  final _dio = Dio();

  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/informes/';

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

  static Future<void> showDialogs(BuildContext context, String errorMessage, bool doblePop, bool triplePop,) async {
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

  Future getInformes(BuildContext context, String token) async {
    String link = apiLink;
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> informesList = resp.data;

      return informesList.map((obj) => Informe.fromJson(obj)).toList();
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

  Future getReporte(BuildContext context, int reporteId, String token) async {
    String link = '${apiUrl}api/v1/rpts/$reporteId';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final Reporte reporte = Reporte.fromJson(resp.data);
      print(reporte.rptGenId);
      return reporte;

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

  Future patchInforme(BuildContext context, Reporte reporte, String generado, String token) async {
    String link = '${apiUrl}api/v1/rpts/${reporte.rptGenId}';

    try {
      var headers = {'Authorization': token};
      var data = ({"generado": generado});
      var resp = await _dio.request(link,
          options: Options(
            method: 'PATCH',
            headers: headers,
          ),
          data: data);

      return resp;
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

  

  Future getParametros(BuildContext context, String token, int informeId) async {
    String link = '$apiLink$informeId/parametros';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> informesList = resp.data;

      return informesList.map((obj) => Parametro.fromJson(obj)).toList();
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

  Future getExisteParametro(BuildContext context, String token, int informeId, Parametro parametro, String? valor) async {
    String link = '$apiLink$informeId/parametros/${parametro.parametroId}/values/?descripcion=$valor';
    bool existe = false;
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> informesList = resp.data;
      if(resp.statusCode == 200 && informesList.isEmpty){
        showDialogs(context, 'Este valor no es valido para el parametro', false, false);
        return existe;
      }else{
        existe = true;
        router.pop();
        return existe;
      }
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

  Future<List<ParametrosValues>> getParametrosValues(
    BuildContext context, String token, int informeId, int parametroId, String id, String descripcion, String dependeDe, List<Parametro> parametros) async {

    List<String> depende = dependeDe.split(',');
    String link = '$apiLink$informeId/parametros/$parametroId/values';
    
    // Construir parámetros a partir de dependeDe y los valores de la lista parametros
    if (depende.isNotEmpty && depende[0].isNotEmpty) {
      String param = depende.asMap().entries.map((entry) {
        int index = entry.key;
        String valor = entry.value;
        return '$valor=${parametros[index].valor}';
      }).join('&');
      link += '?$param';
    }
  
    // Agregar id a la URL si no está vacío
    bool yaTieneFiltro = link.contains('?');
    if (id.isNotEmpty) {
      link += yaTieneFiltro ? '&id=$id' : '?id=$id';
      yaTieneFiltro = true;
    }
  
    // Agregar descripcion a la URL si no está vacía
    if (descripcion.isNotEmpty) {
      link += yaTieneFiltro ? '&descripcion=$descripcion' : '?descripcion=$descripcion';
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
      final List<dynamic> parametrosValuesList = resp.data;
  
      return parametrosValuesList.map((obj) => ParametrosValues.fromJson(obj)).toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if (e.response!.statusCode == 403) {
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            } else {
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
      return [];
    }
  }

  Future postGenerarInforme( BuildContext context, dynamic informe, List<Parametro> parametros, String tipoImpresion, String token) async {
    String link = '${apiUrl}api/v1/rpts/';
    var headers = {'Authorization': token};
    List<Map<String, String>> param = [];
    for(var i = 0; i< parametros.length; i++){
      param.add({
        'p${i + 1}': parametros[i].valor.toString()
      });
      print(param);
    }
    var data = {
      "informeId": informe.informeId,
      "almacenId": informe.almacenId,
      "tipoImpresion": tipoImpresion,
      "destino": 0,
      "destFileName": null,
      "destImpresora": null,
      "parametros": param
    };
    print(data);
    try {

      final resp = await _dio.request(
        link,
        data: data,
        options: Options(
          method: 'POST', 
          headers: headers
        )
      );

      if (resp.statusCode == 200) {
        print(resp.data["rptGenId"]);
        Provider.of<OrdenProvider>(context, listen: false).setRptId(resp.data["rptGenId"]);
        print(resp.data["rptGenId"]);
        //showDialogs(context, 'Informe generado correctamente', true, false);
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

}