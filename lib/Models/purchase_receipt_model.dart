
import 'dart:convert';

PurchaseReceiptResponse purchaseReceiptResponseFromJson(String str) =>
    PurchaseReceiptResponse.fromJson(json.decode(str));

String purchaseReceiptResponseToJson(PurchaseReceiptResponse data) =>
    json.encode(data.toJson());

class PurchaseReceiptResponse {
  String message;
  List<PurchaseReceiptRecord> data;
  int statusCode;

  PurchaseReceiptResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory PurchaseReceiptResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseReceiptResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<PurchaseReceiptRecord>.from(
            json["data"].map((x) => PurchaseReceiptRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class PurchaseReceiptRecord {
  String name;
  String? supplier_name;
  String? postingDate;
  String? status;
  double? grandTotal;
  String? currency;

  PurchaseReceiptRecord({
    required this.name,
    this.supplier_name,
    this.postingDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory PurchaseReceiptRecord.fromJson(Map<String, dynamic> json) =>
      PurchaseReceiptRecord(
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
