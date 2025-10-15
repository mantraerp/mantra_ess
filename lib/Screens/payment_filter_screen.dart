import 'package:flutter/material.dart';
import 'payment_api.dart';

class PaymentFilterScreen extends StatefulWidget {
  final bool usePayroll;
  final String? selectedMonth;
  final String? selectedPayrollEntry;
  final Map<String, dynamic>? selectedBank;
  final Map<String, dynamic>? selectedBankAccount;

  const PaymentFilterScreen({
    super.key,
    required this.usePayroll,
    this.selectedMonth,
    this.selectedPayrollEntry,
    this.selectedBank,
    this.selectedBankAccount,
  });

  @override
  State<PaymentFilterScreen> createState() => _PaymentFilterScreenState();
}

class _PaymentFilterScreenState extends State<PaymentFilterScreen> {
  bool usePayroll = false;
  String? month;
  String? payrollEntry;
  Map<String, dynamic>? bank;
  Map<String, dynamic>? bankAccount;

  List<String> months = [];
  List<String> payrollEntries = [];
  List<Map<String, dynamic>> banks = [];
  List<Map<String, dynamic>> bankAccounts = [];

  bool loadingMonths = false;
  bool loadingPayrollEntries = false;
  bool loadingBanks = false;
  bool loadingBankAccounts = false;

  @override
  void initState() {
    super.initState();
    usePayroll = widget.usePayroll;
    month = widget.selectedMonth;
    payrollEntry = widget.selectedPayrollEntry;
    bank = widget.selectedBank;
    bankAccount = widget.selectedBankAccount;

    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    if (usePayroll) {
      await getMonths();
      if (month != null) await getPayrollEntries(month!);
    } else {
      await getBanks();
      if (bank != null) await getBankAccounts(bank!['bank_name']);
    }
  }

  Future<void> getMonths() async {
    setState(() => loadingMonths = true);
    try {
      final result = await PaymentAPI.getMonths();
      months = result.map((m) => m.toString()).toList();
    } catch (e) {
      debugPrint("Error fetching months: $e");
    }
    setState(() => loadingMonths = false);
  }

  Future<void> getPayrollEntries(String selectedMonth) async {
    setState(() => loadingPayrollEntries = true);
    try {
      final result = await PaymentAPI.getPayrollEntries(selectedMonth);
      payrollEntries = result.isNotEmpty
          ? result.map((e) => e['name'].toString()).toList()
          : [];
    } catch (e) {
      debugPrint("Error fetching payroll entries: $e");
    }
    setState(() => loadingPayrollEntries = false);
  }

  Future<void> getBanks() async {
    setState(() => loadingBanks = true);
    try {
      final result = await PaymentAPI.getBanks();
      banks = List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      debugPrint("Error fetching banks: $e");
    }
    setState(() => loadingBanks = false);
  }

  Future<void> getBankAccounts(String bankName) async {
    setState(() => loadingBankAccounts = true);
    try {
      final result = await PaymentAPI.getBankAccounts(bankName);
      bankAccounts = List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      debugPrint("Error fetching bank accounts: $e");
    }
    setState(() => loadingBankAccounts = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: width,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter Payments",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payroll / Bank Switch
                  SwitchListTile(
                    activeColor: Colors.blueAccent,
                    title: const Text("Use Payroll Entry"),
                    value: usePayroll,
                    onChanged: (v) {
                      setState(() {
                        usePayroll = v;
                        month = null;
                        payrollEntry = null;
                        bank = null;
                        bankAccount = null;
                        months.clear();
                        payrollEntries.clear();
                        banks.clear();
                        bankAccounts.clear();
                        fetchInitialData();
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Payroll Dropdowns
                  if (usePayroll) ...[
                    loadingMonths
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdown(
                      "Month",
                      month,
                      months,
                          (v) async {
                        if (v != null) {
                          setState(() {
                            month = v;
                            payrollEntry = null;
                            payrollEntries.clear();
                          });
                          await getPayrollEntries(v);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (month != null)
                      loadingPayrollEntries
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdown(
                        "Payroll Entry",
                        payrollEntry,
                        payrollEntries,
                            (v) => setState(() {
                          payrollEntry = v;
                        }),
                      ),
                  ],

                  // Bank Dropdowns
                  if (!usePayroll) ...[
                    loadingBanks
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdownMap(
                      "Bank",
                      bank,
                      banks,
                          (v) async {
                        if (v != null) {
                          setState(() {
                            bank = v;
                            bankAccount = null;
                            bankAccounts.clear();
                          });
                          await getBankAccounts(v['bank_name']);
                        }
                      },
                      displayKey: 'bank_name',
                    ),
                    const SizedBox(height: 10),
                    if (bank != null)
                      loadingBankAccounts
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdownMap(
                        "Bank Account",
                        bankAccount,
                        bankAccounts,
                            (v) => setState(() {
                          bankAccount = v;
                        }),
                        displayKey: 'name',
                      ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'usePayroll': usePayroll,
                          'month': month,
                          'payrollEntry': payrollEntry,
                          'bank': bank,
                          'bankAccount': bankAccount,
                        });
                      },
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown for simple string lists
  Widget _buildDropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: value, // do not auto-select
      hint: Text("Select $label"),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(e),
        ),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // Dropdown for map/list data (like bank and bank account)
  Widget _buildDropdownMap(
      String label,
      Map<String, dynamic>? value,
      List<Map<String, dynamic>> items,
      ValueChanged<Map<String, dynamic>?> onChanged, {
        required String displayKey,
      }) {
    // Remove duplicates based on displayKey
    final uniqueItems = {
      for (var e in items) e[displayKey]: e,
    }.values.toList();

    // Find selected value
    Map<String, dynamic>? selectedValue;
    if (value != null) {
      try {
        selectedValue = uniqueItems.firstWhere(
              (e) => e[displayKey] == value[displayKey],
        );
      } catch (e) {
        selectedValue = null; // no match found
      }
    }

    return DropdownButtonFormField<Map<String, dynamic>>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: selectedValue,
      hint: Text("Select $label"),
      items: uniqueItems
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(e[displayKey] ?? ""),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

}
