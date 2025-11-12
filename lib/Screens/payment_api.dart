import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/constant.dart';
import '../Models/payment_entry_model.dart';
import '../Global/webService.dart';

class PaymentAPI {
  // ---------------------------
  // Fetch payments by Bank Account
  // ---------------------------
  static Future<List<PaymentEntry>> fetchPayments(
      {String? bankAccount}) async {
    Uri url;

    if (bankAccount != null) {
      url = Uri.parse(
          "$PaymentPagePaymentEntries?bank_account=$bankAccount");
    }  else {
      throw Exception("Bank account or payroll entry required");
    }

    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']['payment_entries'] as List;
      return data.map((e) => PaymentEntry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch payments");
    }
  }
  static Future<List<PaymentEntry>> fetchPaymentApprovePayments(
      {String? bankAccount}) async {
    Uri url;

    if (bankAccount != null) {
      url = Uri.parse(
          "$PaymentPageApprovePaymentEntries?bank_account=$bankAccount");
    }  else {
      throw Exception("Bank account or payroll entry required");
    }

    final response =await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']['payment_entries'] as List;
      return data.map((e) => PaymentEntry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch payments");
    }
  }

  // ---------------------------
  // Get payment entry details
  // ---------------------------
  static Future<Map<String, dynamic>> getPaymentDetail(
      String paymentEntryId) async {
    final url = Uri.parse(
        "$PaymentPageRefrenceDetails?payment_entry=$paymentEntryId");
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch payment details");
    }
  }


  static Future<String> updateRemark(
      String paymentEntryId, String remark) async {
    final url = Uri.parse(
        "$PaymentPageUpdateRemark");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "payment_entry": paymentEntryId,
        "remark": remark,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        return body['message'].toString();
      } else {
        throw Exception("Invalid response: ${body}");
      }
    } else {
      throw Exception(
          "Failed to update remark. Status code: ${response.statusCode}");
    }
  }
  // ---------------------------
  // Hold / Cancel payment entries
  // ---------------------------
  static Future<void> holdPayment(String paymentEntryId) async {
    final url = Uri.parse("$SUB_BASE_URL/cancel_payment_entries");
    final response = await http.post(url, headers:headers,body: {
      "payment_entry_ids": jsonEncode([paymentEntryId]),
    });

    if (response.statusCode != 200) {
      throw Exception("Failed to hold payment");
    }
  }

  // ---------------------------
  // Get all Banks
  // ---------------------------
  static Future<List<Map<String, dynamic>>> getBanks() async {
    final url = Uri.parse(
        "$PaymentPageBankList");
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']['banks'] as List; // <-- fixed path
      return List<Map<String, dynamic>>.from(data);
    } else {

      throw Exception("Failed to fetch banks");
    }
  }


  // ---------------------------
  // Get Bank Accounts by Bank
  // ---------------------------
  static Future<List<Map<String, dynamic>>> getBankAccounts(
      String bankName) async {
    final url = Uri.parse("$PaymentPageBankAccountList?bank=$bankName");
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']['bank_accounts'] as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch bank accounts");
    }
  }

  // ---------------------------
  // Get all Months
  // ---------------------------
  static Future<List<String>> getMonths() async {
    final url = Uri.parse(
        "$PaymentPageMonthList");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final months = List<String>.from(data['data']['months']);
      return months;
    } else {
      throw Exception("Failed to fetch months");
    }
  }

  static Future<void> cancelPaymentEntries(List<String> paymentEntryIds) async {
    final url = Uri.parse(
        "$PaymentPageCancelPaymentEntry");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"payment_entry_ids": jsonEncode(paymentEntryIds)}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel payments: ${response.body}");
    }

    final body = jsonDecode(response.body);
    if (body['message'] == null || !body['message'].toString().contains("Successfully")) {
      throw Exception("Unexpected response: ${response.body}");
    }
  }


  static Future<void> approvePaymentEntries(List<String> paymentEntryIds) async {
    final url = Uri.parse(
        "$PaymentPageApprovePaymentEntry");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"payment_entry_ids": jsonEncode(paymentEntryIds)}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to hold payments: ${response.body}");
    }

    final body = jsonDecode(response.body);
    if (body['message'] == null || !body['message'].toString().contains("Successfully")) {
      throw Exception("Unexpected response: ${response.body}");
    }
  }

  static Future<void> holdPaymentEntries(List<String> paymentEntryIds) async {
    final url = Uri.parse(
        "$PaymentPageApproveHoldPaymentEntry");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"payment_entry_ids": jsonEncode(paymentEntryIds)}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to hold payments: ${response.body}");
    }

    final body = jsonDecode(response.body);
    if (body['message'] == null || !body['message'].toString().contains("Successfully")) {
      throw Exception("Unexpected response: ${response.body}");
    }
  }



  static Future<void> holdSalarySlips(String salaryslip) async {
    final url = Uri.parse(
        "$PaymentPageHoldSalarySlip?salary_slip_id=$salaryslip");

    final response = await http.post(
      url,
      headers: headers
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel payments: ${response.body}");
    }

    final body = jsonDecode(response.body);
    if (body['message'] == null || !body['message'].toString().contains("Successfully")) {
      throw Exception("Unexpected response: ${response.body}");
    }
  }

  // ---------------------------
  // Get Payroll Entries
  // ---------------------------
  static Future<List<Map<String, dynamic>>> getPayrollEntries(
      String month) async {
    final url = Uri.parse(
        "$PaymentPagePayrollEntriesList?month=$month");
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']?['payroll_entries'] as List? ?? [];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch payroll entries");
    }
  }

  static Future<List<Map<String, dynamic>>> getSalarySlips(
      String payroll) async {
    final url = Uri.parse(
        "$PaymentPageSalarySlipsList?payroll_entry=$payroll");
    final response =await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']?['salary_slips'] as List? ?? [];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch payroll entries");
    }
  }
}
