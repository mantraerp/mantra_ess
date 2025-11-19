import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class WarehouseStock extends StatelessWidget {
  final List? stock_details;
  final String title;

  const WarehouseStock({Key? key, this.stock_details, this.title = "Stock Details"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StockDetails = stock_details ?? [];

    return Scaffold(

      appBar: AppBar(
        title: Text(
          title,

        ),
        centerTitle: true,

      ),
      body: StockDetails.isEmpty
          ? const Center(
        child: Text(
          "No Stock Details found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: StockDetails.length,
        itemBuilder: (context, index) {
          final stock = StockDetails[index];


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
                          "Warehouse",
                          stock?['warehouse'] ?? '',
                          align: TextAlign.left,
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
                          "Actual Qty",
                          "${stock?['actual_qty'] ?? 0} ${stock?['stock_uom'] ?? ''}",
                          align: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Reserved Qty",
                          "${stock?['reserved_qty'] ?? 0}",
                          // currencyFormatter.format(
                          //   double.tryParse("${stock?['reserved_qty'] ?? 0}") ?? 0,
                          // ),
                          align: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _labelValue(
                          "Projected Qty",
                          "${stock?['projected_qty'] ?? 0}",
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