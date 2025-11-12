import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemsScreen extends StatelessWidget {
  final List? items;
  final String title;

  const ItemsScreen({Key? key, this.items, this.title = "Items"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemList = items ?? [];
    final currencyFormatter =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: itemList.isEmpty
          ? const Center(
        child: Text(
          "No items found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          final item = itemList[index];
          final amountValue =
              double.tryParse("${item?['amount'] ?? 0}") ?? 0;

          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: _labelValue(
                          "Item Code",
                          item?['item_code'] ?? '',
                          align: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Item Name",
                          item?['item_name'] ??
                              item?['description'] ??
                              '',
                          align: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, thickness: 0.6),

                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _labelValue(
                          "Qty",
                          "${item?['qty'] ?? 0} ${item?['stock_uom'] ?? ''}",
                          align: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Rate",
                          currencyFormatter.format(
                            double.tryParse("${item?['rate'] ?? 0}") ?? 0,
                          ),
                          align: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Amount",
                          currencyFormatter.format(amountValue),
                          align: TextAlign.right,
                          highlight: true,
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
      {TextAlign align = TextAlign.left, bool highlight = false}) {
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
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: highlight ? Colors.blueAccent : Colors.black87,
          ),
          textAlign: align,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
