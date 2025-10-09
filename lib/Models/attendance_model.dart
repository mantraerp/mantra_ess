// To parse this JSON data, use
//
//     final attendanceResponse = attendanceResponseFromJson(jsonString);

import 'dart:convert';

AttendanceResponse attendanceResponseFromJson(String str) =>
    AttendanceResponse.fromJson(json.decode(str));

String attendanceResponseToJson(AttendanceResponse data) =>
    json.encode(data.toJson());

class AttendanceResponse {
  String message;
  List<AttendanceRecord> data;
  int statusCode;

  AttendanceResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceResponse(
        message: json["message"],
        data: List<AttendanceRecord>.from(
          json["data"].map((x) => AttendanceRecord.fromJson(x)),
        ),
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status_code": statusCode,
  };
}

class AttendanceRecord {
  String name;
  String employeeName;
  String attendanceDate;
  String employeeCode;
  String status;
  String? leaveType;
  String minopStatus;

  AttendanceRecord({
    required this.name,
    required this.employeeName,
    required this.attendanceDate,
    required this.employeeCode,
    required this.status,
    this.leaveType,
    required this.minopStatus,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        name: json["name"],
        employeeName: json["employee_name"],
        attendanceDate: json["attendance_date"],
        employeeCode: json["employee_code"],
        status: json["status"],
        leaveType: json["leave_type"],
        minopStatus: json["minop_status"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "employee_name": employeeName,
    "attendance_date": attendanceDate,
    "employee_code": employeeCode,
    "status": status,
    "leave_type": leaveType,
    "minop_status": minopStatus,
  };
}
