import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/constant.dart';
import '../Global/webService.dart';
import 'package:mantra_ess/Screens/warehouse_wise_stock_details_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final String ItemCode;

  const ItemDetailScreen({Key? key, required this.ItemCode})
      : super(key: key);

  @override
  State<ItemDetailScreen> createState() =>
      _ItemDetailScreenScreenState();
}
class _ItemDetailScreenScreenState extends State<ItemDetailScreen> {

  final box = GetStorage();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  Map<String, dynamic>? itemDetail;
  List<dynamic> StockDetails = [];

  Future<void> _fetchItemAndStockDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sid = box.read('SID');
      final url = Uri.parse("$GetItemAndStockDetail?item_code=${widget.ItemCode}");
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          itemDetail = data["data"];
          StockDetails = itemDetail?['stock_details'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "Failed to fetch details (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchItemAndStockDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ItemCode),
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text(_errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== Header Info ======
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Item Name", itemDetail?['item_name']),
                  _infoRow(
                      "Item Code",
                      itemDetail?['item_code'] ?? "-"),
                  _infoRow("Item Group", itemDetail?['item_group']),
                  _infoRow(
                      "Stock UOM",
                      "${itemDetail?['stock_uom']}"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ====== Navigation Cards ======
            _navCard(
              context,
              title: "Stock Details",
              subtitle: "View all Warehouse and Stock",
              icon: Icons.inventory_2_rounded,
              color: Colors.teal,
              onTap: () {
                if ( StockDetails != null && StockDetails.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WarehouseStock(
                        stock_details: StockDetails,
                        title: "Stock Details",
                      ),
                    ),
                  );
                }
              },
            ),
            // ====== Collapsible Activity Log ======
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}

Widget _infoRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(
          value ?? "-",
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    ),
  );
}

Widget _navCard(
    BuildContext context, {
      required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
    }) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
      ),
    ),
  );
}