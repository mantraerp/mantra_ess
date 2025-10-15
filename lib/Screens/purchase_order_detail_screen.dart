import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../Global/webService.dart';
import 'items_screen.dart';
import 'tax_and_charges.dart';
import 'activity_log_screen.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final String purchaseOrderName;

  const PurchaseOrderDetailScreen({Key? key, required this.purchaseOrderName})
      : super(key: key);

  @override
  State<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  final box = GetStorage();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  Map<String, dynamic>? poDetail;
  bool _logExpanded = false;
  bool _logLoading = false;
  bool _showAllLogs = false;
  List<dynamic> _activityLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchaseOrderDetail();
  }

  Future<void> _fetchActivityLog() async {
    setState(() {
      _logLoading = true;
    });

    try {
      final sid = box.read('SID');
      final doctype = "Purchase Order";
      final response = await http.get(
        Uri.parse(
            "$GetActivityLogs?doctype=$doctype&name=${widget.purchaseOrderName}"),
        headers: {
          'Cookie': 'sid=$sid',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _activityLogs = data["data"] ?? [];
          _logLoading = false;
        });
      } else {
        setState(() => _logLoading = false);
      }
    } catch (e) {
      setState(() => _logLoading = false);
    }
  }

  Future<void> _fetchPurchaseOrderDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sid = box.read('SID');
      final url = Uri.parse(
          "$GetPurchaseOrderDetail?purchase_order=${widget.purchaseOrderName}");
      final response = await http.get(url, headers: {
        'Cookie': 'sid=$sid',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          poDetail = data["data"];
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

  void _toggleActivityLog() {
    setState(() {
      _logExpanded = !_logExpanded;
    });
    if (_logExpanded && _activityLogs.isEmpty) {
      _fetchActivityLog();
    }
  }

  IconData _getLogIcon(String content) {
    if (content.toLowerCase().contains("created")) return Icons.add_circle;
    if (content.toLowerCase().contains("updated")) return Icons.edit;
    if (content.toLowerCase().contains("submitted")) return Icons.check_circle;
    if (content.toLowerCase().contains("cancelled")) return Icons.cancel;
    if (content.contains('changed')) return Icons.check_circle_outline;
    return Icons.history;
  }

  Color _getLogColor(String content) {
    if (content.toLowerCase().contains("created")) return Colors.green;
    if (content.toLowerCase().contains("updated")) return Colors.blue;
    if (content.toLowerCase().contains("submitted")) return Colors.teal;
    if (content.toLowerCase().contains("cancelled")) return Colors.red;
    if (content.toLowerCase().contains("changed")) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchaseOrderName),
        elevation: 1,
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
            // ====== PO Header Info ======
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
                  _infoRow("Supplier", poDetail?['supplier_name']),
                  _infoRow("Transaction Date",
                      poDetail?['transaction_date'] ?? "-"),
                  _infoRow("Status", poDetail?['status']),
                  _infoRow("Grand Total",
                      "${poDetail?['grand_total'] ?? '0.0'} ${poDetail?['currency'] ?? ''}"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 10),

            // ====== Navigation Cards ======
            _navCard(
              context,
              title: "Items",
              subtitle: "View all items in this Purchase Order",
              icon: Icons.inventory_2_rounded,
              color: Colors.teal,
              onTap: () {
                if (poDetail?['items'] != null &&
                    poDetail!['items'].isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemsScreen(
                        items: poDetail!['items'],
                        title: "Purchase Order Items",
                      ),
                    ),
                  );
                }
              },
            ),
            if (poDetail?['taxes'] != null &&
                poDetail!['taxes'].isNotEmpty)
              _navCard(
                context,
                title: "Taxes & Charges",
                subtitle: "Review applied taxes and extra charges",
                icon: Icons.receipt_long_rounded,
                color: Colors.indigo,
                onTap: () {
                  if (poDetail?['taxes'] != null &&
                      poDetail!['taxes'].isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaxAndChargesScreen(
                          taxes: poDetail!['taxes'],
                            currencySymbol: poDetail?['currency']
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              BaseActivityScreen(
                doctype: "Purchase Order",
                docname:  widget.purchaseOrderName,
              ),





          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          Text(
            value ?? "-",
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
