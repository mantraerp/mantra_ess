import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../Global/webService.dart';
import 'items_screen.dart';
import 'tax_and_charges.dart';
import 'activity_log_screen.dart';
import 'package:mantra_ess/Global/constant.dart';
class DeliveryNoteDetailScreen extends StatefulWidget {
  final String deliveryNoteName;

  const DeliveryNoteDetailScreen({Key? key, required this.deliveryNoteName})
      : super(key: key);

  @override
  State<DeliveryNoteDetailScreen> createState() =>
      _DeliveryNoteDetailScreenState();
}

class _DeliveryNoteDetailScreenState extends State<DeliveryNoteDetailScreen> {
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
    _fetchDeliveryNoteDetail();
  }

  Future<void> _fetchActivityLog() async {
    setState(() {
      _logLoading = true;
    });

    try {
      final sid = box.read('SID');
      final doctype = "Delivery Note";
      final response = await http.get(
        Uri.parse("$GetActivityLogs?doctype=$doctype&name=${widget.deliveryNoteName}"),
        headers: headers,
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

  Future<void> _fetchDeliveryNoteDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sid = box.read('SID');
      final url = Uri.parse("$GetDeliveryNoteDetail?delivery_note=${widget.deliveryNoteName}");
      final response = await http.get(url, headers: headers);

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
        title: Text(widget.deliveryNoteName),
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
                  _infoRow("Customer ID", poDetail?['customer']),
                  _infoRow("Customer", poDetail?['customer_name']),

                ],
              ),


            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _infoRow(
                      "Transaction Date",
                      poDetail?['posting_date'] ?? "-"),
                  _infoRow("Status", poDetail?['status']),
                  _infoRow(
                      "Grand Total",
                      "${poDetail?['grand_total'] ?? '0.0'} ${poDetail?['currency'] ?? ''}"),
                ],
              ),


            ),

            const SizedBox(height: 20),

            // ====== Navigation Cards ======
            _navCard(
              context,
              title: "Items",
              subtitle: "View all items in this Delivery Note",
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
                        title: "Delivery Invoice Items",
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaxAndChargesScreen(
                          taxes: poDetail!['taxes'],
                          currencySymbol: poDetail?['currency']
                      ),
                    ),
                  );
                },
              ),

            // ====== Collapsible Activity Log ======
            const SizedBox(height: 20),
            BaseActivityScreen(
              doctype: "Delivery Note",
              docname:  widget.deliveryNoteName,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          // VALUE (auto-wrap)
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              softWrap: true,
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
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
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
