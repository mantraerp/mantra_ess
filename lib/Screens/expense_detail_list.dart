import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Controllers/expense_controller.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Models/expense_model.dart';

class ExpenseDetailListScreen extends StatelessWidget {
  const ExpenseDetailListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments;
    List<ExpenseItem> expenseDetailList = data is List<ExpenseItem> ? data : [];

    return Scaffold(
      appBar: AppBar(title: Text('Expense Details'), centerTitle: true),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: expenseDetailList.length,
                itemBuilder: (context, index) {
                  ExpenseItem data = expenseDetailList[index];
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child:
                          // Divider(height: double.infinity),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              dataTile('Expense Date', data.expenseDate),
                              dataTile('Expense Type', data.expenseType),
                              dataTile('Cost Center', data.costCenter),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  dataTile('Amt', data.amount.toString()),
                                  dataTile(
                                    'Sanctioned Amt',
                                    data.sanctionedAmount.toString(),
                                  ),
                                ],
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
