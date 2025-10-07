import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

import 'SalarySlip/salaryslip_list.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  bool serviceCall = false;

  @override
  void initState() {
    super.initState();

    _getDashboradMenuOption();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: false,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1,
          ),
          itemCount: 18,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                onTap: () {
                  //TODO: Open cards
                  Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (
                          context) => salaryslip_list()));


                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForIndex(index),
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getTitleForIndex(index),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.dashboard,
      Icons.person,
      Icons.calendar_today,
      Icons.access_time,
      Icons.assignment,
      Icons.bar_chart,
      Icons.notifications,
      Icons.settings,
      Icons.folder,
      Icons.payment,
      Icons.help,
      Icons.info,
      Icons.notifications,
      Icons.settings,
      Icons.folder,
      Icons.payment,
      Icons.help,
      Icons.info,
    ];
    return icons[index % icons.length];
  }

  String _getTitleForIndex(int index) {
    final titles = [
      'Attendance Register',
      'Leave Application',
      'Expenses List',
      'Visit Salon',
      'Salon List',
      'KYC Create',
      'Technical Activity',
      'Sample Requisition',
      'Travel & Beat Plan',
      'Travel Plan Approve',
      'Create Order',
      'Cumulative Offer',
      'Distributor List',
      'Sales Order List',
      'Return Create',
      'RSM Order List',
      'Employee Information',
      'Visit EBO',
    ];
    return titles[index % titles.length];
  }

  _getDashboradMenuOption() async {
    if (serviceCall) {
      return;
    }
    setState(() {
      serviceCall = true;
    });

    apiGetDashboardMenu().then((response) {
      serviceCall = false;
      if (response.runtimeType == bool) {
        setState(() {});
      } else {
        var allKeys = response.keys;
      }
    });
  }
}
