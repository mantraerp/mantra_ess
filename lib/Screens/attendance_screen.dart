import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
          appBar: AppBar(title: Text('Attendance'), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: controller.attendanceList.length,
              itemBuilder: (context, index) {
                AttendanceRecord data = controller.attendanceList[index];
                return Card(
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),

                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      spacing: 12,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              data.minopStatus,
                              style: TextStyle(
                                color: data.minopStatus == 'P'
                                    ? appGreen
                                    : appBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.attendanceDate),
                              Text(data.name),
                              if (data.status != 'Present')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Status :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            color: appGrey800,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(data.status),
                                      ],
                                    ),
                                    if (data.leaveType != null)
                                      Row(
                                        children: [
                                          Text(
                                            'Leave Type :',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w200,
                                              color: appGrey800,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(data.leaveType ?? ''),
                                        ],
                                      ),
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
        );
      },
    );
  }
}
