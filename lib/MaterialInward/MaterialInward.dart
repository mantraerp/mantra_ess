import 'package:flutter/material.dart';
import 'MaterialInwordDetails.dart';

class materialinward_list extends StatefulWidget {
  const materialinward_list({super.key});

  @override
  materialinward_listState createState() => materialinward_listState();
}
class materialinward_listState extends State<materialinward_list> {
    final TextEditingController _filterController = TextEditingController();
    final List<Map<String, String>> _materialList = [
      {'id': 'MI001', 'name': 'Steel Rods'},
      {'id': 'MI002', 'name': 'Copper Wires'},
      {'id': 'MI003', 'name': 'Plastic Sheets'},
      {'id': 'MI004', 'name': 'Wooden Pallets'},
      {'id': 'MI005', 'name': 'Iron Bolts'},
      {'id': 'MI006', 'name': 'Iron Bolts'},
      {'id': 'MI007', 'name': 'Iron Bolts'},
      {'id': 'MI008', 'name': 'Iron Bolts'},
      {'id': 'MI009', 'name': 'Iron Bolts'},
      {'id': 'MI010', 'name': 'Iron Bolts'},
      {'id': 'MI011', 'name': 'Iron Bolts'},
      {'id': 'MI012', 'name': 'Iron Bolts'},
      {'id': 'MI013', 'name': 'Iron Bolts'},
      {'id': 'MI014', 'name': 'Iron Bolts'},
      {'id': 'MI015', 'name': 'Iron Bolts'},
    ];

    String _filter = '';

    @override
    void initState() {
      super.initState();
      _filterController.addListener(() {
        setState(() {
          _filter = _filterController.text.toLowerCase();
        });
      });
    }
    @override
    Widget build(BuildContext context) {
      final filteredList = _materialList.where((item) {
        return item['id']!.toLowerCase().contains(_filter);
      }).toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Material Inward',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 🔍 Filter/Search Bar
              TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Filter by ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 📋 List of Materials
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                  child: Text(
                    'No materials found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            item['id']!.substring(2),
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          item['id']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(item['name']!),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaterialInwardDetail(material: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
}