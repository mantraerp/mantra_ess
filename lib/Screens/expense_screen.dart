import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Controllers/expense_controller.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Models/expense_model.dart';
import 'package:mantra_ess/Screens/expense_detail_list.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ExpenseController>(
      init: ExpenseController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Expense List'),
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
                        controller.getExpensesList();
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
                          controller.getExpensesList();
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
                  child: controller.expenseList.isEmpty
                      ? const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.expenseList.length,
                          itemBuilder: (context, index) {
                            ExpenseRecord data = controller.expenseList[index];
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => ExpenseDetailListScreen(),
                                arguments: data.expenses,
                              ),
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child:
                                      // Divider(height: double.infinity),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          dataTile('Date', data.postingDate),
                                          dataTile('Status', data.status),
                                          dataTile('Company', data.company),
                                        ],
                                      ),
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

  RichText dataTile(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title :',
        style: TextStyle(fontSize: 12, color: Colors.black54),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
