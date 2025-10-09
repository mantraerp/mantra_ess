import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Controllers/attendance_controller.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Models/attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AttendanceController>(
      init: AttendanceController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Attendance'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 90),
                      ),
                      lastDate: DateTime.now(),
                    ).then((pickedRange) {
                      if (pickedRange != null) {
                        controller.fromDate.value = pickedRange.start;
                        controller.toDate.value = pickedRange.end;
                        controller.getAttendanceList();
                      }
                    });
                  },
                  child: Icon(Icons.filter_alt, size: 24, color: appText),
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              if (controller.isFilter.value)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateFormat('dd-MM-yyyy').format(controller.fromDate.value)} to ${DateFormat('dd-MM-yyyy').format(controller.toDate.value)}',
                        style: TextStyle(color: appWhite, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.fromDate.value =
                              controller.defaultFromDate;
                          controller.toDate.value = controller.defaultToDate;
                          controller.getAttendanceList();
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: appWhite, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: controller.attendanceList.length,
                    itemBuilder: (context, index) {
                      AttendanceRecord data = controller.attendanceList[index];
                      DateTime dateTime = DateFormat(
                        'dd-MM-yyyy',
                      ).parse(data.attendanceDate);
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        color: data.minopStatus == 'P'
                            ? appGreen
                            : data.minopStatus == 'W'
                            ? appYellow
                            : appBlue,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 12,
                            children: [
                              SizedBox(
                                // width: 50,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('EEE').format(dateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: appText,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd').format(dateTime),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: appText,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMM, yyyy',
                                        ).format(dateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: appText,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.minopStatus == 'W'
                                          ? 'Week Off'
                                          : data.status,
                                    ),
                                    if (data.leaveType != null)
                                      Row(
                                        children: [
                                          Text(
                                            'Leave Type :',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                255,
                                                83,
                                                83,
                                                83,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(data.leaveType ?? ''),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
