import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Screens/toast_helper.dart';
import 'purchase_order_detail_screen.dart';
import 'purchase_invoice_detail_screen.dart';
import 'purchase_receipt_detail_screen.dart';
import 'payment_api.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> paymentDetail;
  final String paymentEntryId;

  const PaymentDetailScreen({
    super.key,
    required this.paymentDetail,
    required this.paymentEntryId,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late Map<String, dynamic> customDetails;

  @override
  void initState() {
    super.initState();
    customDetails =
        (widget.paymentDetail['custom_details'] as Map<String, dynamic>?) ?? {};
  }

  void _navigateToTransaction(
      BuildContext context, String doctype, String docName) {
    Widget page;

    switch (doctype.toLowerCase()) {
      case 'purchase order':
        page = PurchaseOrderDetailScreen(purchaseOrderName: docName);
        break;
      case 'purchase invoice':
        page = PurchaseInvoiceDetailScreen(purchaseInvoiceName: docName);
        break;
      case 'purchase receipt':
        page = PurchaseReceiptDetailScreen(purchaseReceiptName: docName);
        break;
      default:
        ToastUtils.show(context,"No detail screen available");

        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget buildReferenceRow(BuildContext context, Map<String, dynamic> row) {
    List<String> approvers = [];
    if (row['Approvers'] != null) {
      approvers = (row['Approvers'] as String).split(',');
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (row['Document'] != null)
              InkWell(
                onTap: () => _navigateToTransaction(
                    context, row['doctype'].toString(), row['Document'].toString()),
                child: Text(
                  "${row['Document ID']} - ${row['Document']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            const SizedBox(height: 4),
            if (row['Created On'] != null)
              Text("Created on: ${row['Created On']}",
                  style: const TextStyle(fontSize: 12)),
            if (row['Submitted On'] != null)
              Text("Submitted on: ${row['Submitted On']}",
                  style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            if (row['Purpose'] != null)
              Text("Purpose: ${row['Purpose']}",
                  style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            if (approvers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Approvers:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ...approvers
                      .map((a) =>
                      Text(a.trim(), style: const TextStyle(fontSize: 12)))
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateRemarkDialog() async {
    String initialRemark =
    (customDetails['custom_management_remarks'] ??
        customDetails['remarks'] ??
        '')
        .toString();

    TextEditingController controller = TextEditingController(text: initialRemark);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Update Remark"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Enter remark",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!isLoading) Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    String remarkText = controller.text.toString().trim();
                    String paymentId = widget.paymentEntryId;

                    if (paymentId.isEmpty) {
                      ToastUtils.show(context,"Payment ID is missing");
                      return;
                    }

                    setStateDialog(() => isLoading = true);

                    try {
                      await PaymentAPI.updateRemark(paymentId, remarkText);

                      setState(() {
                        customDetails['custom_management_remarks'] =
                            remarkText;
                      });

                      Navigator.pop(context); // close dialog

                      // ✅ Success popup with close icon
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          // Auto-close after 2 seconds
                          Future.delayed(const Duration(seconds: 2), () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          });

                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(16),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                  const SizedBox(height: 8),
                                const Text(
                                  "Remark updated successfully",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      setStateDialog(() => isLoading = false);
                      ToastUtils.show(context,"Error: $e");
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildCustomDetailsCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoColumn("Type", customDetails['custom_type']),
                _buildInfoColumn("Project Type", customDetails['custom_project_type']),
                _buildInfoColumn("Approved By", customDetails['custom_approved_by']),
              ],
            ),
            const SizedBox(height: 8),
            if (customDetails['remarks'] != null)
              Text("Remark:\n${customDetails['remarks']}",
                  style: const TextStyle(fontSize: 12)),
            if (customDetails['custom_management_remarks'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                    "Approver Remark:\n${customDetails['custom_management_remarks']}",
                    style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: _showUpdateRemarkDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Update Remark",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String? value) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value ?? "-", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> referenceDetails =
        (widget.paymentDetail['reference_details'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [];

    return Scaffold(
      appBar: AppBar(title: const Text("Approval Details"),centerTitle: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reference Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...referenceDetails.isEmpty
                ? [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("No Reference Details Found",
                    style: TextStyle(fontSize: 12)),
              )
            ]
                : referenceDetails
                .map((row) => buildReferenceRow(context, row))
                .toList(),
            const SizedBox(height: 12),
            buildCustomDetailsCard(),
          ],
        ),
      ),
    );
  }
}
