import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Models/attendance_model.dart';
import 'package:mantra_ess/utils.dart';

class AttendanceController extends GetxController {
  // 🔹 Reactive variables
  RxList<AttendanceRecord> attendanceList = <AttendanceRecord>[].obs;
  RxBool isLoading = false.obs;
  RxMap<String, int> summary = <String, int>{}.obs;

  DateTime defaultFromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime defaultToDate = DateTime.now();

  Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  Rx<DateTime> toDate = DateTime.now().obs;

  // 🔹 Filter status (All, Present, Absent, Half Day, On Leave)
  RxString filterStatus = 'All'.obs;

  // 🔹 Reactive filter state for date range
  RxBool get isFilter =>
      (!isSameDate(fromDate.value, defaultFromDate) ||
          !isSameDate(toDate.value, defaultToDate))
          .obs;

  // 🔹 Format dates for API call
  Map<String, String> getFormattedDateTime() {
    final formattedFromDate = DateFormat('dd-MM-yyyy').format(fromDate.value);
    final formattedToDate = DateFormat('dd-MM-yyyy').format(toDate.value);
    return {'fromDate': formattedFromDate, 'toDate': formattedToDate};
  }

  // 🔹 Fetch attendance list and summary
  Future<void> getAttendanceList() async {
    try {
      isLoading.value = true;
      final formattedDates = getFormattedDateTime();

      final res = await apiGetAttendance(
        formattedDates['fromDate'] ?? '',
        formattedDates['toDate'] ?? '',
      );

      if (res is AttendanceResponse) {
        // Attendance data
        attendanceList.value = res.data;

        // ✅ Handle summary safely
        if (res.summary != null && res.summary.isNotEmpty) {
          summary.value = {
            'Present': res.summary['Present'] ?? 0,
            'Absent': res.summary['Absent'] ?? 0,
            'On Leave': res.summary['On Leave'] ?? 0,
            'Half Day': res.summary['Half Day'] ?? 0,
            'Total Days': res.summary['Total Days'] ?? 0,
            'Week-Off': res.summary[ "Week-off"] ?? 0,
          };
        } else {
          summary.clear();
        }

        // Reset filter to 'All' whenever new data is fetched
        filterStatus.value = 'All';
      }
    } catch (e) {
      print('❌ Error fetching attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Utility: Filtered attendance list based on filterStatus
  List<AttendanceRecord> getFilteredList() {
    if (filterStatus.value == 'All') return attendanceList;
    return attendanceList.where((att) {
      switch (filterStatus.value) {
        case 'Present':
          return att.minopStatus == 'P';
        case 'Week-off':
          return att.minopStatus == 'W';
        case 'Absent':
          return att.minopStatus == 'A';
        case 'Half Day':
          return att.minopStatus == 'PW';
        case 'On Leave':
          return att.leaveType != null && att.leaveType!.isNotEmpty;
        default:
          return true;
      }
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getAttendanceList();
  }
}
