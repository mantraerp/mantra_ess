
import 'dart:convert';

PurchaseOrderResponse purchaseOrderResponseFromJson(String str) =>
    PurchaseOrderResponse.fromJson(json.decode(str));

String purchaseOrderResponseToJson(PurchaseOrderResponse data) =>
    json.encode(data.toJson());

class PurchaseOrderResponse {
  String message;
  List<PurchaseOrderRecord> data;
  int statusCode;

  PurchaseOrderResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory PurchaseOrderResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderResponse(
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<PurchaseOrderRecord>.from(
            json["data"].map((x) => PurchaseOrderRecord.fromJson(x)))
            : [],
        statusCode: json["status_code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class PurchaseOrderRecord {
  String name;
  String? supplier_name;
  String? transactionDate;
  String? status;
  double? grandTotal;
  String? currency;

  PurchaseOrderRecord({
    required this.name,
    this.supplier_name,
    this.transactionDate,
    this.status,
    this.grandTotal,
    this.currency,
  });

  factory PurchaseOrderRecord.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderRecord(
        name: json["name"] ?? "",
        supplier_name: json["supplier_name"],
        transactionDate: json["transaction_date"],
        status: json["status"],
        grandTotal: (json["grand_total"] != null)
            ? json["grand_total"].toDouble()
            : 0.0,
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "supplier_name": supplier_name,
    "transaction_date": transactionDate,
    "status": status,
    "grand_total": grandTotal,
    "currency": currency,
  };
}
