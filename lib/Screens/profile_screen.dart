import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mantra_ess/Controllers/profile_controller.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text('Profile'), centerTitle: true),
          body: controller.profileData != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            controller.profileData?.value.image ?? '',
                            headers: controller.getImageHeaders(),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),

                        Text(
                          controller.profileData!.value.fullName,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          controller.profileData!.value.designation,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          dataTile(
                            'Gender',
                            controller.profileData!.value.gender,
                          ),
                          dataTile(
                            'Birth Date',
                            controller.profileData!.value.birthDate,
                          ),
                          dataTile(
                            'Email',
                            controller.profileData!.value.email,
                          ),
                          dataTile(
                            'Employee Code',
                            controller.profileData!.value.employeeCode,
                          ),
                          dataTile(
                            'Mobile Number',
                            controller.profileData!.value.mobileNo,
                          ),
                          dataTile(
                            'Phone',
                            controller.profileData!.value.phone,
                          ),
                        ],
                      ),
                    ),
                    Spacer(flex: 1),
                    GestureDetector(
                      onTap: () => apiLogout(),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: appWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                )
              : Center(child: Text('No data')),
        );
      },
    );
  }

  Card dataTile(String title, String value) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
