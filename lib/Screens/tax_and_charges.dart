import 'package:flutter/material.dart';

class TaxAndChargesScreen extends StatelessWidget {
  final List? taxes;
  final String title;
  final String currencySymbol; // e.g., "USD", "INR", "EUR"

  const TaxAndChargesScreen({
    Key? key,
    this.taxes,
    this.title = "Taxes & Charges",
    this.currencySymbol = "₹",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taxList = taxes ?? [];

    // Function to format numbers as "2.14 USD"
    String formatCurrency(double amount) {
      return "${amount.toStringAsFixed(2)} $currencySymbol";
    }

    return Scaffold(

      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 1,

      ),
      body: taxList.isEmpty
          ? const Center(
        child: Text(
          "No taxes or charges found",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: taxList.length,
        itemBuilder: (context, index) {
          final tax = taxList[index];

          final taxAmount =
              double.tryParse("${tax?['tax_amount'] ?? 0}") ?? 0;
          final total =
              double.tryParse("${tax?['total'] ?? 0}") ?? 0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _labelValue(
                          "Charge Type",
                          tax?['charge_type'] ?? '-',
                          align: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _labelValue(
                          "Account Head",
                          tax?['account_head'] ?? '-',
                          align: TextAlign.right,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  const SizedBox(height: 10),

                  // Bottom Row
                  Row(
                    children: [
                      Expanded(
                        child: _labelValue(
                          "Rate",
                          "${tax?['rate'] ?? 0}%",
                          align: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Tax Amount",
                          formatCurrency(taxAmount),
                          align: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Total",
                          formatCurrency(total),
                          align: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _labelValue(String label, String value,
      {TextAlign align = TextAlign.left}) {
    return Column(
      crossAxisAlignment: align == TextAlign.left
          ? CrossAxisAlignment.start
          : (align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.end),
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: align,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
