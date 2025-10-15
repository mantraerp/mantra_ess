import 'package:flutter/material.dart';

class DataDisplayScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const DataDisplayScreen({super.key, required this.data});

  // Convert field_name_like_this → Field Name Like This
  String prettifyFieldName(String field) {
    return field
        .split('_')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> details = data['data'] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Label Details"),
        centerTitle: true,
        backgroundColor: Colors.blue[700], // Medium blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.blue.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: details.entries.length,
              itemBuilder: (context, index) {
                final entry = details.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        child: Text(
                          "${prettifyFieldName(entry.key)}:", // ✅ Added colon
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[700], // Medium blue
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${entry.value}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
