// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/materialesTPI.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';

class MaterialesDiagnosticoServices {
  final _dio = Dio();
  String apiUrl = Config.APIURL;
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

  Future<void> showErrorDialog(BuildContext context, String mensaje) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<int?> getStatusCode () async {
    return statusCode;
  }

  Future<void> resetStatusCode () async {
    statusCode = null;
  }
  
  Future getMateriales(BuildContext context, String token) async {
    String link = '${apiUrl}api/v1/materiales/?enAppTecnico=S&enUso=S';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> materialList = resp.data;

      return materialList.map((obj) => Materiales.fromJson(obj)).toList();
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

  Future getMaterialesXTPI(BuildContext context, TipoPtosInspeccion tPI, String token) async {
    String link = '${apiUrl}api/v1/tipos/puntos/${tPI.tipoPuntoInspeccionId}/materiales';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> materialXPTIList = resp.data;

      return materialXPTIList.map((obj) => MaterialXtpi.fromJson(obj)).toList();
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

  Future getLotes(BuildContext context, int materialId, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/lotes?estado=A';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> lotesList = resp.data;

      return lotesList.map((obj) => Lote.fromJson(obj)).toList();
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

  Future getMetodosAplicacion(BuildContext context, String token) async {
    String link = '${apiUrl}api/v1/metodos-aplicacion/';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> metodosList = resp.data;

      return metodosList.map((obj) => MetodoAplicacion.fromJson(obj)).toList();
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

  Future getRevisionMateriales(BuildContext context, Orden orden, int revisionId, String token) async {
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> revisionMaterialesList = resp.data;

      return revisionMaterialesList.map((obj) => RevisionMaterial.fromJson(obj)).toList();
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

  Future postRevisionMaterial(BuildContext context, Orden orden, RevisionMaterial revisionMaterial, int revisionId, String token) async {
    
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales';
    var data = ({
      "comentario": revisionMaterial.comentario,
      "cantidad": revisionMaterial.cantidad,
      "idMaterial": revisionMaterial.material.materialId,
      "idMaterialLote": null,
      "idMetodoAplicacion": null,
      "ubicacion": null,
      "areaCobertura": null,
      "idsPlagas": []
    });

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        revisionMaterial.otMaterialId = resp.data["otMaterialId"];
        await showDialogs(context, 'Material guardado', true, false);
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

  Future deleteRevisionMaterial(BuildContext context, Orden orden, RevisionMaterial revisionMaterial, int revisionId, String token) async {
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales/${revisionMaterial.otMaterialId}';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        showDialogs(context, 'Material borrado', true, false);
      }
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

  Future putRevisionMaterial(BuildContext context, Orden orden, RevisionMaterial revisionMaterial, int revisionId, String token) async {
    
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales/${revisionMaterial.otMaterialId}';
    var data = ({
      "comentario": revisionMaterial.comentario,
      "cantidad": revisionMaterial.cantidad,
      "idMaterial": revisionMaterial.material.materialId,
      "idMaterialLote": null,
      "idMetodoAplicacion": null,
      "ubicacion": null,
      "areaCobertura": null,
      "idsPlagas": []
    });

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: data,
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        await showDialogs(context, 'Material editado', true, false);
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
}
