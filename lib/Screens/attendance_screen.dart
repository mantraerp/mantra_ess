import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Controllers/attendance_controller.dart';
import '../Models/attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  AttendanceScreen({super.key});


  Color getStatusColor(String? ms, String? status, String? leaveType) {
    ms = ms ?? "";
    status = status ?? "";
    leaveType = leaveType ?? "";


    if (leaveType == "Leave Without Pay") {
      return Colors.red.shade100;
    }


    if (leaveType.isNotEmpty) {
      return Colors.blue.shade100;
    }


    if (["W", "WH"].contains(ms)) {
      return Colors.orange.shade100;
    }


    if (["H", "HW"].contains(ms)) {
      return Colors.lightBlue.shade100;
    }


    if (ms == "HD" || status == "Half Day") {
      return Colors.yellow.shade200;
    }


    if (["P", "PW", "PH", "WH", "HW"].contains(ms)) {
      return Colors.green.shade100;
    }


    if (["A", "XX", "LH", "E"].contains(ms)) {
      return Colors.red.shade100;
    }

    return Colors.grey.shade200;
  }



  Color getStatusTextColor(String? ms, String? status, String? leaveType) {
    ms = ms ?? "";
    status = status ?? "";
    leaveType = leaveType ?? "";


    if (leaveType == "Leave Without Pay") {
      return Colors.red.shade800;
    }


    if (leaveType.isNotEmpty) {
      return Colors.blue.shade800;
    }


    if (["W", "WH"].contains(ms)) {
      return Colors.orange.shade800;
    }


    if (["H", "HW"].contains(ms)) {
      return Colors.blue.shade900;
    }


    if (ms == "HD" || status == "Half Day") {
      return Colors.amber.shade900;
    }


    if (["P", "PW", "PH", "WH", "HW"].contains(ms)) {
      return Colors.green.shade800;
    }


    if (["A", "XX", "LH", "E"].contains(ms)) {
      return Colors.red.shade800;
    }

    return Colors.black87;
  }


  // Summary card widget with tap for filtering
  Widget summaryCard(String title, String count, Color bgColor, Color textColor,
      VoidCallback onTap,
      {String? extraText}) {
    return Flexible(
      fit: FlexFit.tight,
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (extraText != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: textColor),
                      ),
                      child: Text(
                        extraText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime? parseSafeDate(String? date) {
    try {
      if (date == null || date.isEmpty) return null;
      return DateFormat('dd-MM-yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter Attendance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // From Date Picker
                Obx(() => GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.fromDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) controller.fromDate.value = picked;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "From: ${DateFormat('dd-MM-yyyy').format(controller.fromDate.value)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                )),

                // To Date Picker
                Obx(() => GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.toDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) controller.toDate.value = picked;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "To: ${DateFormat('dd-MM-yyyy').format(controller.toDate.value)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                )),

                // Apply Filter Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Close dialog
                      await controller.getAttendanceList(); // Apply filter
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      "Apply Filter",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Attendance Summary'),
        centerTitle: true,

        actions: [

          IconButton(
            onPressed: () => pickDateRange(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredList = controller.getFilteredList();
        final summary = controller.attendance_count;



        return Padding(

          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  summaryCard('Present', summary['Present'] ?? '0',
                      Colors.green.shade100, Colors.green.shade800, () {
                        controller.filterStatus.value = 'Present';
                      }),
                  summaryCard('Absent', summary['Absent'] ?? '0', Colors.red.shade100,

                      Colors.red.shade800, () {
                        controller.filterStatus.value = 'Absent';
                      }),
                  summaryCard('On Leave', summary['On Leave'] ?? '0', Colors.blue.shade100,
                      Colors.blue.shade800, () {
                        controller.filterStatus.value = 'On Leave';
                      }),

                  summaryCard('Week Off', summary['Week-Off'] ?? '0', Colors.orange.shade100,
                      Colors.orange.shade800, () {
                        controller.filterStatus.value = 'Week-off';
                      }),
                  summaryCard('Total', summary['Total Days'] ?? '0', Colors.grey.shade300,
                      Colors.black87, () {
                        controller.filterStatus.value = 'All';
                      }),
                ],
              ),
              const SizedBox(height: 16),

              // Attendance List
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                  child: Text(
                    "No Attendance Data",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final data = filteredList[index];
                    final date = parseSafeDate(data.attendanceDate);
                    final day = date != null ? DateFormat('dd').format(date) : '';
                    final month = date != null ? DateFormat('MMM').format(date) : '';
                    final year = date != null ? DateFormat('yyyy').format(date) : '';

                    final statusText =
                    data.leaveType != null && data.leaveType!.isNotEmpty
                        ? 'On Leave'
                        : data.minopStatus == 'P'
                        ? 'Present'
                        : data.minopStatus == 'A' || data.status == 'Absent'
                        ? 'Absent'
                        : data.minopStatus == 'W'
                        ? 'Week Off'
                        : data.minopStatus == 'H'
                        ? 'Holiday'
                        : '-';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: getStatusColor(data.minopStatus, data.status,data.leaveType),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: getStatusTextColor(data.minopStatus, data.status,data.leaveType)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left: vertical date in border
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(8),

                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  month,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  year,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right: status text with leave type box
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: getStatusTextColor(
                                        data.minopStatus, data.status,data.leaveType),
                                  ),
                                ),
                              data.minopStatus == 'HD'
                                  ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius:
                                  BorderRadius.circular(4),
                                  border: Border.all(
                                      color: getStatusTextColor(
                                          data.minopStatus,data.status,
                                          data.leaveType)),
                                ),
                                child: Text(
                                  "HD",
                                  style:  TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusTextColor(
                                        data.minopStatus,data.status,
                                        data.leaveType),
                                  ),
                                ),
                              )
                                  : SizedBox(),



                              if (data.leaveType != null &&
                                    data.leaveType!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius:
                                      BorderRadius.circular(4),
                                      border: Border.all(
                                          color: getStatusTextColor(
                                              data.minopStatus,data.status,
                                              data.leaveType)),
                                    ),
                                    child: Text(
                                      data.leaveType!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: getStatusTextColor(
                                            data.minopStatus,data.status,
                                            data.leaveType),
                                      ),
                                    ),
                                  ),
                              ],
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
      }),
    );
  }
}
