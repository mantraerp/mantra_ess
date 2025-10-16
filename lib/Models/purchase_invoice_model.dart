
import 'dart:convert';

PurchaseInvoiceResponse purchaseInvoiceResponseFromJson(String str) =>
    PurchaseInvoiceResponse.fromJson(json.decode(str));

String purchaseInvoiceResponseToJson(PurchaseInvoiceResponse data) =>
    json.encode(data.toJson());

class PurchaseInvoiceResponse {
  String message;
  List<PurchaseInvoiceRecord> data;
  int statusCode;

  PurchaseInvoiceResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory PurchaseInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseInvoiceResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<PurchaseInvoiceRecord>.from(
            json["data"].map((x) => PurchaseInvoiceRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class PurchaseInvoiceRecord {
  String name;
  String? supplier_name;
  String? postingDate;
  String? status;
  double? grandTotal;
  String? currency;

  PurchaseInvoiceRecord({
    required this.name,
    this.supplier_name,
    this.postingDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory PurchaseInvoiceRecord.fromJson(Map<String, dynamic> json) =>
      PurchaseInvoiceRecord(
        name: json["name"] ?? "",
        supplier_name: json["supplier_name"],
        postingDate: json["posting_date"],
        status: json["status"],
        grandTotal: (json["grand_total"] != null)
            ? json["grand_total"].toDouble()
            : 0.0,
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "supplier_name": supplier_name,
    "posting_date": postingDate,
    "status": status,
    "grand_total": grandTotal,
    "currency": currency,
  };
}
