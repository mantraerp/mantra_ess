import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/payment_entry_model.dart';
import '../Models/salary_slip_model.dart';
import 'payment_api.dart';
import 'payment_page_approve_filter_screen.dart';
import 'toast_helper.dart';
import 'payment_page_po_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Global/constant.dart'; // for baseUrl
import '../Global/webService.dart'; // if you store frappeUserEmail or token here
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
final box = GetStorage();
class PaymentApprovePage extends StatefulWidget {
  const PaymentApprovePage({super.key});

  @override
  State<PaymentApprovePage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentApprovePage> {
  List<PaymentEntry> payments = [];
  Map<String, List<PaymentEntry>> groupedPayments = {};
  Set<String> selectedPaymentIds = {};
  Set<String> expandedParties = {};
  bool loading = false;


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







  Future<void> fetchPayments() async {
    setState(() => loading = true);
    try {
      List<PaymentEntry> data = [];


        data = await PaymentAPI.fetchPaymentApprovePayments(
          bankAccount: selectedBankAccount?['name'],
        );


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

        selectedBank: selectedBank,
        selectedBankAccount: selectedBankAccount,
        ),
    );

    if (result != null) {
      setState(() {

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


      ToastUtils.show(context, "Failed to fetch payment details");
    }
  }

  Future<void> approvePayment(PaymentEntry entry) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Approve"),
          content: const Text("Are you sure you want to approve this payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Approve"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await PaymentAPI.approvePaymentEntries([entry.id]);

      setState(() {
        payments.removeWhere((p) => p.id == entry.id);
        groupedPayments = _groupByParty(payments);
      });


      ToastUtils.show(context,"Payment Approved successfully");
    } catch (e) {

      ToastUtils.show(context,"Error approving payment: $e");
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

      ToastUtils.show(context,"Payment rejected successfully");
    } catch (e) {
      ToastUtils.show(context,"Error rejecting payment: $e");

    }
  }

  Future<void> HoldPayment(PaymentEntry entry) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Hold"),
          content: const Text("Are you sure you want to hold this payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Hold"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await PaymentAPI.holdPaymentEntries([entry.id]);

      setState(() {
        payments.removeWhere((p) => p.id == entry.id);
        groupedPayments = _groupByParty(payments);
      });
      ToastUtils.show(context,"Payment hold successfully");

    } catch (e) {
      ToastUtils.show(context,"Error hold payment: $e");

    }
  }


  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: "₹", decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        centerTitle: true,
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
          "No payments found",
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
                    foregroundColor: Colors.black,

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
                      activeColor: appBlack,
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
                                  activeColor: appBlack,
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
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 5, // horizontal space between buttons
                              runSpacing: 4, // vertical space when wrapping
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => HoldPayment(entry),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orangeAccent,
                                    side: const BorderSide(color: Colors.orangeAccent),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Hold"),
                                ),
                                OutlinedButton(
                                  onPressed: () => approvePayment(entry),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.greenAccent),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Approve"),
                                ),
                                OutlinedButton(
                                  onPressed: () => rejectPayment(entry),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Reject"),
                                ),
                                ElevatedButton(
                                  onPressed: () => showPaymentDetail(entry.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Get Details"),
                                ),
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
