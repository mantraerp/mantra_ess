
import 'dart:convert';

SalesOrderResponse SalesOrderResponseFromJson(String str) =>
    SalesOrderResponse.fromJson(json.decode(str));

String SalesOrderResponseToJson(SalesOrderResponse data) =>
    json.encode(data.toJson());

class SalesOrderResponse {
  String message;
  List<SalesOrderRecord> data;
  int statusCode;

  SalesOrderResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory SalesOrderResponse.fromJson(Map<String, dynamic> json) =>
      SalesOrderResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<SalesOrderRecord>.from(
            json["data"].map((x) => SalesOrderRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class SalesOrderRecord {
  String name;
  String? customer_name;
  String? transactionDate;
  String? status;
  double? grandTotal;
  String? currency;

  SalesOrderRecord({
    required this.name,
    this.customer_name,
    this.transactionDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory SalesOrderRecord.fromJson(Map<String, dynamic> json) =>
      SalesOrderRecord(
        name: json["name"] ?? "",
        customer_name: json["customer_name"],
        transactionDate: json["transaction_date"],
        status: json["status"],
        grandTotal: (json["grand_total"] != null)
            ? json["grand_total"].toDouble()
            : 0.0,
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "customer_name": customer_name,
    "transaction_date": transactionDate,
    "status": status,
    "grand_total": grandTotal,
    "currency": currency,
  };
}
