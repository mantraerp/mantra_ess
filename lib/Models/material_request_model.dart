
import 'dart:convert';

MaterialRequestResponse MaterialRequestResponseFromJson(String str) =>
    MaterialRequestResponse.fromJson(json.decode(str));

String MaterialRequestResponseToJson(MaterialRequestResponse data) =>
    json.encode(data.toJson());

class MaterialRequestResponse {
  String message;
  List<MaterialRequestRecord> data;
  int statusCode;

  MaterialRequestResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory MaterialRequestResponse.fromJson(Map<String, dynamic> json) =>
      MaterialRequestResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<MaterialRequestRecord>.from(
            json["data"].map((x) => MaterialRequestRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class MaterialRequestRecord {
  String name;
  String? title;
  String? transcationDate;
  String? status;
  String? materialRequestType;

  MaterialRequestRecord({
    required this.name,
    this.title,
    this.transcationDate,
    this.status,
    this.materialRequestType,

  });

  factory MaterialRequestRecord.fromJson(Map<String, dynamic> json) =>
      MaterialRequestRecord(
        name: json["name"] ?? "",
        title: json["title"],
        transcationDate: json["transaction_date"],
        status: json["status"],
        materialRequestType: json["material_request_type"]
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "title": title,
    "transcation_date": transcationDate,
    "status": status,
    "material_request_type": materialRequestType,

  };
}
