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


  List<AttendanceRecord> getFilteredList() {
    if (filterStatus.value == 'All') return attendanceList;

    return attendanceList.where((att) {
      String ms = att.minopStatus ?? "";
      String status = att.status ?? "";
      String leave = att.leaveType ?? "";

      switch (filterStatus.value) {
        case 'Present':
          return (["P","PW","PH","HW"].contains(ms) && status == "Present")
              || (["P","PW","PH","WH","HW"].contains(ms) && status.isEmpty);

        case 'Week-off':
          return ["W","WH"].contains(ms);

        case 'Half Day':
          return
            (["P","PW","PH","W","WH","H","HW"].contains(ms) && status == "Half Day") ||
                (ms == "HD") ||
                (["A","XX","LH","E"].contains(ms) &&
                    leave.isNotEmpty && leave != "Leave Without Pay" &&
                    status == "Half Day");
        case 'Absent':
          return
            (["A","XX","E"].contains(ms)) ||
                (ms == "LH" && status == "Absent" && leave != "Leave Without Pay") ||
                (["P","PW","PH","W","WH","H","HW"].contains(ms) &&
                    status == "On Leave" && leave == "Leave Without Pay") ||
                (ms == "HD" && leave == "Leave Without Pay");

        case 'On Leave':
          return
            (["TL","CL","SL","WL","ML","BL","BR","LL","CO","EL","OD","LC"]
                .contains(ms)) ||
                (ms == "HD" && leave != "Leave Without Pay") ||
                (["A","XX","LH","E"].contains(ms) &&
                    leave.isNotEmpty && leave != "Leave Without Pay" &&
                    status == "Present") ||
                (["P","PW","PH","WH","HW"].contains(ms) &&
                    status == "On Leave" &&
                    leave.isNotEmpty && leave != "Leave Without Pay");
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
