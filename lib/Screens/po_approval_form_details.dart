import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/apiCall.dart';


class POApprovalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> details;
  final String currency;

  const POApprovalDetailsScreen({Key? key, required this.details,required this.currency})
      : super(key: key);

  String extractText(String html) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return html.replaceAll(regex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final poForm = details["po_form_details"] ?? {};
    final items = details["items"] ?? [];
    final stockDetail = poForm["stock_detail"] ?? [];
    final priceComparison = poForm["price_comparison"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("PO Form Approval"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 12),

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
                  _infoRow("Supplier ID", poForm?['supplier']),
                  _infoRow("Supplier", details?['supplier_name']),
                  _infoRow("Status", details?['status']),
                  _infoRow("Grand Total",
                      "${details?['grand_total'] ?? '0.0'} ${currency ?? ''}"),


                ],
              ),
            ),

            SizedBox(height: 20),


            if (items.isNotEmpty) ...[
              Center(
              child:Text(
                "Items",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 10),
              _ItemTable(items),
              SizedBox(height: 10),
            ],


            if (poForm.isNotEmpty)
              Center(
              child:Text(
                "PO Form Approval Details",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
            SizedBox(height: 10),
            if (poForm.isNotEmpty) _poApprovalTable(context,poForm),
            SizedBox(height: 20),


            if (stockDetail.isNotEmpty) ...[
           Center(
           child:Text(
                "Stock Details",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 10),
              _StockItemTable(stockDetail),
              SizedBox(height: 20),
            ],


            if (priceComparison.isNotEmpty) ...[
              Center(
              child:Text(
                "Price Comparison",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 10),
              _priceComparisonTable(context,priceComparison),
            ],
          ],
        ),
      ),
    );
  }


  Widget _rowWithButton(
      BuildContext context, String label, String buttonText, String url) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: buttonText == 'Certificates' ? 0:3,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),

          Expanded(
            flex: 4,
            child: Align(
              alignment:  buttonText != 'Certificates' ? Alignment.centerRight : Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  textStyle: TextStyle(fontSize: 11),
                ),
                onPressed: () async {
                  if (buttonText == 'Certificates' || buttonText == 'NDA') {
                    await openNDAInDialog(context, url);
                  } else {
                    await openNDAWithUrlLauncher(context, url);
                  }

                },
                child: Text(buttonText),
              ),
            ),
          )
        ],
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
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),


          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                fontSize: 11,
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



  Widget _row(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: TextStyle(fontSize: 11, color: Colors.black54)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              (value == null || value.toString().trim().isEmpty) ? '-' : value.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _poApprovalTable(BuildContext context, Map<String, dynamic> form)
  {
  return Container(
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _row("Project Code", form["project"] ?? ""),
          _row("Project Name", form["project_name"] ?? ""),
          _row("Sales Order No", form["sales_order"] ?? ""),
          _row("Customer PO No", form["po_no"] ?? ""),
          _row("Customer Code", form["customer"] ?? ""),
          _row("Customer Name", form["customer_name"] ?? ""),
          _row("Business Unit Name", form["business_unit_name"] ?? ""),
          _row("Business Unit Email", form["business_unit_email"] ?? ""),
          _row("Purpose", form["purpose"] ?? ""),
          _row("Cost Center/Profit Center", form["cost_center"] ?? ""),
          _row("Requester", form["requester"] ?? ""),
          _row("Approved By", form["approved_by"] ?? ""),
          _row("Material Request", form["material_request"] ?? ""),
          _row("Request By", form["request_by"] ?? ""),

          form["approval_link"] != null &&
              form["approval_link"].toString().isNotEmpty ?
          _rowWithButton(
            context,
            "Approval Link",
            "Approval Link",
            form["approval_link"].toString() ?? "-",
          ):Text(""),
          _row("Overall Profit in case If Project", form["overall_profit_in_case_if_project"].toString() ?? ""),
          _row("Last Lowest Price", form["last_lowest_price"].toString() ?? ""),
          form["final_supplier_quotation_link"] != null &&
              form["final_supplier_quotation_link"].toString().isNotEmpty ?
          _rowWithButton(
            context,
            "Final Supplier Quotation Link",
            "View Quotation",
            form["final_supplier_quotation_link"].toString() ?? "-",
          ):Text(""),

          _row("Comments", form["comment"] ?? ""),
          form["nda"] != null &&
              form["nda"].toString().isNotEmpty ?
          _rowWithButton(
            context,
            "NDA",
            "NDA",
            form["nda"] ?? "-",
          ):Text(""),

        ],
      ),
    );
  }

  Widget _ItemTable(List comparison) {
    if (comparison.isEmpty) return SizedBox();
    // take up to 6 entries
    final data = comparison.length > 6 ? comparison.sublist(0, 6) : comparison;

    return Container(
      decoration: _boxDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          defaultColumnWidth: FixedColumnWidth(140),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.blue.shade50),
              children: ["Item Name", "Maintain Stock", "Qty", "Rate", "Previous Purchase Rate", "Target Warehouse Qty", "Total Stock"]
                  .map((e) => _headerCell(e))
                  .toList(),
            ),
            for (var d in data)
              TableRow(children: [
                _cell(d["item_name"].toString()),
                _checkboxCell(d["is_maintain_stock"] == 1),
                _cell(d["qty"].toString()),
                _cell(d["rate"].toString()),
                _cell(d["last_purchase_rate"].toString()),
                _cell(d["available_qty_in_target"].toString()),
                _cell(d["total_available_stock"]?.toString() ?? ""),
              ])
          ],
        ),
      ),
    );
  }

  Widget _StockItemTable(List comparison) {
    if (comparison.isEmpty) return SizedBox();
    // take up to 6 entries
    final data = comparison.length > 6 ? comparison.sublist(0, 6) : comparison;

    return Container(
      decoration: _boxDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          defaultColumnWidth: FixedColumnWidth(140),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.blue.shade50),
              children: ["Item Code","Item Name", "Qty", "Target Warehouse Qty", "Current Stock", "Demand", "Additional"]
                  .map((e) => _headerCell(e))
                  .toList(),
            ),
            for (var d in data)
              TableRow(children: [
                _cell(d["item_code"].toString()),
                _cell(d["item_name"].toString()),
                _cell(d["qty"].toString()),
                _cell(d["target_warehouse_qty"].toString()),
                _cell(d["current_stock"].toString()),
                _cell(d["demand"].toString()),
                _cell(d["additional"].toString()),

              ])
          ],
        ),
      ),
    );
  }


  Widget _priceComparisonTable(BuildContext context,List comparison) {
    if (comparison.isEmpty) return SizedBox();

    final data = comparison.length > 6 ? comparison.sublist(0, 6) : comparison;

    return Container(
      decoration: _boxDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          defaultColumnWidth: FixedColumnWidth(140),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.blue.shade50),
              children: ["Supplier Name", "Quote Price to the Customer", "Total Purchase Price", "Supplier Quoted Price", "Negotiated", "Warranty / FOC Spares (%)", "Lead Time","Freight","Rate Contract","Compliance / Certificates (In case of IMPORT)","Payment Terms","Incoterms/ Shipping Terms"]
                  .map((e) => _headerCell(e))
                  .toList(),
            ),
            for (var d in data)
              TableRow(children: [
                _cell(d["supplier"].toString()),
                _cell(d["quote_price_to_the_customer"].toString()),
                _cell(d["total_purchase_price"].toString()),
                _cell(d["supplier_quoted_price"].toString()),
                _cell(d["nagotiated"].toString()),
                _cell(d["warranty_foc_spares"].toString()),
                _cell(d["lead_time"]?.toString() ?? ""),
                _cell(d["freight"]?.toString() ?? ""),
                _cell(d["rate_contract"]?.toString() ?? ""),
                d["compliance__certificates_in_case_of_import"] != null &&
                    d["compliance__certificates_in_case_of_import"].toString().isNotEmpty
                    ?
              _rowWithButton(
                  context,
                  "",
                  "Certificates",
                  d["compliance__certificates_in_case_of_import"].toString(),
                ) : const Text(""),
                _cell(d["payment_terms"]?.toString() ?? ""),
                _cell(extractText(d["incoterms_shipping_terms"]?.toString() ?? "")),
              ])
          ],
        ),
      ),
    );
  }




  Widget _headerCell(String text) {
    return Container(
      width: 140,
      height: 48,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.blue.shade50,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
        maxLines: 2,
      ),
    );
  }

  Widget _cell(String text) {
    return Container(
      width: 140,
      height: 48,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          text,
          style: TextStyle(fontSize: 11),
        ),
      ),
    );
  }


  Widget _checkboxCell(bool checked) {
    return Center(child: Checkbox(value: checked, onChanged: null));
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))
      ],
    );
  }
}
