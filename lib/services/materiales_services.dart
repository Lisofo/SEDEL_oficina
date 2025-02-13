// ignore_for_file: avoid_print, use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/manuales_materiales.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/materialesTPI.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';

class MaterialesServices {
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/materiales/';
  int? statusCode;

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

  final _dio = Dio();
  
  Future<int?> getStatusCode () async {
    return statusCode;
  }

  Future<void> resetStatusCode () async {
    statusCode = null;
  }
  
  Future getMaterialById(BuildContext context, String id, String token) async {
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

  Future getMateriales(BuildContext context, String descripcion, String codMaterial, String token) async {
    String link = "$apiLink?sort=descripcion";
    bool yaTieneFiltro = true;
    if (descripcion != '') {
      link += '&descripcion=$descripcion';
      yaTieneFiltro = true;
    }
    if (codMaterial != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'codMaterial=$codMaterial';
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

  Future putMaterial(BuildContext context, Materiales material, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link += material.materialId.toString(),
        data: material.toMap(),
        options: Options(
          method: 'PUT', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        showDialogs(context, 'Material actualizado correctamente', false, false);
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

  Future postMaterial( BuildContext context, Materiales material, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        data: material.toMap(),
        options: Options(
          method: 'POST', 
          headers: headers
        )
      );

      statusCode = 1;
      material.materialId = resp.data['materialId'];

      if (resp.statusCode == 201) {
        showDialogs(context, 'Material creado correctamente', false, false);
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

  Future deleteMaterial(BuildContext context, Materiales material, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link += material.materialId.toString(),
        options: Options(
          method: 'DELETE', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        showDialogs(context, 'Material borrado correctamente', true, true);
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

  Future getLotes(BuildContext context, int materialId, bool conEstado, String token) async {
    String link = conEstado ? '${apiUrl}api/v1/materiales/$materialId/lotes?estado=A' : '${apiUrl}api/v1/materiales/$materialId/lotes';

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

  Future postLote(BuildContext context, int materialId, Lote lote, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/lotes';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: lote.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 201){
        lote.materialLoteId = resp.data["materialLoteId"];
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

  Future putLote(BuildContext context, int materialId, Lote lote, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/lotes/${lote.materialLoteId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: lote.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 200){
        
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

  Future deleteLote(BuildContext context, int materialId, Lote lote, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/lotes/${lote.materialLoteId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'Delete',
          headers: headers,
        ),
      );

      statusCode = 1;
      if(resp.statusCode == 204){
        
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

  Future getMetodosAplicacion(BuildContext context,String descripcion, String codMetodoAplicacion, String token) async {
    String link = '${apiUrl}api/v1/metodos-aplicacion/?sort=descripcion';
    String linkFiltrado = link;
    bool yaTieneFiltro = true;
    if (descripcion != '') {
      linkFiltrado += '&descripcion=$descripcion';
      yaTieneFiltro = true;
    }
    if (codMetodoAplicacion != '') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'codMetodoAplicacion=$codMetodoAplicacion';
      yaTieneFiltro = true;
    }


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

  Future postMetodo( BuildContext context, MetodoAplicacion metodo, String token) async {
    try {
      String link = '${apiUrl}api/v1/metodos-aplicacion/';
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        data: metodo.toMap(),
        options: Options(
          method: 'POST', 
          headers: headers
        )
      );


      statusCode = 1;
      if (resp.statusCode == 201) {
        metodo.metodoAplicacionId = resp.data['metodoAplicacionId'];
        showDialogs(context, 'Metodo creado correctamente', false, false);
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

  Future putMetodo( BuildContext context, MetodoAplicacion metodo, String token) async {
    try {
      String link = '${apiUrl}api/v1/metodos-aplicacion/${metodo.metodoAplicacionId}';
      var headers = {'Authorization': token};
      var data = metodo.toMap();
      print(data);

      final resp = await _dio.request(
        link,
        data: metodo.toMap(),
        options: Options(
          method: 'PUT', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        showDialogs(context, 'Metodo editado correctamente', false, false);
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

  Future deleteMetodo( BuildContext context, MetodoAplicacion metodo, String token) async {
    try {
      String link = '${apiUrl}api/v1/metodos-aplicacion/${metodo.metodoAplicacionId}';
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE', 
          headers: headers
        )
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        showDialogs(context, 'Metodo borrado correctamente', true, true);
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

  Future postRevisionMaterial(BuildContext context, Orden orden, List<int> plagasIds, RevisionMaterial revisionMaterial, int revisionId, String token) async {
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales';
    var data = ({
      "idsPlagas": plagasIds,
      "comentario": "",
      "cantidad": revisionMaterial.cantidad,
      "idMaterialLote": revisionMaterial.lote.materialLoteId == 0 ? null : revisionMaterial.lote.materialLoteId,
      "idMetodoAplicacion": revisionMaterial.metodoAplicacion.metodoAplicacionId,
      "ubicacion": revisionMaterial.ubicacion,
      "areaCobertura": revisionMaterial.areaCobertura,
      "idMaterial": revisionMaterial.material.materialId
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
        // showDialogs(context, 'Material borrado', true, false);
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

  Future getMaterialesXTPI(BuildContext context, TipoPtosInspeccion tPI, String token) async {
    String link = '${apiUrl}api/v1/tipos/puntos/${tPI.tipoPuntoInspeccionId}/materiales?sort=descripcion';

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

  Future getDetalles(BuildContext context, int materialId, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/detalles';

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
      final List<dynamic> detallesList = resp.data;

      return detallesList.map((obj) => MaterialDetalles.fromJson(obj)).toList();
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

  Future postDetalle(BuildContext context, int materialId, MaterialDetalles detalle, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/detalles';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: detalle.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 201){
        detalle.materialDetId = resp.data["materialDetId"];
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

  Future putDetalle(BuildContext context, int materialId, MaterialDetalles detalle, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/detalles/${detalle.materialDetId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: detalle.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 200){
        
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

  Future deleteDetalle(BuildContext context, int materialId, MaterialDetalles detalle, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/detalles/${detalle.materialDetId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'Delete',
          headers: headers,
        ),
      );

      statusCode = 1;
      if(resp.statusCode == 204){
        
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
  
  Future getHabilitaciones(BuildContext context, int materialId, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/habilitaciones';

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
      final List<dynamic> habilitacionesList = resp.data;

      return habilitacionesList.map((obj) => MaterialHabilitacion.fromJson(obj)).toList();
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

  Future postHabilitacion(BuildContext context, int materialId, MaterialHabilitacion habilitacion, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/habilitaciones';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: habilitacion.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 201){
        habilitacion.materialHabId = resp.data["materialHabId"];
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

  Future putHabilitacion(BuildContext context, int materialId, MaterialHabilitacion habilitacion, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/habilitaciones/${habilitacion.materialHabId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: habilitacion.toMap()
      );

      statusCode = 1;
      if(resp.statusCode == 200){
        
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

  Future deleteHabilitacion(BuildContext context, int materialId, MaterialHabilitacion habilitacion, String token) async {
    String link = '${apiUrl}api/v1/materiales/$materialId/habilitaciones/${habilitacion.materialHabId}';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'Delete',
          headers: headers,
        ),
      );

      statusCode = 1;
      if(resp.statusCode == 204){
        
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

  Future getManualesMateriales(BuildContext context, int id, String token) async {
    String link = apiLink += '$id/manuales';
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

      return materialList.map((obj) => ManualesMateriales.fromJson(obj)).toList();
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

  Future postManualesMateriales(BuildContext context, int id, String token, Uint8List? manual, String? fileName, String md5) async {
    String link = apiLink += '$id/manuales';
    List<String> listaMd5 = [];
    listaMd5.add(md5);
    try {
      var headers = {'Authorization': token};
      var formData = FormData.fromMap({
        'manuales': MultipartFile.fromBytes(manual as List<int>, filename: fileName),
        'manualesMD5': jsonEncode(listaMd5),
      });
      print(formData);
      var resp = await _dio.post(
        link,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        showDialogs(context, 'PDF subido', false, false);
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

  Future deleteManualesMateriales(BuildContext context, int id, String token, String? fileName) async {
    String link = apiLink += '$id/manuales/$fileName';
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
        showDialogs(context, 'PDF borrado', true, false);
      }
      return;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if (e.response!.statusCode == 403) {
              showErrorDialog(context, 'Error: ${responseData['message']}');
            } else {
              final errors = responseData['errors'] as List<dynamic>?; // Cambio aquí
              if (errors != null) {
                final errorMessages = errors.map((error) {
                  return "Error: ${error['message']}";
                }).toList();
                showErrorDialog(context, errorMessages.join('\n'));
              } else {
                showErrorDialog(context, 'Error: ${e.response!.data}');
              }
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

  Future putRevisionMaterial(BuildContext context, Orden orden, List<int> plagasIds, RevisionMaterial revisionMaterial, int revisionId, String token) async {
    
    String link = '${apiUrl}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/materiales/${revisionMaterial.otMaterialId}';
    var data = ({
      "idsPlagas": plagasIds,
      "comentario": "",
      "cantidad": revisionMaterial.cantidad,
      "idMaterialLote": revisionMaterial.lote.materialLoteId == 0 ? null : revisionMaterial.lote.materialLoteId,
      "idMetodoAplicacion": revisionMaterial.metodoAplicacion.metodoAplicacionId,
      "ubicacion": revisionMaterial.ubicacion,
      "areaCobertura": revisionMaterial.areaCobertura,
      "idMaterial": revisionMaterial.material.materialId
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
        } 
      } 
    }
  }
}
