import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mantra_ess/Controllers/dashboard_controller.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/SalarySlip/salaryslip_list.dart';
import 'package:mantra_ess/Screens/attendance_screen.dart';
import 'package:mantra_ess/Screens/profile_screen.dart';
import 'package:mantra_ess/Screens/scanner_screen.dart';
import 'package:mantra_ess/Screens/purchase_order_screen.dart';
import 'package:mantra_ess/Screens/sales_order_screen.dart';
import 'package:mantra_ess/Screens/sales_invoice_screen.dart';
import 'package:mantra_ess/Screens/purchase_receipt_screen.dart';
import 'package:mantra_ess/Screens/purchase_invoice_screen.dart';
import 'package:mantra_ess/Screens/delivery_note_screen.dart';
import 'package:mantra_ess/Screens/payment_page.dart';
import 'package:mantra_ess/Screens/payment_page_approve.dart';
import 'package:mantra_ess/SerialNumberDetails/SerialNumberDetails.dart';
import 'package:mantra_ess/Policy/PolicyList.dart';
// import 'package:mantra_ess/Holiday/HolidayList.dart';
import 'package:mantra_ess/Holiday/HolidayList.dart';
import 'package:mantra_ess/Screens/expense_claim_list.dart';
import 'package:mantra_ess/Screens/material_request_screen.dart';
import 'package:mantra_ess/Screens/item_list.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  bool serviceCall = false;
  // final DashboardController dashboardController = Get.lazyPut(()=>DashboardController());
  @override
  void initState() {
    super.initState();

    _getDashboradMenuOption();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard'),
            leading: Container(),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () => Get.to(ProfileScreen()),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          body: controller.dashboardCards.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: false,
              physics: const BouncingScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: controller.dashboardCards.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (controller.dashboardCards[index] ==
                          'Attendance') {
                        Get.to(AttendanceScreen());
                      } else if (controller.dashboardCards[index] ==
                          'Salary Slip') {
                        Get.to(SalarySlipList());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Scan QRCode') {
                        Get.to(ScannerScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Purchase Order') {
                        Get.to(PurchaseOrderListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Sales Order') {
                        Get.to(SalesOrderListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Purchase Receipt') {
                        Get.to(PurchaseReceiptListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Purchase Invoice') {
                        Get.to(PurchaseInvoiceListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Sales Invoice') {
                        Get.to(SalesInvoiceListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Delivery Note') {
                        Get.to(DeliveryNoteListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Payment Page') {
                        Get.to(PaymentPage());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Serial Number Tracking') {
                        Get.to(SerialNumberList());
                      }else if (controller.dashboardCards[index] ==
                          'Policy') {
                        Get.to(Policylist());
                      }else if (controller.dashboardCards[index] ==
                          'Holiday') {
                        Get.to(HolidayList());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Expense Claim') {
                        Get.to(ExpenseClaimScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Material Request') {
                        Get.to(MaterialRequestScreenListScreen());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Items') {
                        Get.to(ItemListPage());
                      }
                      else if (controller.dashboardCards[index] ==
                          'Payment Page Approve') {
                        Get.to(PaymentApprovePage());
                      }
                      //TODO: add other screen routes
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
                            controller.dashboardCards[index],
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
          )
              : Center(child: Text('No data')),
        );
      },
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
      'Payment Page',
      'Policy',
      'Serial Number Tracking',
      'Holiday',
      'Create Order',
      'Sales Invoice',
      'Delivery Note',
      'Sales Order',
      'Scan QRCode',
      'Purchase Order',
      'Purchase Receipt',
      'Purchase Invoice',
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