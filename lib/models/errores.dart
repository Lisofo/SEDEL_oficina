import 'dart:convert';

ErrorApi errorFromJson(String str) => ErrorApi.fromJson(json.decode(str));

String errorToMap(ErrorApi data) => json.encode(data.toMap());

class ErrorApi {
  List<ErrorElement> errors;

  ErrorApi({
    required this.errors,
  });

  factory ErrorApi.fromJson(Map<String, dynamic> json) => ErrorApi(
        errors: List<ErrorElement>.from(
            json["errors"].map((x) => ErrorElement.fromJson(x))),
      );

  Map<String, dynamic> toMap() => {
        "errors": List<dynamic>.from(errors.map((x) => x.toMap())),
      };
}

class ErrorElement {
  String code;
  String message;
  String param;
  String location;
  String value;

  ErrorElement({
    required this.code,
    required this.message,
    required this.param,
    required this.location,
    required this.value,
  });

  factory ErrorElement.fromJson(Map<String, dynamic> json) => ErrorElement(
        code: json["code"] as String? ?? '',
        message: json["message"] as String? ?? '',
        param: json["param"] as String? ?? '',
        location: json["location"] as String? ?? '',
        value: json["value"] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "message": message,
        "param": param,
        "location": location,
        "value": value,
      };
}
