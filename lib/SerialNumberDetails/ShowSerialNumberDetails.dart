import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class SerialDetailsPage extends StatefulWidget {
  final String serialNumber;

  const SerialDetailsPage({super.key, required this.serialNumber});

  @override
  State<SerialDetailsPage> createState() => _SerialDetailsPageState();
}

class _SerialDetailsPageState extends State<SerialDetailsPage> {
  List<dynamic> serialData = [];
  List<Map<String, dynamic>> trackData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSerialDetails();
  }

  Future<void> fetchSerialDetails() async {
    try {
      var data = await apiTrackSerialNumber(widget.serialNumber);


      setState(() {
        // Serial Info
        if (data['serial_data'] != null &&
            (data['serial_data'] as List).isNotEmpty) {
          serialData = data['serial_data'];
          errorMessage = '';
        } else {
          serialData = [];
          errorMessage = data['message'] ?? 'No serial data found';
        }

        // Document Tracking Info (safe handling)
        final rawTrackData = data['data'];
        if (rawTrackData is List && rawTrackData.isNotEmpty) {
          trackData = List<Map<String, dynamic>>.from(rawTrackData);
        } else {
          trackData = [];
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        serialData = [];
        trackData = [];
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Serial Details - ${widget.serialNumber}'),

        centerTitle: true,

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchSerialDetails,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Show "Item Information" section only if serialData has data
              if (serialData.isNotEmpty) ...[
                sectionHeader(Icons.inventory_2, 'Item Information', Colors.blueAccent),
                const SizedBox(height: 8),
                ...serialData.map<Widget>((e) => _buildItemCard(e)).toList(),
                const SizedBox(height: 20),
              ],

              // 🔹 Show "Document History" section only if trackData has data
              if (trackData.isNotEmpty) ...[
                sectionHeader(Icons.description, 'Document History', Colors.blueAccent),
                const SizedBox(height: 8),
                ...trackData.map<Widget>((e) => _buildDocumentCard(e)).toList(),
                const SizedBox(height: 20),
              ],

              // 🔹 If both are empty, show a friendly “No Data” message
              if (serialData.isEmpty && trackData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No serial or document data found.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

      ),
    );
  }
}


// 🔹 Item Information Card
  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['item_name'] ?? 'Unnamed Item',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Divider(),

            _labelValue("Item Code", item['item_code']),
            _labelValue("Status", item['status']),
            _labelValue("Warehouse", item['warehouse']),
            _labelValue("Warranty Expiry", item['warranty_expiry_date']),
            _labelValue("RD Expiry", item['amc_expiry_date']),
          ],
        ),
      ),
    );
  }

  // 🔹 Document History Card
  Widget _buildDocumentCard(Map<String, dynamic> row) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(row['document'] ?? '-',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            const SizedBox(height: 4),
            const Divider(),

            _labelValue("Document Name", row['document_name']),
            _labelValue("Posting Date", row['posting_date']),
            if (row['document'] == 'Delivery Note')
              _labelValue("Customer Name", row['dn_customer_name']),
            if (row['document'] == 'Sales Invoice')
              _labelValue("Customer Name", row['si_customer_name']),
            if (row['document'] == 'Sales Order')
              _labelValue("Customer Name", row['so_customer_name']),
            if (row['document'] == 'Stock Entry')
              _labelValue("Type of Transaction", row['type_of_transaction']),
            ..._buildExtraDetails(row),
          ],
        ),
      ),
    );
  }

  // 🔹 Extra details depending on document type
  List<Widget> _buildExtraDetails(Map<String, dynamic> row) {
    switch (row['document']) {
      case 'Delivery Note':
        return [
          _labelValue("Customer", row['dn_customer']),
          _labelValue("Warranty Period", row['dn_warranty_time_period']),
          _labelValue("RD Service Period", row['dn_rd_service_time_period']),
        ];
      case 'Sales Order':
        return [
          _labelValue("Customer", row['so_customer']),
          _labelValue("Warranty Period", row['so_warranty_time_period']),
          _labelValue("RD Service Period", row['so_rd_service_time_period']),
          _labelValue("Delivery Note", row['delivey_note']),
        ];
      case 'Sales Invoice':
        return [
          _labelValue("Customer", row['si_customer']),
          _labelValue("Warranty Period", row['si_warranty_time_period']),
          _labelValue("RD Service Period", row['si_rd_service_time_period']),
          _labelValue("Delivery Note", row['delivey_note']),
        ];
      default:
        return [];
    }
  }

  // 🔹 Reusable key-value UI element
  Widget _labelValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value?.toString().isNotEmpty == true ? value.toString() : '-',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Header
  Widget sectionHeader(IconData icon, String title, Color color) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 50),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 55),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
