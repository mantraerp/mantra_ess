import 'package:flutter/material.dart';
import 'payment_api.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PaymentFilterScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedBank;
  final Map<String, dynamic>? selectedBankAccount;

  const PaymentFilterScreen({
    super.key,

    this.selectedBank,
    this.selectedBankAccount,
  });

  @override
  State<PaymentFilterScreen> createState() => _PaymentFilterScreenState();
}

class _PaymentFilterScreenState extends State<PaymentFilterScreen> {

  Map<String, dynamic>? bank;
  Map<String, dynamic>? bankAccount;


  List<Map<String, dynamic>> banks = [];
  List<Map<String, dynamic>> bankAccounts = [];


  bool loadingBanks = false;
  bool loadingBankAccounts = false;

  // Search Controllers

  final TextEditingController bankSearchController = TextEditingController();
  final TextEditingController bankAccountSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bank = widget.selectedBank;
    bankAccount = widget.selectedBankAccount;

    fetchInitialData();
  }

  Future<void> fetchInitialData() async {

      await getBanks();
      if (bank != null) await getBankAccounts(bank!['bank_name']);

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

  Future<void> _showCenteredMessage(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.center,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.orangeAccent),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
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
            child: Stack(
              children: [
                // Main Content
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20), // space for close icon
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

                      const SizedBox(height: 8),

                      // Payroll Dropdowns


                      // Bank Dropdowns
                    ...[
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
                            'bank_name',
                            bankSearchController),
                        const SizedBox(height: 10),
                        if (bank != null)
                          loadingBankAccounts
                              ? const Center(child: CircularProgressIndicator())
                              : bankAccounts.isEmpty
                              ? const Text(
                            "No Bank Accounts Found",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          )
                              : _buildDropdownMap(
                              "Bank Account",
                              bankAccount,
                              bankAccounts,
                                  (v) {
                                setState(() {
                                  bankAccount = v;
                                });
                              },
                              'name',
                              bankAccountSearchController),
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
                          onPressed: () async {

                              if (bank == null) {
                                await _showCenteredMessage(
                                  "Please select a Bank before applying filters.",
                                );
                                return;
                              }
                              if (bankAccount == null) {
                                await _showCenteredMessage(
                                  "Please select a Bank Account before applying filters.",
                                );
                                return;
                              }


                            Navigator.pop(context, {

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

                // Close Icon
                Positioned(
                  right: -10,
                  top:-10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Dropdown for simple string lists (with search)
  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged, TextEditingController searchController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: value,
            hint: Text('Select $label'),
            items: items
                .map((e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              elevation: 3,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search $label...',
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value
                    .toString()
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Dropdown for map/list data (with search & safe deduplication & null-safety)
  Widget _buildDropdownMap(
      String label,
      Map<String, dynamic>? value,
      List<Map<String, dynamic>> items,
      ValueChanged<Map<String, dynamic>?> onChanged,
      String displayKey,
      TextEditingController searchController) {
    final uniqueItemsMap = <String, Map<String, dynamic>>{};
    for (var e in items) {
      final key = (e[displayKey] ?? '').toString().trim();
      if (!uniqueItemsMap.containsKey(key)) {
        uniqueItemsMap[key] = e;
      }
    }
    final uniqueItems = uniqueItemsMap.values.toList();

    Map<String, dynamic>? selectedValue;
    if (value != null) {
      try {
        selectedValue = uniqueItems.firstWhere(
              (e) =>
          e[displayKey]?.toString().trim() ==
              value[displayKey]?.toString().trim(),
        );
      } catch (e) {
        selectedValue = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton2<Map<String, dynamic>>(
            isExpanded: true,
            value: selectedValue,
            hint: Text('Select $label'),
            items: uniqueItems
                .map(
                  (e) => DropdownMenuItem<Map<String, dynamic>>(
                value: e,
                child: Text(
                  e[displayKey]?.toString() ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              elevation: 3,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search $label...',
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                final val = item.value?[displayKey]?.toString() ?? "";
                return val.toLowerCase().contains(searchValue.toLowerCase());
              },
            ),
          ),
        ),
      ],
    );
  }
}
