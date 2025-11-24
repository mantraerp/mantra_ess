import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class BatchDetailsPage extends StatefulWidget {
  final String batchNumber;

  const BatchDetailsPage({super.key, required this.batchNumber});

  @override
  State<BatchDetailsPage> createState() => _BatchDetailsPageState();
}

class _BatchDetailsPageState extends State<BatchDetailsPage> {
  dynamic batchData, trackData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSerialDetails();
  }

  Future<void> fetchSerialDetails() async {
    try {
      var data = await apiTrackBatchNumber(widget.batchNumber);
      setState(() {
        batchData = data['batch_data'] ?? [];
        trackData = data['data'] ?? [];
        errorMessage = batchData.isEmpty
            ? (data['message'] ?? 'No Batch data found')
            : '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        batchData = [];
        trackData = [];
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Widget sectionHeader(IconData icon, String title, Color color) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 16, bottom: 8,left:50),
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

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : '-', softWrap: true)),
        ],
      ),
    );
  }

  Widget buildBatchCard(Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['item_name'] ?? 'Unnamed Item',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Divider(),
            infoRow('Batch Number', item['batch_no'] ?? ''),
            infoRow('Item Code', item['item_code'] ?? ''),
            infoRow('Batch Quantity', item['batch_qty']?.toString() ?? ''),
            infoRow('Manufacturing Date', item['manufacturing_date'] ?? ''),
            infoRow('Expiry Date', item['expiry_date'] ?? ''),
            infoRow('Source Document Type', item['source_document_type'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget buildTrackCard(Map<String, dynamic> row) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
            infoRow('Document Name', row['document_name'] ?? ''),
            infoRow('Date', row['posting_date'] ?? ''),

            if (row['document'] == 'Delivery Note') ...[
              infoRow('Customer Name', row['dn_customer_name'] ?? ''),
              infoRow('Customer', row['dn_customer'] ?? ''),
              infoRow('Warranty Time Period', row['dn_warranty_time_period'] ?? ''),
              infoRow('RD Service Time Period', row['dn_rd_service_time_period'] ?? ''),
            ] else if (row['document'] == 'Sales Invoice') ...[
              infoRow('Customer Name', row['si_customer_name'] ?? ''),
              infoRow('Customer', row['si_customer'] ?? ''),
              infoRow('Warranty Time Period', row['si_warranty_time_period'] ?? ''),
              infoRow('RD Service Time Period', row['si_rd_service_time_period'] ?? ''),
              infoRow('Delivery', row['delivey_note'] ?? ''),
            ] else if (row['document'] == 'Sales Order') ...[
              infoRow('Customer Name', row['so_customer_name'] ?? ''),
              infoRow('Customer', row['so_customer'] ?? ''),
              infoRow('Warranty Time Period', row['so_warranty_time_period'] ?? ''),
              infoRow('RD Service Time Period', row['so_rd_service_time_period'] ?? ''),
              infoRow('Delivery', row['delivey_note'] ?? ''),
            ] else if (row['document'] == 'Stock Entry') ...[
              infoRow('Type of Transaction', row['type_of_transaction'] ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Batch Details - ${widget.batchNumber}'),

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
              if (batchData.isNotEmpty) ...[
              sectionHeader(Icons.inventory_2, 'Item Information', Colors.blueAccent),
              ...batchData.map<Widget>((e) => buildBatchCard(e)).toList()],
              if (trackData.isNotEmpty) ...[
              sectionHeader(Icons.description, 'Document History', Colors.blueAccent),
              ...trackData.map<Widget>((e) => buildTrackCard(e)).toList(),
              const SizedBox(height: 20)
            ],
          if (batchData.isEmpty && trackData.isEmpty)
            Center(
              child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No batch or document data found.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),

              ),
            ),
          )],
          ),
        ),
      ),
    );
  }
}
