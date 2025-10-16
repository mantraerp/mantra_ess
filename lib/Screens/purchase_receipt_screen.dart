import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Models/purchase_receipt_model.dart';
import '../Global/constant.dart';
import '../Global/webService.dart';
import 'filter_screen.dart';
import 'purchase_receipt_detail_screen.dart';

class PurchaseReceiptListScreen extends StatefulWidget {
  const PurchaseReceiptListScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseReceiptListScreen> createState() =>
      _PurchaseReceiptListScreenState();
}

class _PurchaseReceiptListScreenState extends State<PurchaseReceiptListScreen> {
  final box = GetStorage();
  List<PurchaseReceiptRecord> _purchasereceipt = [];
  List<String> _statusOptions = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPaginating = false;
  bool _hasMore = true;
  String _errorMessage = "";

  int start = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  // Filters
  late String fromDate;
  late String toDate;
  String? selectedStatus;

  // Search
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final last60Days = now.subtract(const Duration(days: 7));

    fromDate = DateFormat('yyyy-MM-dd').format(last60Days);
    toDate = DateFormat('yyyy-MM-dd').format(now);

    _fetchStatusOptions();
    _fetchPurchaseReceipt(isRefresh: true);

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
        Uri.parse(GetPurchaseReceiptStatus),
        headers: {'Cookie': 'sid=$sid', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _statusOptions = List<String>.from(data["data"] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Status options fetch error: $e");
    }
  }

  Future<void> _fetchPurchaseReceipt({bool isRefresh = false}) async {
    if (isRefresh || (selectedStatus != null && selectedStatus!.isNotEmpty)) {
      start = 0;
      _hasMore = true;
      _purchasereceipt.clear();
    }

    final from = DateTime.parse(fromDate);
    final to = DateTime.parse(toDate);

// Check if From Date is after To Date
    if (from.isAfter(to)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(""),
          content: const Text("From Date cannot be after To Date"),
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

// Check if difference is greater than 60 days
    if (to.difference(from).inDays > 60) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(""),
          content: const Text("Date range cannot be greater than 60 days"),
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


    if (!_hasMore && !isRefresh) return;

    setState(() {
      if (isRefresh) {
        _isLoading = true;
      } else {
        _isPaginating = true;
      }
      _hasError = false;
    });

    try {
      final sid = box.read(SID);
      String fromStr = DateFormat('dd-MM-yyyy').format(DateTime.parse(fromDate));
      String toStr = DateFormat('dd-MM-yyyy').format(DateTime.parse(toDate));

      String url = "$GetPurchaseReceipts?from_date=$fromStr&to_date=$toStr";

      // Only include start if no status filter is applied

      if (selectedStatus != null && selectedStatus!.isNotEmpty) {
        url += "&status=${Uri.encodeComponent(selectedStatus!)}";
      }
      if (_searchText.isNotEmpty) {
        url += "&search_string=${Uri.encodeComponent(_searchText)}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Cookie': 'sid=$sid', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final poData = (data["data"] != null && data["data"]["purchase_receipts"] != null)
            ? data["data"]["purchase_receipts"]
            : [];
        final poResponse = PurchaseReceiptResponse.fromJson({
          "message": data["message"],
          "data": poData,
          "status_code": data["status_code"]
        });

        setState(() {
          _purchasereceipt.addAll(poResponse.data);

          if (poResponse.data.length < pageSize) {
            _hasMore = false;
          } else {
            // Only increment start if no status filter applied
            if (selectedStatus == null || selectedStatus!.isEmpty) {
              start += pageSize;
            }
          }

          _isLoading = false;
          _isPaginating = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
          "Failed to fetch purchase receipts (${response.statusCode})";
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
    if (!_isPaginating && _hasMore && !_isLoading) _fetchPurchaseReceipt();
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
      case "partly billed":
        return const Color(0xFFFAEDB9);
      case "to bill":
        return const Color(0xFFBCD5F7);
      case "return issued":
        return const Color(0xFFA6F7E3);
      case "completed":
        return const Color(0xFFA3F7B8);
      case "cancelled":
        return const Color(0xFFFECACA);
      case "closed":
        return const Color(0xFFFAD8B1);
      default:
        return const Color(0xFFD3D3D3);
    }
  }

  String _shortenStatus(String status) =>
      status.length > 10 ? "${status.substring(0, 10)}..." : status;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate =
    isFromDate ? DateTime.parse(fromDate) : DateTime.parse(toDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        if (isFromDate)
          fromDate = formatted;
        else
          toDate = formatted;
      });
      _fetchPurchaseReceipt(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text("Purchase Receipts")
            : TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
          ),
          onChanged: (v) {
            _searchText = v.trim();
            _fetchPurchaseReceipt(isRefresh: true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchText = "";
                  _fetchPurchaseReceipt(isRefresh: true);
                }
              });
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🧭 Filter bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: _filterBox("From", formatDate(fromDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: _filterBox("To", formatDate(toDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () async {
                      final result = await showDialog<String?>(
                        context: context,
                        builder: (context) {
                          return FilterDialog(
                            title: "Select Status",
                            options: _statusOptions,
                            selectedOption: selectedStatus,
                          );
                        },
                      );

                      setState(() => selectedStatus = result);
                      _fetchPurchaseReceipt(isRefresh: true);
                    },
                    child: _filterBox(
                      "Status",
                      selectedStatus != null
                          ? _shortenStatus(selectedStatus!)
                          : "All",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 📜 Purchase Receipt List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(child: Text(_errorMessage))
                : _purchasereceipt.isEmpty
                ? const Center(
              child: Text("No Purchase Receipts Found",
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey)),
            )
                : RefreshIndicator(
              onRefresh: () =>
                  _fetchPurchaseReceipt(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _purchasereceipt.length +
                    (_isPaginating ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _purchasereceipt.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator()),
                    );
                  }

                  final po = _purchasereceipt[i];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PurchaseReceiptDetailScreen(
                              purchaseReceiptName: po.name),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // 🟢 Left Side (Main Info)
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(po.name,
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Text(
                                      "Supplier: ${po.supplier_name ?? '-'}",
                                      style: const TextStyle(
                                          fontSize: 13)),
                                  Text(
                                      "Date: ${formatDate(po.postingDate)}",
                                      style: const TextStyle(
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 8,
                                        vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                          po.status),
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    child: Text(
                                      po.status ?? "-",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 💰 Right Side
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text(
                                  po.grandTotal
                                      ?.toStringAsFixed(2) ??
                                      '0.00',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Text(po.currency ?? '',
                                    style: const TextStyle(
                                        fontSize: 12)),
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
          ),
        ],
      ),
    );
  }

  Widget _filterBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
