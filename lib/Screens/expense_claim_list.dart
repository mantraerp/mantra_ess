import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mantra_ess/Screens/api_dropdown.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ExpenseClaimScreen extends StatefulWidget {
  const ExpenseClaimScreen({super.key});

  @override
  State<ExpenseClaimScreen> createState() => _ExpenseClaimScreenState();
}

class _ExpenseClaimScreenState extends State<ExpenseClaimScreen> {
  List<dynamic> allExpenses = [];
  List<dynamic> filteredExpenses = [];
  List<String> expenseTypes = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? expenseClaimName; // will hold current claim ID
  String? attachmentUrl;  // will hold uploaded file URL

  @override
  void initState() {
    super.initState();
    fetchExpenseClaims(_focusedDay);
    fetchExpenseTypes();
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Fetch Expense Types for dropdown
  Future<void> fetchExpenseTypes() async {
    try {
      final sid = box.read(SID);
      final url = Uri.parse(
          "$GetMasterList?doctype=Expense Claim Type&search_text=");

      final response = await http.get(url, headers: {'Cookie': 'sid=$sid'});
      final data = jsonDecode(response.body);
      if (data["data"] != null) {
        setState(() {
          expenseTypes = List<String>.from(data["data"]);
        });
      }
    } catch (e) {
      debugPrint("Error fetching expense types: $e");
    }
  }

  /// Fetch Expense Claims (monthly)
  Future<void> fetchExpenseClaims(DateTime monthDate) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);
    final dateFormat = DateFormat("dd-MM-yyyy");

    try {
      final res = await apiExpenseClaimList(
        dateFormat.format(firstDay),
        dateFormat.format(lastDay),
        0,
      );

      if (res != null && res['data'] != null) {
        final seen = <String>{};
        final List<dynamic> temp = [];

        for (var exp in res['data']) {
          if (exp['expenses'] != null) {
            for (var e in exp['expenses']) {
              // Build a unique key string for each expense
              final key =
                  "${e['name']}";

              if (!seen.contains(key)) {
                seen.add(key);
                temp.add(e);
              }
            }
          }
        }

        setState(() {
          allExpenses.clear();
          allExpenses.addAll(temp);
          _filterExpensesForSelectedDay();
          isLoading = false;
        });
      }

      else {
        setState(() {
          allExpenses = [];
          filteredExpenses = [];
          isLoading = false;
          errorMessage = 'No expense data found for this month';
        });
      }
    } catch (e) {
      setState(() {
        allExpenses = [];
        filteredExpenses = [];
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  /// Filter expenses for selected day
  void _filterExpensesForSelectedDay() {
    setState(() {
      filteredExpenses = allExpenses.where((item) {
        try {
          DateTime date = DateFormat("dd-MM-yyyy")
              .parse(item['expense_date'], true)
              .toLocal();
          expenseClaimName=item['name'];
          return _normalizeDate(date) == _normalizeDate(_selectedDay);
        } catch (_) {
          return false;
        }
      }).toList();
    });
  }

  /// Daily totals for calendar
  Map<DateTime, double> _getDailyTotals() {
    Map<DateTime, double> totals = {};
    for (var e in allExpenses) {
      try {
        DateTime date =
        DateFormat("dd-MM-yyyy").parse(e['expense_date'], true).toLocal();
        date = _normalizeDate(date);
        totals[date] = (totals[date] ?? 0) + (e['amount'] ?? 0.0);
      } catch (_) {}
    }
    return totals;
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      _focusedDay = newDate;
    });
    fetchExpenseClaims(newDate);
  }

  Future<void> _deleteExpense(String rowName, {String? expenseClaim}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Confirm Delete",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return; // user cancelled

    try {

      final sid = box.read(SID);
      final expenseClaimID = expenseClaim ?? '';
      expenseClaimName = expenseClaimID ?? '';
      final res = await http.post(
        Uri.parse("$DeleteExpenseClaim?row=$rowName&expense_claim=$expenseClaimID"),
        headers: {"Content-Type": "application/json",'Cookie': 'sid=$sid'},

      );



      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Expense deleted successfully",
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        fetchExpenseClaims(_focusedDay);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${data['message'] ?? 'Error deleting expense'}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text("Error deleting expense: $e")),
      );
    }
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _filterExpensesForSelectedDay();
  }

  /// --------------------------
  /// 🟣 ADD EXPENSE DIALOG
  /// --------------------------
  // void _showAddExpenseDialog() {
  //   final TextEditingController descriptionController = TextEditingController();
  //   final TextEditingController amountController = TextEditingController();
  //   String? selectedType;
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Dialog(
  //       insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: StatefulBuilder(
  //         builder: (context, setState) => Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Header
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       "Add Expense Claim",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w700,
  //                         color: Colors.indigo,
  //                         fontSize: 18,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close_rounded, color: Colors.grey),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(height: 10, thickness: 1),
  //
  //                 const SizedBox(height: 15),
  //
  //                 // Expense Type
  //                 ApiDropdown(
  //                   label: "Expense Type",
  //                   apiUrl:
  //                   "$GetMasterList?doctype=Expense Claim Type&search_text=",
  //                   prefixIcon: Icons.category_outlined,
  //                   onChanged: (val) => selectedType = val,
  //                   validator: (value) =>
  //                   value == null ? "Select an expense type" : null,
  //                 ),
  //                 const SizedBox(height: 18),
  //
  //                 // Description
  //                 TextFormField(
  //                   controller: descriptionController,
  //                   decoration: InputDecoration(
  //                     labelText: "Description",
  //                     hintText: "Enter description of expense",
  //                     prefixIcon: const Icon(Icons.notes_outlined),
  //                     filled: true,
  //                     fillColor: Colors.grey.shade50,
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(color: Colors.grey, width: 1.0),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(color: Colors.grey, width: 1.2),
  //                     ),
  //                   ),
  //                   maxLines: 3,
  //                 ),
  //                 const SizedBox(height: 18),
  //
  //                 // Amount
  //                 TextFormField(
  //                   controller: amountController,
  //                   keyboardType: TextInputType.number,
  //                   decoration: InputDecoration(
  //                     labelText: "Amount",
  //                     hintText: "Enter amount (₹)",
  //                     prefixIcon: const Icon(Icons.currency_rupee),
  //                     filled: true,
  //                     fillColor: Colors.grey.shade50,
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(color: Colors.grey, width: 1.0),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(color: Colors.grey, width: 1.1),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 25),
  //
  //                 // Buttons
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       style: TextButton.styleFrom(
  //                         foregroundColor: Colors.grey.shade600,
  //                       ),
  //                       child: const Text("Cancel"),
  //                     ),
  //                     const SizedBox(width: 10),
  //                     ElevatedButton.icon(
  //                       onPressed: () async {
  //                         if (selectedType == null ||
  //                             descriptionController.text.isEmpty ||
  //                             amountController.text.isEmpty) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                                 content:
  //                                 Text("Please fill all required fields.")),
  //                           );
  //                           return;
  //                         }
  //
  //                         Navigator.pop(context);
  //
  //                         await _handleExpenseSave(
  //                           selectedType!,
  //                           descriptionController.text,
  //                           double.tryParse(amountController.text) ?? 0.0,
  //                         );
  //                       },
  //                       icon: const Icon(Icons.save_rounded, size: 20),
  //                       label: const Text("Save"),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.indigo,
  //                         foregroundColor: Colors.white,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  void _showAddExpenseDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String? selectedType;
    String? uploadedFileUrl;
    bool isUploading = false;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Expense Claim",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 10, thickness: 1),
                  const SizedBox(height: 15),

                  // Expense Type
                  ApiDropdown(
                    label: "Expense Type",
                    apiUrl: "$GetMasterList?doctype=Expense Claim Type&search_text=",
                    prefixIcon: Icons.category_outlined,
                    onChanged: (val) => selectedType = val,
                    validator: (value) => value == null ? "Select an expense type" : null,
                  ),
                  const SizedBox(height: 18),

                  // Description
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Enter description of expense",
                      prefixIcon: const Icon(Icons.notes_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),

                  // Amount
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      hintText: "Enter amount (₹)",
                      prefixIcon: const Icon(Icons.currency_rupee),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // File Upload Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (isUploading || uploadedFileUrl != null)
                              ? null
                              : () async {
                            final result = await FilePicker.platform.pickFiles();
                            if (result == null || result.files.isEmpty) return;

                            final file = result.files.first;
                            final sid = box.read("sid");

                            setState(() => isUploading = true);

                            try {
                              var formData = FormData.fromMap({
                                "doctype": "Expense Claim Detail",
                                "docname": expenseClaimName ?? '1',
                                "fieldname": "custom_attachment",
                                "private": 1,
                                "files": await MultipartFile.fromFile(
                                  file.path!,
                                  filename: file.name,
                                ),
                              });

                              var dio = Dio();

                              var response = await dio.post(
                                "$uploadAttachment",
                                data: formData,
                                options: Options(headers: {"Cookie": "sid=$sid"}),
                              );

                              if (response.statusCode == 201) {
                                var fileUrl = response.data["data"]?["file_url"] ??
                                    response.data["file_url"];
                                setState(() {
                                  uploadedFileUrl = fileUrl;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("File uploaded successfully ✅")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Upload failed: ${response.statusMessage}")),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                    Text("Error uploading file: $e")),
                              );
                            } finally {
                              setState(() => isUploading = false);
                            }
                          },
                          icon: isUploading
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.attach_file),
                          label: Text(
                            uploadedFileUrl == null
                                ? "Upload Attachment"
                                : "Attachment Uploaded ✅",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: uploadedFileUrl == null
                                ? Colors.blueAccent.shade400
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (uploadedFileUrl != null) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red.shade600,
                          child: isDeleting
                              ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                            onPressed: () async {
                              final sid = box.read("sid");
                              setState(() => isDeleting = true);
                              try {
                                var response = await Dio().post(
                                  "$DeleteAttachment",
                                  data: {
                                    "file_url": uploadedFileUrl,
                                    "doctype": "Expense Claim Detail",
                                    "docname": expenseClaimName ?? '1',
                                  },
                                  options: Options(
                                      headers: {"Cookie": "sid=$sid"}),
                                );

                                if (response.statusCode == 202) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text("File deleted successfully ❌")),
                                  );
                                  setState(() {
                                    uploadedFileUrl = null;
                                  });
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                      Text("Error deleting file: $e")),
                                );
                              } finally {
                                setState(() => isDeleting = false);
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Save / Cancel Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedType == null ||
                              descriptionController.text.isEmpty ||
                              amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all required fields."),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          await _handleExpenseSave(
                            selectedType!,
                            descriptionController.text,
                            double.tryParse(amountController.text) ?? 0.0,
                            uploadedFileUrl,
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// --------------------------
  /// 🟠 Handle Save Logic
  /// --------------------------
  Future<void> _handleExpenseSave(
      String type, String description, double amount, String? attachmentUrl) async {
    try {
      final String employee = box.read('employee_code');
      final formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDay);

      final getUrl = Uri.parse(
          "$GetExpenseClaimName?date=$formattedDate&employee=$employee");
      final getResponse = await http.get(getUrl);
      final getData = jsonDecode(getResponse.body);

      if (getResponse.statusCode == 200 &&
          getData["data"] != null &&
          getData["data"].toString().isNotEmpty) {
        final existingClaimName = getData["data"];

        await _createExpenseClaim(
          type: type,
          description: description,
          amount: amount,
          attachmentUrl: attachmentUrl,
          expenseClaimName: existingClaimName,
        );
      } else {
        await _createExpenseClaim(
          type: type,
          description: description,
          amount: amount,
          attachmentUrl: attachmentUrl
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking expense claim: $e")),
      );
    }

  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else {
      openAppSettings();
      return false;
    }
  }



  /// --------------------------
  /// 🔵 Create / Update Claim
  /// --------------------------
  Future<void> _createExpenseClaim({
    required String type,
    required String description,
    required double amount,
    String? expenseClaimName,
    String? attachmentUrl,
  }) async {
    try {
      final endpoint =
          "$CreateExpenseClaim";
      final formattedDate = DateFormat("dd-MM-yyyy").format(_selectedDay);

      final body = {
        "employee": box.read('employee_code'),
        "posting_date":formattedDate,
        "expenses": [
          {
            "expense_type": type,
            "description": description,
            "amount": amount,
            "sanctioned_amount": amount,
            "expense_date": DateFormat("yyyy-MM-dd").format(_selectedDay),
            "custom_attachment": attachmentUrl
          }
        ]
      };
      final sid = box.read(SID);
      Uri url = expenseClaimName != null
          ? Uri.parse("$endpoint?name=$expenseClaimName")
          : Uri.parse(endpoint);

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json",'Cookie': 'sid=$sid'},
        body: jsonEncode(body),
      );


      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Expense Claim saved successfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        fetchExpenseClaims(_focusedDay);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${data['message'] ?? 'Error'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating expense claim: $e")),
      );
    }
  }

  /// --------------------------
  /// 🟢 UI BUILD
  /// --------------------------
  @override
  Widget build(BuildContext context) {
    final dailyTotals = _getDailyTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Calendar'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(DateTime.now().year - 2, 1, 1),
              lastDay: DateTime(DateTime.now().year + 2, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
              _normalizeDate(day) == _normalizeDate(_selectedDay),
              onDaySelected: _onDaySelected,
              onPageChanged: _onMonthChanged,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: Colors.indigo),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: Colors.indigo),
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final normalizedDay = _normalizeDate(day);
                  final total = dailyTotals[normalizedDay];
                  return _buildDayCell(day, total);
                },
                todayBuilder: (context, day, _) {
                  final normalizedDay = _normalizeDate(day);
                  final total = dailyTotals[normalizedDay];
                  return _buildDayCell(day, total, isToday: true);
                },
                selectedBuilder: (context, day, _) {
                  final normalizedDay = _normalizeDate(day);
                  final total = dailyTotals[normalizedDay];
                  return _buildDayCell(day, total, isSelected: true);
                },
              ),
            ),
          ),

          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
              child: Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'No expenses for this day',
                style: const TextStyle(
                    fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                var exp = filteredExpenses[index];
                DateTime date = DateFormat("dd-MM-yyyy")
                    .parse(exp['expense_date'], true)
                    .toLocal();
                String formattedDate =
                DateFormat("d MMM, yyyy").format(date);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Stack(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8EAF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.receipt_long, color: Colors.indigo, size: 24),
                          ),
                        ),
                        title: Text(exp['expense_type'] ?? ''),
                        subtitle: Text('${exp['description'] ?? ''}\n$formattedDate'),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '₹${exp['amount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),

                      // 🔴 DELETE BUTTON (top-right)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            // Determine whether to delete row or entire claim
                            if (filteredExpenses.length > 1) {
                              _deleteExpense(exp['name']);
                            } else {
                              // Delete entire claim if only one row for that day
                              final claimId = exp['parent']; // Expense Claim ID
                              _deleteExpense(exp['name'], expenseClaim: claimId);
                            }
                          },
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar day cell
  Widget _buildDayCell(DateTime day, double? total,
      {bool isToday = false, bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? Colors.indigo.shade200
            : isToday
            ? Colors.indigo.shade50
            : Colors.transparent,
        border:
        isToday ? Border.all(color: Colors.indigo, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${day.day}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (total != null)
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
