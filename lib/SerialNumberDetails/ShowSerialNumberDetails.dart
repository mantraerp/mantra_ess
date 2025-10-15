import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class SerialDetailsPage extends StatefulWidget {
  final String serialNumber;

  const SerialDetailsPage({super.key, required this.serialNumber});

  @override
  State<SerialDetailsPage> createState() => _SerialDetailsPageState();
}

class _SerialDetailsPageState extends State<SerialDetailsPage> {
  dynamic serialData,batchData,TrackData;
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
      print("API DATA $data");
      setState(() {
        if (data['serial_data'] != null && data['serial_data'].isNotEmpty) {
          serialData = data['serial_data'];
          errorMessage = '';
        } else {
          serialData = null;
          errorMessage = data['message'] ?? 'No serial data found';
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
        serialData = null;
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
        title: Text('Serial Details - ${widget.serialNumber}'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : serialData == null
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
                          'Serial Number',
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
                  ...serialData.map<TableRow>((item) {
                    return TableRow(
                      decoration:
                      const BoxDecoration(color: Colors.white),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['serial_no'] ?? '-',
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
                                  text: 'Warranty Expiry: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${item['warranty_expiry_date'] ?? '-'}\n',
                                ),
                                TextSpan(
                                  text: 'RD Expiry: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${item['amc_expiry_date'] ?? '-'}\n',
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
                                    text: 'Status: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${item['status'] ?? '-'}\n',
                                  ),
                                  TextSpan(
                                    text: 'Warehouse: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${item['warehouse'] ?? '-'}\n',
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
