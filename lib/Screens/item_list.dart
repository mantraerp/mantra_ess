import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Screens/item_detail_screen.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<dynamic> itemList = [];
  bool isLoading = true;
  String errorMessage = '';
  bool isDisabled = false;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Call the API to get the item list
  Future<void> fetchItems({String? searchString,String? disabled}) async {
    try {
      final data = await apiGetItemList(search_string: searchString ?? '', disabled: disabled ?? '',);
      if (data == null ) {
        setState(() {
          itemList = [];
          isLoading = false;
          errorMessage = "No matching items for search766";
        });
      } else {
        setState(() {
          itemList = data;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      errorMessage = "Error fetching data: $error";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();  // Fetch items when the page is loaded

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim();
      });
      fetchItems(searchString: searchQuery,disabled: isDisabled ? '1' : '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Item List',

        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search items...",
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
                const SizedBox(width: 12), // Add some spacing between search and checkbox
                // Disabled checkbox
                Row(
                  children: [
                    const Text('Disabled', style: TextStyle(fontSize: 14)),
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: isDisabled,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isDisabled = newValue ?? false;
                        });
                        fetchItems(searchString: searchQuery, disabled: isDisabled ? '1' : '');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // appBar: AppBar(
      //   title: const Text(
      //     'Item List',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(55),
      //     child: Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //       child: TextField(
      //         controller: _searchController,
      //         decoration: InputDecoration(
      //           hintText: "Search items...",
      //           prefixIcon: const Icon(Icons.search),
      //           filled: true,
      //           fillColor: Colors.white,
      //           contentPadding: const EdgeInsets.symmetric(vertical: 0),
      //           border: OutlineInputBorder(
      //             borderRadius: BorderRadius.circular(10),
      //             borderSide: BorderSide.none,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : itemList.isEmpty
          ? const Center(
        child: Text(
          'No Item data found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: () => fetchItems(searchString: searchQuery),
        // onRefresh: fetchItems,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            final item = itemList[index];
            final itemName = item['item_name'] ?? 'Untitled Item';
            final itemCode = item['item_code'] ?? 'N/A';
            final itemGroup = item['item_group'] ?? 'N/A';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ItemDetailScreen(ItemCode: item['item_code']),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade50.withOpacity(0.5)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.policy,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,

                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Item Code: $itemCode',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Item Group: $itemGroup',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusTag(item),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusTag(Map<String, dynamic> item) {
    String statusText = 'Non-Serial';
    Color bgColor = Colors.red.shade600;
    IconData icon = Icons.fiber_new_rounded;

    if (item['has_serial_no'] == 1) {
      statusText = 'Serial-Item';
      bgColor = Colors.green.shade600;
      icon = Icons.cancel_outlined;
    } else if (item['has_batch_no'] == 1) {
      statusText = 'Batch-Item';
      bgColor = Colors.orange.shade700;
      icon = Icons.refresh_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: bgColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: bgColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}