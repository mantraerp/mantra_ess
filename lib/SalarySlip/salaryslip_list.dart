import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/appWidget.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'SalarySlipDetailScreen.dart'; // ✅ add this import
import 'dart:io'; // ✅ Required for File
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SalarySlipList extends StatefulWidget {
  const SalarySlipList({super.key});

  @override
  _SalarySlipListState createState() => _SalarySlipListState();
}

class _SalarySlipListState extends State<SalarySlipList> {
  DateTime? fromDate;
  DateTime? toDate;

  bool serviceCall = false;
  List<dynamic> items = [];
  List<dynamic> itemsAll = [];
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // Default filter: last month
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month - 1, 1);
    toDate = DateTime(now.year, now.month, 0); // last day of previous month

    // Initial load
    loadSalarySlips();
  }

  void loadSalarySlips() {
    if (serviceCall) return;
    setState(() => serviceCall = true);

    apiSalarySlipList(fromDate: fromDate, toDate: toDate).then((response) {
      serviceCall = false;
      if (response.runtimeType != bool) {
        setState(() {
          itemsAll = response;
          items = response;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(


        centerTitle: true,
        title: const Text(
          'Salary Slip',
          style: TextStyle(
            color: appBlack,

            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: appBlack),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterDialog(),
          ),
        ],
      ),
      body: Container(
        color: appWhite,
        child: serviceCall
            ? showLoaderText('Loading Salary Slips...')
            : items.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'No salary slip found',
              style: const TextStyle(
                fontSize: 16,
                color: appGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
            : RefreshIndicator(
          color: appGray,
          onRefresh: _getData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            controller: _controller,
            itemCount: items.length,
            itemBuilder: (context, index) => salarySlipCard(items[index]),
          ),
        ),
      ),
    );
  }

  Future<void> _getData() async {
    loadSalarySlips();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// --- FILTER DIALOG ---
  void showFilterDialog() {
    DateTime? tempFrom = fromDate;
    DateTime? tempTo = toDate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with X button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Salary Slips",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date pickers
              _buildDatePicker("From Date", tempFrom, (date) => tempFrom = date),
              const SizedBox(height: 15),
              _buildDatePicker("To Date", tempTo, (date) => tempTo = date),
              const SizedBox(height: 25),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      fromDate = tempFrom;
                      toDate = tempTo;
                      loadSalarySlips();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 48),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        DateTime now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}",
              style: TextStyle(fontSize: 14, color: date == null ? Colors.grey : Colors.black87),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// --- SALARY SLIP CARD ---
  Widget salarySlipCard(dynamic slip) {
    final String paymentStatus = slip['payment_status'] ?? 'N/A';

    LinearGradient statusGradient(String status) {
      switch (status.toLowerCase()) {
        case 'success':
          return const LinearGradient(colors: [Colors.green, Colors.greenAccent]);
        case 'initiated':
          return const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]);
        case 'failed':
          return const LinearGradient(colors: [Colors.red, Colors.redAccent]);
        case 'processed':
          return const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]);
        default:
          return const LinearGradient(colors: [Colors.grey, Colors.grey]);
      }
    }

    Color statusTextColor(String status) {
      switch (status.toLowerCase()) {
        case 'success':
          return Colors.white;
        case 'initiated':
          return Colors.white;
        case 'failed':
          return Colors.white;
        case 'processed':
          return Colors.white;
        default:
          return Colors.white;
      }
    }

    String formatMonthYear(String? date) {
      if (date == null || date.isEmpty) return '';
      try {
        final parts = date.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final monthName = [
            'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
            'September', 'October', 'November', 'December',
          ][month - 1];
          return '$monthName $year';
        }
        return '';
      } catch (e) {
        return '';
      }
    }



    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade400]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatMonthYear(slip['start_date']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor(paymentStatus),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amounts Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSalaryInfo("Gross Pay", slip['gross_pay'], Colors.green.shade700),
                    _buildSalaryInfo("Deductions", slip['total_deduction'], Colors.red.shade700),
                    _buildSalaryInfo("Net Pay", slip['net_pay'], Colors.black87),
                  ],
                ),
                const SizedBox(height: 16),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final slipName = slip['name'] ?? '';
                        if (slipName.isEmpty) {
                          showAlert(ApplicationTitle, "Salary slip name missing");
                          return;
                        }

                        try {
                          File? file = await downloadAndSavePDF(slipName);
                          Navigator.pop(context);
                          if (file == null) {
                            showAlert(ApplicationTitle, "Failed to download PDF");
                          }
                        } catch (e) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.download, size: 20, color: Colors.white),
                      label: const Text(""),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () {
                          final slipData = {
                            "name": slip['name'] ?? '',
                            "employeeName": slip['employee_name'] ?? '',
                            "PaymentDays": slip['payment_days'] ?? '',
                            "WorkingDays": slip['working_days'] ?? '',
                            "startDate": slip['start_date'] ?? '',
                            "endDate": slip['end_date'] ?? '',
                            "earnings":
                            (slip['earnings'] ?? [])
                                .map(
                                  (e) => {
                                "salaryComponent":
                                e['salary_component'],
                                "amount": e['amount'],
                              },
                            )
                                .toList(),
                            "deductions":
                            (slip['deductions'] ?? [])
                                .map(
                                  (d) => {
                                "salaryComponent":
                                d['salary_component'],
                                "amount": d['amount'],
                              },
                            )
                                .toList(),
                            "netPay": slip['net_pay'] ?? 0,
                            "GrossPay": slip['gross_pay'] ?? 0,
                            "TotalDeduction": slip['total_deduction'] ?? 0,
                            "paymentStatus": slip['payment_status'] ?? 'N/A',
                          };
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SalarySlipDetailScreen(slip: slipData)),
                        );
                      },


                    ),
    )],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSalaryInfo(String label, dynamic value, Color color) {
    double amount = 0;
    try {
      amount = value is num ? value.toDouble() : double.parse(value.toString());
    } catch (_) {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
