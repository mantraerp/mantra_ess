import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Models/attendance_model.dart';
import 'package:mantra_ess/Utils.dart';

class AttendanceController extends GetxController {
  RxList<AttendanceRecord> attendanceList = RxList.empty();

  DateTime defaultFromDate = DateTime.now().subtract(Duration(days: 30));
  DateTime defaultToDate = DateTime.now();

  Rx<DateTime> fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  Rx<DateTime> toDate = DateTime.now().obs;

  RxBool get isFilter =>
      (!isSameDate(fromDate.value, defaultFromDate) ||
              !isSameDate(toDate.value, defaultToDate))
          .obs;

  Map<String, String> getFormattedDateTime() {
    final formattedFromDate = DateFormat('dd-MM-yyyy').format(fromDate.value);
    final formattedToDate = DateFormat('dd-MM-yyyy').format(toDate.value);
    return {'fromDate': formattedFromDate, 'toDate': formattedToDate};
  }

  void getAttendanceList() async {
    final formattedDates = getFormattedDateTime();
    final res = await apiGetAttendance(
      formattedDates['fromDate'] ?? '',
      formattedDates['toDate'] ?? '',
    );
    if (res is AttendanceResponse) {
      attendanceList.value = res.data;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getAttendanceList();
  }
}
