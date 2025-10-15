import 'dart:convert';
import 'package:http/http.dart' as http;
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
          "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_payment_entries?bank_account=$bankAccount");
    }  else {
      throw Exception("Bank account or payroll entry required");
    }

    final response = await http.get(url);

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
        "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_payment_entry_detail?payment_entry=$paymentEntryId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message'] as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch payment details");
    }
  }

  // ---------------------------
  // Hold / Cancel payment entries
  // ---------------------------
  static Future<void> holdPayment(String paymentEntryId) async {
    final url = Uri.parse("$SUB_BASE_URL/cancel_payment_entries");
    final response = await http.post(url, body: {
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
        "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_banks");
    final response = await http.get(url);

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
    final url = Uri.parse("http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_bank_accounts?bank=$bankName");
    final response = await http.get(url);

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
        "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_payroll_months");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final months = List<String>.from(data['data']['months']);
      return months;
    } else {
      throw Exception("Failed to fetch months");
    }
  }

  // ---------------------------
  // Get Payroll Entries
  // ---------------------------
  static Future<List<Map<String, dynamic>>> getPayrollEntries(
      String month) async {
    final url = Uri.parse(
        "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_payroll_entries?month=$month");
    final response = await http.get(url);

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
        "http://192.168.11.66:8017/api/method/erp_mobile.api.payment_page.get_salary_slips?payroll_entry=$payroll");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']?['salary_slips'] as List? ?? [];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch payroll entries");
    }
  }
}
