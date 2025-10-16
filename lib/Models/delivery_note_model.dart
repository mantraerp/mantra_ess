
import 'dart:convert';

DeliveryNoteResponse DeliveryNoteResponseFromJson(String str) =>
    DeliveryNoteResponse.fromJson(json.decode(str));

String DeliveryNoteResponseToJson(DeliveryNoteResponse data) =>
    json.encode(data.toJson());

class DeliveryNoteResponse {
  String message;
  List<DeliveryNoteRecord> data;
  int statusCode;

  DeliveryNoteResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory DeliveryNoteResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryNoteResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<DeliveryNoteRecord>.from(
            json["data"].map((x) => DeliveryNoteRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class DeliveryNoteRecord {
  String name;
  String? customer_name;
  String? postingDate;
  String? status;
  double? grandTotal;
  String? currency;

  DeliveryNoteRecord({
    required this.name,
    this.customer_name,
    this.postingDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory DeliveryNoteRecord.fromJson(Map<String, dynamic> json) =>
      DeliveryNoteRecord(
        name: json["name"] ?? "",
        customer_name: json["customer_name"],
        postingDate: json["posting_date"],
        status: json["status"],
        grandTotal: (json["grand_total"] != null)
            ? json["grand_total"].toDouble()
            : 0.0,
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "customer_name": customer_name,
    "posting_date": postingDate,
    "status": status,
    "grand_total": grandTotal,
    "currency": currency,
  };
}
