import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class BatchDetailsPage extends StatefulWidget {
  final String batchNumber;

  const BatchDetailsPage({super.key, required this.batchNumber});

  @override
  State<BatchDetailsPage> createState() => _BatchDetailsPageState();
}

class _BatchDetailsPageState extends State<BatchDetailsPage> {
  dynamic batchData,TrackData;
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
        if (data['batch_data'] != null && data['batch_data'].isNotEmpty) {
          batchData = data['batch_data'];
          errorMessage = '';
        } else {
          batchData = null;
          errorMessage = data['message'] ?? 'No Batch data found';
        }

        if (data['data'] != null && data['data'].isNotEmpty) {
          TrackData = List<Map<String, dynamic>>.from(data['data']);
        } else {
          TrackData = [];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        batchData = null;
        TrackData = [];
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Number Details - ${widget.batchNumber}'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : batchData == null
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  // borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: const Center(
                  child: Text(
                    'Item Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // white text
                    ),
                  ),
                ),
              ),
            ),
            // First Table
            Container(
              margin: const EdgeInsets.all(16),
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 1),
                defaultVerticalAlignment:
                TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(90),
                  1: FixedColumnWidth(150),
                  2: FixedColumnWidth(120),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration:
                    const BoxDecoration(color: Color(0xFFDFF4F3)),

                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Batch Number',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Item Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Additional Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...batchData.map<TableRow>((item) {
                    return TableRow(
                      decoration:
                      const BoxDecoration(color: Colors.white),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['batch_no'] ?? '-',
                              style:
                              const TextStyle(color: Colors.black)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Name: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${item['item_name'] ?? '-'}\n',
                                ),
                                TextSpan(
                                  text: 'Manufacturing Date: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${item['manufacturing_date'] ?? '-'}\n',
                                ),
                                TextSpan(
                                  text: 'Expiry Date: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${item['expiry_date'] ?? '-'}\n',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: 'Code: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: '${item['item_code'] ?? '-'}\n',
                                    ),
                                    TextSpan(
                                      text: 'Batch Qty: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: '${item['batch_qty'] ?? '-'}\n',
                                    ),
                                    TextSpan(
                                      text: 'Source Document Type: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: '${item['source_document_type'] ?? '-'}\n',
                                    ),
                                  ],
                                )
                            )
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            // Tracking Documents
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  // borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: const Center(
                  child: Text(
                    'Document History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // white text
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 1),
                defaultVerticalAlignment:
                TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(90),
                  1: FixedColumnWidth(150),
                  2: FixedColumnWidth(120),
                },
                children: [
                  // Header
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFDFF4F3)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Document Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Document Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Additional Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  // Data rows (replace with your second table data)
                  ...TrackData.map<TableRow>((row) {
                    return TableRow(
                      decoration:
                      const BoxDecoration(color: Colors.white),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(row['document'] ?? '-'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              children: [
                                const TextSpan(text: 'Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${row['document_name'] ?? '-'}\n'),
                                const TextSpan(text: 'Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${row['posting_date'] ?? '-'}\n'),
                                if (row['document'] == 'Delivery Note') ...[
                                  const TextSpan(text: 'Customer Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['dn_customer_name'] ?? '-'}\n'),
                                ] else if (row['document'] == 'Sales Invoice') ...[
                                  const TextSpan(text: 'Customer Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['si_customer_name'] ?? '-'}\n'),
                                ] else if (row['document'] == 'Sales Order') ...[
                                  const TextSpan(text: 'Customer Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['so_customer_name'] ?? '-'}\n'),
                                ] else if (row['document'] == 'Stock Entry') ...[
                                  const TextSpan(text: 'Type of Transaction: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['type_of_transaction'] ?? '-'}\n'),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              children: [
                                if (row['document'] == 'Delivery Note') ...[
                                  const TextSpan(text: 'Customer: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['dn_customer'] ?? '-'}\n'),
                                  const TextSpan(text: 'Warranty Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['dn_warranty_time_period'] ?? '-'}\n'),
                                  const TextSpan(text: 'RD Service Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['dn_rd_service_time_period'] ?? '-'}\n'),
                                ] else if (row['document'] == 'Sales Order') ...[
                                  const TextSpan(text: 'Customer: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['so_customer'] ?? '-'}\n'),
                                  const TextSpan(text: 'Warranty Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['so_warranty_time_period'] ?? '-'}\n'),
                                  const TextSpan(text: 'RD Service Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['so_rd_service_time_period'] ?? '-'}\n'),
                                  const TextSpan(text: 'Delivery: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['delivey_note'] ?? '-'}\n'),
                                ] else if (row['document'] == 'Sales Invoice') ...[
                                  const TextSpan(text: 'Customer: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['si_customer'] ?? '-'}\n'),
                                  const TextSpan(text: 'Warranty Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['si_warranty_time_period'] ?? '-'}\n'),
                                  const TextSpan(text: 'RD Service Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['si_rd_service_time_period'] ?? '-'}\n'),
                                  const TextSpan(text: 'Delivery: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '${row['delivey_note'] ?? '-'}\n'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
