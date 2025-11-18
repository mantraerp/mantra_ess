import 'package:flutter/material.dart';
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
          appBar: AppBar(
            title: Text('Profile'),
            centerTitle: true,

          ),
          body: controller.profileData != null
              ? SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (controller.profileData?.value.image != null &&
                      controller.profileData!.value.image.isNotEmpty)
                      ? NetworkImage(
                    controller.profileData!.value.image,
                    headers: controller.getImageHeaders(),
                  )
                      : null, // no image
                  child: (controller.profileData?.value.image == null ||
                      controller.profileData!.value.image.isEmpty)
                      ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  )
                      : null,
                ),

                SizedBox(height: 12),
                Text(
                  controller.profileData!.value.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  controller.profileData!.value.designation,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    dataTile('Gender', controller.profileData!.value.gender),
                    dataTile('Birth Date', controller.profileData!.value.birthDate),
                    dataTile('Email', controller.profileData!.value.email),
                    dataTile('Employee Code', controller.profileData!.value.employeeCode),
                    dataTile('Mobile Number', controller.profileData!.value.mobileNo),
                    dataTile('Phone', controller.profileData!.value.phone),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
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
              ],
            ),
          )
              : Center(child: Text('No data available')),
        );
      },
    );
  }

  Card dataTile(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Flexible(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              apiLogout();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
