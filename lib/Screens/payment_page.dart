import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/payment_entry_model.dart';
import '../Models/salary_slip_model.dart';
import 'payment_api.dart';
import 'payment_filter_screen.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PaymentEntry> payments = [];
  Map<String, List<PaymentEntry>> groupedPayments = {};
  Set<String> selectedPaymentIds = {}; // Track selected payments
  Set<String> expandedParties = {}; // Track expanded parent tiles

  bool loading = false;

  // Filters
  bool usePayroll = false;
  String? selectedMonth;
  String? selectedPayrollEntry;
  Map<String, dynamic>? selectedBank;
  Map<String, dynamic>? selectedBankAccount;

  bool allSelected = false; // Toggle select/deselect

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

  // Fetch Payments or Salary Slips based on filter
  Future<void> fetchPayments() async {
    setState(() => loading = true);
    try {
      List<PaymentEntry> data = [];

      if (usePayroll && selectedPayrollEntry != null) {
        // Fetch salary slips
        final salarySlipsData = await PaymentAPI.getSalarySlips(selectedPayrollEntry!);
        final salarySlips = salarySlipsData.map((s) => SalarySlip.fromJson(s)).toList();

        // Map SalarySlip to PaymentEntry for UI
        data = salarySlips.map((s) => PaymentEntry(
          id: s.id,
          partyName: s.partyName,
          amount: s.amount,

          remarks: s.remarks,
        )).toList();

      } else {
        // Fetch regular payments
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
      barrierDismissible: false,
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
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Entry Details"),
          content: Text(detail.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error fetching payment detail: $e");
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : Column(
        children: [
          // Summary Card
          Padding(
            padding: const EdgeInsets.all(8),
            child: SummaryCard(
              totalTransactions: totalTransactions,
              totalAmount: totalAmount,
              selectedTransactions: selectedTransactions,
              selectedAmount: selectedAmount,
            ),
          ),
          // Select/Deselect Toggle Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: toggleSelectAll,
                child: Text(allSelected
                    ? "Deselect All ($selectedTransactions)"
                    : "Select All"),
              ),
            ),
          ),
          // Grouped Payments
          Expanded(
            child: ListView.builder(
              itemCount: groupedPayments.keys.length,
              itemBuilder: (context, index) {
                final party = groupedPayments.keys.elementAt(index);
                final entries = groupedPayments[party]!;
                final totalPartyAmount =
                entries.fold(0.0, (sum, e) => sum + e.amount);

                final parentSelected =
                entries.every((e) => selectedPaymentIds.contains(e.id));

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    initiallyExpanded: expandedParties.contains(party),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded)
                          expandedParties.add(party);
                        else
                          expandedParties.remove(party);
                      });
                    },
                    leading: Checkbox(
                      value: parentSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            entries.forEach(
                                    (e) => selectedPaymentIds.add(e.id));
                          } else {
                            entries.forEach(
                                    (e) => selectedPaymentIds.remove(e.id));
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true)
                                        selectedPaymentIds.add(entry.id);
                                      else
                                        selectedPaymentIds
                                            .remove(entry.id);
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      if (entry.remarks?.isNotEmpty ==
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
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Hold button disabled for salary slips
                                OutlinedButton(
                                  onPressed: usePayroll
                                      ? null
                                      : () => PaymentAPI.holdPayment(entry.id),
                                  child: const Text("Hold"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      showPaymentDetail(entry.id),
                                  child: const Text("Get Details"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
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

// Summary Card
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
