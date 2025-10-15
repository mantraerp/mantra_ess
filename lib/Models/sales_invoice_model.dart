
import 'dart:convert';

SalesInvoiceResponse SalesInvoiceResponseFromJson(String str) =>
    SalesInvoiceResponse.fromJson(json.decode(str));

String SalesInvoiceResponseToJson(SalesInvoiceResponse data) =>
    json.encode(data.toJson());

class SalesInvoiceResponse {
  String message;
  List<SalesInvoiceRecord> data;
  int statusCode;

  SalesInvoiceResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory SalesInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      SalesInvoiceResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<SalesInvoiceRecord>.from(
            json["data"].map((x) => SalesInvoiceRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class SalesInvoiceRecord {
  String name;
  String? customer_name;
  String? postingDate;
  String? status;
  double? grandTotal;
  String? currency;

  SalesInvoiceRecord({
    required this.name,
    this.customer_name,
    this.postingDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory SalesInvoiceRecord.fromJson(Map<String, dynamic> json) =>
      SalesInvoiceRecord(
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
