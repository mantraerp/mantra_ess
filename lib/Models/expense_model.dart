// To parse this JSON data, use
//
//     final expenseResponse = expenseResponseFromJson(jsonString);

import 'dart:convert';

ExpenseResponse expenseResponseFromJson(String str) =>
    ExpenseResponse.fromJson(json.decode(str));

String expenseResponseToJson(ExpenseResponse data) =>
    json.encode(data.toJson());

class ExpenseResponse {
  String message;
  List<ExpenseRecord>? data;
  int statusCode;

  ExpenseResponse({required this.message, this.data, required this.statusCode});

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) =>
      ExpenseResponse(
        message: json["message"],
        data: json["data"] != null
            ? List<ExpenseRecord>.from(
                json["data"].map((x) => ExpenseRecord.fromJson(x)),
              )
            : null,
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class ExpenseRecord {
  String name;
  String postingDate;
  String employeeName;
  String? customExpenseGrouping;
  String status;
  String company;
  List<ExpenseItem> expenses;

  ExpenseRecord({
    required this.name,
    required this.postingDate,
    required this.employeeName,
    this.customExpenseGrouping,
    required this.status,
    required this.company,
    required this.expenses,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
    name: json["name"],
    postingDate: json["posting_date"],
    employeeName: json["employee_name"],
    customExpenseGrouping: json["custom_expense_grouping"],
    status: json["status"],
    company: json["company"],
    expenses: List<ExpenseItem>.from(
      json["expenses"].map((x) => ExpenseItem.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "posting_date": postingDate,
    "employee_name": employeeName,
    "custom_expense_grouping": customExpenseGrouping,
    "status": status,
    "company": company,
    "expenses": List<dynamic>.from(expenses.map((x) => x.toJson())),
  };
}

class ExpenseItem {
  String expenseType;
  String? description;
  double amount;
  double sanctionedAmount;
  String costCenter;
  String expenseDate;

  ExpenseItem({
    required this.expenseType,
    this.description,
    required this.amount,
    required this.sanctionedAmount,
    required this.costCenter,
    required this.expenseDate,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
    expenseType: json["expense_type"],
    description: json["description"],
    amount: (json["amount"] as num).toDouble(),
    sanctionedAmount: (json["sanctioned_amount"] as num).toDouble(),
    costCenter: json["cost_center"],
    expenseDate: json["expense_date"],
  );

  Map<String, dynamic> toJson() => {
    "expense_type": expenseType,
    "description": description,
    "amount": amount,
    "sanctioned_amount": sanctionedAmount,
    "cost_center": costCenter,
    "expense_date": expenseDate,
  };
}
