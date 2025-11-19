import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Models/attendance_model.dart';

class AttendanceController extends GetxController {
  // 🔹 Reactive variables
  RxList<AttendanceRecord> attendanceList = <AttendanceRecord>[].obs;
  RxBool isLoading = false.obs;
  RxMap<String, String> attendance_count = <String, String>{}.obs;

  // 🔹 Last month as default
  DateTime defaultFromDate =
  DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
  DateTime defaultToDate = DateTime(DateTime.now().year, DateTime.now().month, 0);

  Rx<DateTime> fromDate =
      DateTime(DateTime.now().year, DateTime.now().month - 1, 1).obs;
  Rx<DateTime> toDate =
      DateTime(DateTime.now().year, DateTime.now().month, 0).obs;

  // 🔹 Filter status (All, Present, Absent, Half Day, On Leave, Week-off)
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
        if (res.attendance_count != null && res.attendance_count!.isNotEmpty) {
          attendance_count.value = {
            'Present': res.attendance_count!['Present'] ?? '0',
            'Absent': res.attendance_count!['Absent'] ?? '0',
            'On Leave': res.attendance_count!['On Leave'] ?? '0',
            'Half Day': res.attendance_count!['Half Day'] ?? '0',
            'Week-Off': res.attendance_count!['Week-off'] ?? '0',
            'Holiday': res.attendance_count!['Holiday'] ?? '0',
            'Total Days': res.attendance_count!['Total Days'] ?? '0',
          };
        } else {
          attendance_count.clear();
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

  // 🔹 Helper: Compare dates ignoring time
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void onInit() {
    super.onInit();
    getAttendanceList();
  }
}
