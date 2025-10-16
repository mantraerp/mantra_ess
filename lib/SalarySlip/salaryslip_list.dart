import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/appWidget.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'SalarySlipDetailScreen.dart'; // ✅ add this import
import 'dart:io'; // ✅ Required for File
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class salaryslip_list extends StatefulWidget {
  const salaryslip_list({super.key});

  @override
  salaryslip_listState createState() => salaryslip_listState();
}

class salaryslip_listState extends State<salaryslip_list> {
  DateTime? fromDate;
  DateTime? toDate;

  bool serviceCall = false;
  TextEditingController editingController = TextEditingController();
  List<dynamic> items = [];
  List<dynamic> itemsAll = [];
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    // Start of current month
    fromDate = DateTime(now.year, now.month, 1);

    // Today
    toDate = now;

    // Initial load: fetch slips with fromDate and toDate
    loadPendingTourPlan(fromDate: fromDate, toDate: toDate);
  }

  void loadPendingTourPlan({DateTime? fromDate, DateTime? toDate}) {
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
        backgroundColor: appWhite,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Salary Slip',
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: appBlack),
      ),
      body: Container(
        color: appWhite,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              child: searchbar(),
            ),
            const Divider(color: appGray),
            Expanded(child: myListView()),
          ],
        ),
      ),
    );
  }

  // --- Your search bar (same as before) ---
  Widget searchbar() {
    void applyDateFilter() async {
      setState(() => serviceCall = true);
      final response = await apiSalarySlipList(
        fromDate: fromDate,
        toDate: toDate,
      );
      serviceCall = false;
      if (response.runtimeType != bool) {
        setState(() {
          itemsAll = response;
          items = response;
        });
      } else {
        setState(() {});
      }
    }

    String formatDate(DateTime? date, String label) {
      if (date == null) return label;
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }

    Future<void> selectDate(BuildContext context, bool isFrom) async {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          if (isFrom) {
            fromDate = picked;
          } else {
            toDate = picked;
          }
          applyDateFilter();
        });
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 16, top: 5, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),

      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(fromDate, "From Date"),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        fromDate == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(toDate, "To Date"),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        toDate == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LIST VIEW SECTION ---
  Widget myListView() {
    if (serviceCall) {
      return showLoaderText('No Salary Slip Found');
    }
    if (items.isEmpty) {
      // Show friendly message if no salary slips found
      return Center(
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
      );
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: RefreshIndicator(
        color: appGray,
        onRefresh: _getData,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 10, right: 10),
          controller: _controller,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final slip = items[index];
            return GestureDetector(
              onTap: () {
                // Construct a slip object to match your SalarySlipDetailScreen fields
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
                      "salaryComponent": e['salary_component'],
                      "amount": e['amount'],
                    },
                  )
                      .toList(),
                  "deductions":
                  (slip['deductions'] ?? [])
                      .map(
                        (d) => {
                      "salaryComponent": d['salary_component'],
                      "amount": d['amount'],
                    },
                  )
                      .toList(),
                  "netPay": slip['net_pay'] ?? 0,
                  "GrossPay": slip['gross_pay'] ?? 0,
                  "TotalDeduction": slip['total_deduction'] ?? 0,
                  "paymentStatus": slip['payment_status'] ?? 'N/A',
                };


              },
              child: productCell(slip),
            );
          },
        ),
      ),
    );
  }

  Future<void> _getData() async {
    loadPendingTourPlan();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Widget productCell(dynamic slip) {
    // Map payment status to colors
    Color statusColor(String status) {
      switch (status.toLowerCase()) {
        case 'success':
          return Colors.green.shade100;
        case 'initiated':
          return Colors.blue.shade100;
        case 'failed':
          return Colors.red.shade100;
        case 'processed':
          return Colors.orange.shade100;
        default:
          return Colors.grey.shade200;
      }
    }

    Color statusTextColor(String status) {
      switch (status.toLowerCase()) {
        case 'success':
          return Colors.green.shade800;
        case 'initiated':
          return Colors.blue.shade800;
        case 'failed':
          return Colors.red.shade800;
        case 'processed':
          return Colors.orange.shade800;
        default:
          return Colors.grey.shade600;
      }
    }

    final String paymentStatus = slip['payment_status'] ?? 'N/A';
    String formatMonthYear(String? date) {
      if (date == null || date.isEmpty) return '';
      try {
        // Expected input: "01-09-2025"
        final parts = date.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final dt = DateTime(year, month, day);
          final monthName =
          [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ][month - 1];

          return '$monthName $year';
        } else {
          return '';
        }
      } catch (e) {
        return '';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor(paymentStatus),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatMonthYear(slip['start_date']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSalaryInfo(
                      "Gross Pay",
                      slip['gross_pay'],
                      Colors.green.shade700,
                    ),
                    _buildSalaryInfo(
                      "Deductions",
                      slip['total_deduction'],
                      Colors.red.shade700,
                    ),
                    _buildSalaryInfo("Net Pay", slip['net_pay'], Colors.black),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final slipName = slip['name'] ?? '';
                        if (slipName.isEmpty) {
                          showAlert(
                            ApplicationTitle,
                            "Salary slip name missing",
                          );
                          return;
                        }


                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            content: Row(
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Text("Downloading PDF..."),
                              ],
                            ),
                          ),
                        );
                        try {
                          // ✅ Await download and check result
                          File? file = await downloadAndSavePDF(slipName);

                          // Close loading dialog
                          Navigator.pop(context);

                          if (file != null) {

                          } else {
                            showAlert(ApplicationTitle, "Failed to download PDF");
                          }
                        } catch (e) {
                          // Close dialog in case of error
                          Navigator.pop(context);

                        }
                      },
                      icon: const Icon(
                        Icons.download,
                        size: 20,
                        color: Colors.black,
                      ),
                      label: const Text(""),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0, //
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black87,
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
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  SalarySlipDetailScreen(slip: slipData),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
      amount =
      (value is num) ? value.toDouble() : double.parse(value.toString());
    } catch (_) {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}