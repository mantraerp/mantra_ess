// To parse this JSON data, use
//
//     final userProfileResponse = userProfileResponseFromJson(jsonString);

import 'dart:convert';

UserProfileResponse userProfileResponseFromJson(String str) =>
    UserProfileResponse.fromJson(json.decode(str));

String userProfileResponseToJson(UserProfileResponse data) =>
    json.encode(data.toJson());

class UserProfileResponse {
  String message;
  UserProfileData data;
  int statusCode;

  UserProfileResponse({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        message: json["message"],
        data: UserProfileData.fromJson(json["data"]),
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data.toJson(),
    "status_code": statusCode,
  };
}

class UserProfileData {
  String fullName;
  String email;
  String employeeCode;
  String designation;
  String gender;
  String phone;
  String mobileNo;
  String image;
  String birthDate;

  UserProfileData({
    required this.fullName,
    required this.email,
    required this.employeeCode,
    required this.designation,
    required this.gender,
    required this.phone,
    required this.mobileNo,
    required this.image,
    required this.birthDate,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      UserProfileData(
        fullName: json["full_name"],
        email: json["email"],
        employeeCode: json["employee_code"],
        designation: json["designation"],
        gender: json["gender"],
        phone: json["phone"],
        mobileNo: json["mobile_no"],
        image: json["image"],
        birthDate: json["birth_date"],
      );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "email": email,
    "employee_code": employeeCode,
    "designation": designation,
    "gender": gender,
    "phone": phone,
    "mobile_no": mobileNo,
    "image": image,
    "birth_date": birthDate,
  };
}
