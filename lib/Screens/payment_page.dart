import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/payment_entry_model.dart';
import '../Models/salary_slip_model.dart';
import 'payment_api.dart';
import 'payment_filter_screen.dart';
import 'payment_page_po_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Global/constant.dart'; // for baseUrl
import '../Global/webService.dart'; // if you store frappeUserEmail or token here
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
final box = GetStorage();
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PaymentEntry> payments = [];
  Map<String, List<PaymentEntry>> groupedPayments = {};
  Set<String> selectedPaymentIds = {};
  Set<String> expandedParties = {};
  bool loading = false;

  bool usePayroll = false;
  String? selectedMonth;
  String? selectedPayrollEntry;
  Map<String, dynamic>? selectedBank;
  Map<String, dynamic>? selectedBankAccount;

  bool allSelected = false;
  bool _isProcessing = false;
  TextEditingController _otpController = TextEditingController();

  double get totalAmount => payments.fold(0, (sum, p) => sum + p.amount);
  int get totalTransactions => payments.length;

  double get selectedAmount => payments
      .where((p) => selectedPaymentIds.contains(p.id))
      .fold(0, (sum, p) => sum + p.amount);
  int get selectedTransactions => selectedPaymentIds.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => openFilterScreen());
  }


  Future<void> _sendOtp() async {
    try {
      setState(() => _isProcessing = true);
      final String userEmail = box.read('user_email');
      final url = Uri.parse("$PaymentPageSendOtp?email=$userEmail");
      final response = await http.get(url);

      final data = jsonDecode(response.body);
      print(data);
      if (data["message"]["status"] == "success") {
        _showSnack("OTP sent successfully!");
        _showOtpDialog();
      } else {
        _showSnack(data["message"]["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showSnack("Error sending OTP: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.isEmpty) {
      _showSnack("Please enter OTP");
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final String userEmail = box.read('user_email');
      final url = Uri.parse("$PaymentPageVerifyOtp");
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "email": userEmail,
          "otp": otp,
          "selected_ids": selectedPaymentIds.toList(),
          "bank_account": selectedBankAccount?['name'],
          "use_payroll": usePayroll,
          "payroll_entry":selectedPayrollEntry
        }),
      );

      final data = jsonDecode(response.body);
      print(data);
      if (data['message']["status"] == "success") {
        _showSnack(data["message"]["message"]);
        Navigator.pop(context); // close OTP dialog

        // 🔹 Call your upload bank file logic or refresh list
        setState(() {
          payments.removeWhere((p) => selectedPaymentIds.contains(p));
          selectedPaymentIds.clear();
        });
        await fetchPayments();
      } else {
        _showSnack(data["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      _showSnack("Error verifying OTP: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.blueAccent),
    );
  }

  void _showConfirmDialog() {
    if (selectedPaymentIds.isEmpty) {
      _showSnack("Please select at least one payment or salary slip.");
      return;
    }

    final totalAmt = payments
        .where((p) => selectedPaymentIds.contains(p.id))
        .fold(0.0, (sum, p) => sum + p.amount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirm Payment"),
        content: Text(
          "You have selected ${selectedPaymentIds.length} transactions.\n"
              "Total Amount: ₹${totalAmt.toStringAsFixed(2)}\n\n"
              "Do you want to send OTP for confirmation?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendOtp();
            },
            child: const Text("Send OTP"),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog() {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Verify OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the OTP sent to your registered email:"),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _verifyOtp(_otpController.text.trim()),
            child: const Text("Verify OTP"),
          ),
        ],
      ),
    );
  }


  Future<void> fetchPayments() async {
    setState(() => loading = true);
    try {
      List<PaymentEntry> data = [];

      if (usePayroll && selectedPayrollEntry != null) {
        final salarySlipsData =
        await PaymentAPI.getSalarySlips(selectedPayrollEntry!);
        final salarySlips =
        salarySlipsData.map((s) => SalarySlip.fromJson(s)).toList();

        data = salarySlips
            .map((s) => PaymentEntry(
          id: s.id,
          partyName: s.partyName,
          amount: s.amount,
          remarks: s.remarks,
        ))
            .toList();
      } else {
        data = await PaymentAPI.fetchPayments(
          bankAccount: selectedBankAccount?['name'],
        );
      }

      setState(() {
        payments = data;
        groupedPayments = _groupByParty(data);
        selectedPaymentIds.clear();
        expandedParties.clear();
        allSelected = false;
      });
    } catch (e) {
      debugPrint("Error fetching payments: $e");
    }
    setState(() => loading = false);
  }

  Map<String, List<PaymentEntry>> _groupByParty(List<PaymentEntry> entries) {
    final map = <String, List<PaymentEntry>>{};
    for (var e in entries) {
      map.putIfAbsent(e.partyName, () => []).add(e);
    }
    return map;
  }

  void openFilterScreen() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => PaymentFilterScreen(
        usePayroll: usePayroll,
        selectedMonth: selectedMonth,
        selectedPayrollEntry: selectedPayrollEntry,
        selectedBank: selectedBank,
        selectedBankAccount: selectedBankAccount,
      ),
    );

    if (result != null) {
      setState(() {
        usePayroll = result['usePayroll'];
        selectedMonth = result['month'];
        selectedPayrollEntry = result['payrollEntry'];
        selectedBank = result['bank'];
        selectedBankAccount = result['bankAccount'];
      });

      await fetchPayments();
    }
  }

  void toggleSelectAll() {
    setState(() {
      if (allSelected) {
        selectedPaymentIds.clear();
        allSelected = false;
      } else {
        selectedPaymentIds = payments.map((p) => p.id).toSet();
        allSelected = true;
      }
    });
  }

  void showPaymentDetail(String id) async {
    try {
      final detail = await PaymentAPI.getPaymentDetail(id);
      if (detail != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentDetailScreen(
              paymentDetail: detail,
              paymentEntryId: id,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching payment detail: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch payment details")),
      );
    }
  }

  Future<void> holdPayment(PaymentEntry entry) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Hold"),
          content: const Text("Are you sure you want to hold this salary slip?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Hold"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // 🔸 Add your API call here
      await PaymentAPI.holdSalarySlips(entry.id);
      setState(() {
        payments.removeWhere((p) => p.id == entry.id);
        groupedPayments = _groupByParty(payments);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment held successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error holding payment: $e")),
      );
    }
  }


  Future<void> rejectPayment(PaymentEntry entry) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Reject"),
          content: const Text("Are you sure you want to reject this payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Reject"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await PaymentAPI.cancelPaymentEntries([entry.id]);

      setState(() {
        payments.removeWhere((p) => p.id == entry.id);
        groupedPayments = _groupByParty(payments);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment rejected successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error rejecting payment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: "₹", decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: openFilterScreen,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? Center(
        child: Text(
          usePayroll ? "No salary slips found" : "No payments found",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SummaryCard(
              totalTransactions: totalTransactions,
              totalAmount: totalAmount,
              selectedTransactions: selectedTransactions,
              selectedAmount: selectedAmount,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ Select / Deselect All Button
                TextButton.icon(
                  icon: Icon(
                    allSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  label: Text(
                    allSelected
                        ? "Deselect All ($selectedTransactions)"
                        : "Select All",
                  ),
                  onPressed: toggleSelectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // ✅ Make Payment Button (only shown when something is selected)
                if (selectedPaymentIds.isNotEmpty)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment, size: 20),
                    onPressed: _isProcessing ? null : _showConfirmDialog,
                    label: Text(
                      _isProcessing ? "Processing..." : "Make Payment",
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: groupedPayments.keys.length,
              itemBuilder: (context, index) {
                final party = groupedPayments.keys.elementAt(index);
                final entries = groupedPayments[party]!;
                final totalPartyAmount = entries.fold(
                    0.0, (sum, e) => sum + e.amount);

                final parentSelected = entries
                    .every((e) => selectedPaymentIds.contains(e.id));

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ExpansionTile(
                    key: PageStorageKey(party),
                    initiallyExpanded:
                    expandedParties.contains(party),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded) {
                          expandedParties.add(party);
                        } else {
                          expandedParties.remove(party);
                        }
                      });
                    },
                    leading: Checkbox(
                      value: parentSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            entries.forEach((e) =>
                                selectedPaymentIds.add(e.id));
                          } else {
                            entries.forEach((e) =>
                                selectedPaymentIds.remove(e.id));
                          }
                        });
                      },
                    ),
                    title: Text(
                      party,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Total: ${f.format(totalPartyAmount)} (${entries.length} entries)",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: entries.map((entry) {
                      final isSelected =
                      selectedPaymentIds.contains(entry.id);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedPaymentIds
                                            .add(entry.id);
                                      } else {
                                        selectedPaymentIds
                                            .remove(entry.id);
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.id,
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 16)),
                                      if (entry.remarks
                                          ?.isNotEmpty ==
                                          true)
                                        Text(entry.remarks!,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Text(
                                  f.format(entry.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (usePayroll)
                                  OutlinedButton(
                                    onPressed: () => holdPayment(entry),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orangeAccent,
                                      side: const BorderSide(color: Colors.orangeAccent),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Hold"),
                                  )
                                else ...[
                                  OutlinedButton(
                                    onPressed: () => rejectPayment(entry),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Reject"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => showPaymentDetail(entry.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Get Details"),
                                  ),
                                ],
                              ],
                            ),

                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Summary Card --------------------
class SummaryCard extends StatelessWidget {
  final int totalTransactions;
  final double totalAmount;
  final int selectedTransactions;
  final double selectedAmount;

  const SummaryCard({
    super.key,
    required this.totalTransactions,
    required this.totalAmount,
    required this.selectedTransactions,
    required this.selectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: "₹", decimalDigits: 2);

    final stats = [
      {"label": "Total\nTransactions", "value": totalTransactions.toString()},
      {"label": "Total\nAmount", "value": f.format(totalAmount)},
      {"label": "Selected\nTransactions", "value": selectedTransactions.toString()},
      {"label": "Selected\nAmount", "value": f.format(selectedAmount)},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats
              .map(
                (s) => Column(
              children: [
                Text(
                  s["label"]!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  s["value"]!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
