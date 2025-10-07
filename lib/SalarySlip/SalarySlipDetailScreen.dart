import 'package:flutter/material.dart';

class SalarySlipDetailScreen extends StatelessWidget {
  final dynamic slip;

  const SalarySlipDetailScreen({super.key, required this.slip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(slip.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee: ${slip.employeeName}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text('Period: ${slip.startDate} → ${slip.endDate}'),
                const Divider(height: 30),

                Text('Earnings', style: Theme.of(context).textTheme.titleLarge),
                ...slip.earnings.map((e) => ListTile(
                  dense: true,
                  title: Text(e.salaryComponent),
                  trailing:
                  Text('₹${e.amount.toStringAsFixed(2)}'),
                )),
                const Divider(),
                Text('Deductions', style: Theme.of(context).textTheme.titleLarge),
                ...slip.deductions.map((d) => ListTile(
                  dense: true,
                  title: Text(d.salaryComponent),
                  trailing:
                  Text('-₹${d.amount.toStringAsFixed(2)}'),
                )),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Salary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹${slip.netPay.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Status: ${slip.paymentStatus}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
