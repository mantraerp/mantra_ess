import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Models/purchase_order_model.dart';
import '../Global/constant.dart';
import '../Global/webService.dart';
import 'purchase_order_detail_screen.dart';
import 'create_purchase_order_screen.dart';
import 'filter_screen.dart';

class PurchaseOrderListScreen extends StatefulWidget {
  final bool refresh;
  const PurchaseOrderListScreen({Key? key, this.refresh = false}) : super(key: key);

  @override
  State<PurchaseOrderListScreen> createState() => _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState extends State<PurchaseOrderListScreen> {
  final box = GetStorage();
  List<PurchaseOrderRecord> _purchaseOrders = [];
  List<String> _statusOptions = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPaginating = false;
  bool _hasMore = true;
  String _errorMessage = "";

  final ScrollController _scrollController = ScrollController();

  // Filters
  late String fromDate;
  late String toDate;
  String? selectedStatus;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final last60Days = now.subtract(const Duration(days: 60)); // Last 60 days
    fromDate = DateFormat('yyyy-MM-dd').format(last60Days);
    toDate = DateFormat('yyyy-MM-dd').format(now);

    _fetchStatusOptions();
    _fetchPurchaseOrders(isRefresh: widget.refresh);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isPaginating) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchStatusOptions() async {
    try {
      final sid = box.read(SID);
      final response = await http.get(
        Uri.parse(GetPurchaseOrderStatus),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _statusOptions = ["All"];
          _statusOptions.addAll(List<String>.from(data["data"] ?? []));
        });
      }
    } catch (e) {
      debugPrint("Status fetch error: $e");
    }
  }

  Future<void> _fetchPurchaseOrders({bool isRefresh = false}) async {
    // Validation: From Date cannot be after To Date
    if (DateTime.parse(fromDate).isAfter(DateTime.parse(toDate))) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invalid Date Range"),
          content: const Text("From Date cannot be after To Date."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (isRefresh) {
      _purchaseOrders.clear();
      _hasMore = true;
    }
    if (!_hasMore && !isRefresh) return;

    setState(() {
      _isLoading = isRefresh;
      _isPaginating = !isRefresh;
      _hasError = false;
    });

    try {
      final sid = box.read(SID);
      String fromStr = DateFormat('dd-MM-yyyy').format(DateTime.parse(fromDate));
      String toStr = DateFormat('dd-MM-yyyy').format(DateTime.parse(toDate));

      String url = "$GetPurchaseOrders?from_date=$fromStr&to_date=$toStr";
      if (selectedStatus != null && selectedStatus != "All") {
        url += "&status=${Uri.encodeComponent(selectedStatus!)}";
      }
      if (_searchText.isNotEmpty) {
        url += "&search_string=${Uri.encodeComponent(_searchText)}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final poData = data["data"]?["purchase_orders"] ?? [];
        final poResponse = PurchaseOrderResponse.fromJson({
          "message": data["message"],
          "data": poData,
          "status_code": data["status_code"]
        });
        setState(() {
          final existingNames = _purchaseOrders.map((e) => e.name).toSet();
          final newItems =
          poResponse.data.where((e) => !existingNames.contains(e.name)).toList();

          if (isRefresh) {
            _purchaseOrders = poResponse.data;
          } else {
            _purchaseOrders.addAll(newItems);
          }

          if (poResponse.data.isEmpty || newItems.isEmpty) _hasMore = false;
          _isLoading = false;
          _isPaginating = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "Failed to fetch (${response.statusCode})";
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

  void _loadMore() {
    if (!_isPaginating && _hasMore && !_isLoading) _fetchPurchaseOrders();
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => FilterDialogBase(
        title: "Filter Purchase Orders",
        fromDate: fromDate,
        toDate: toDate,
        statusOptions: _statusOptions,
        selectedStatus: selectedStatus,
        onApply: (f, t, s) {
          setState(() {
            fromDate = f;
            toDate = t;
            selectedStatus = s;
          });
          _fetchPurchaseOrders(isRefresh: true);
        },
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "draft":
        return const Color(0xFFE2E8F0);
      case "on hold":
        return const Color(0xFFFAEDB9);
      case "to receive and bill":
        return const Color(0xFFD4F3FA);
      case "to bill":
        return const Color(0xFFBCD5F7);
      case "to receive":
        return const Color(0xFFA6F7E3);
      case "completed":
        return const Color(0xFFA3F7B8);
      case "cancelled":
        return const Color(0xFFFECACA);
      case "closed":
        return const Color(0xFFFAD8B1);
      case "delivered":
        return const Color(0xFFCBD5E1);
      default:
        return const Color(0xFFD3D3D3);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Purchase Orders"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // 🔍 Search Bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        _searchText = v.trim();
                        _fetchPurchaseOrders(isRefresh: true);
                      },
                      decoration: InputDecoration(
                        hintText: "Search purchase orders...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ➕ Add Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePurchaseOrderScreen(isNew: true),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text(_errorMessage))
          : _purchaseOrders.isEmpty
          ? const Center(
          child: Text("No Purchase Orders Found",
              style: TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: () => _fetchPurchaseOrders(isRefresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _purchaseOrders.length + (_isPaginating ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == _purchaseOrders.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final dn = _purchaseOrders[i];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PurchaseOrderDetailScreen(purchaseOrderName: dn.name),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dn.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87),
                            ),
                          ),
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(dn.status).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dn.status ?? "-",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Supplier:", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          Expanded(
                            child: Text(
                              dn.supplier_name ?? "-",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date:", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          Text(formatDate(dn.transactionDate),
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Grand Total",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54)),
                          Text(
                            "${dn.currency ?? ''} ${dn.grandTotal?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
