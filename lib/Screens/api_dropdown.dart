import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mantra_ess/Global/constant.dart';
import 'package:get_storage/get_storage.dart';

class ApiDropdown extends StatefulWidget {
  final String label;
  final String apiUrl;
  final IconData? prefixIcon;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const ApiDropdown({
    super.key,
    required this.label,
    required this.apiUrl,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<ApiDropdown> createState() => _ApiDropdownState();
}

class _ApiDropdownState extends State<ApiDropdown> {
  List<String> items = [];
  bool isLoading = true;
  String? selectedValue;
  final TextEditingController searchController = TextEditingController();
  final box = GetStorage();
  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {

      final sid = box.read(SID);
      final res = await http.get(Uri.parse(widget.apiUrl),headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          items = List<String>.from(data['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching dropdown data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: selectedValue,
            hint: Text('Select ${widget.label}'),
            items: items
                .map((e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: (val) {
              setState(() => selectedValue = val);
              widget.onChanged(val);
            },
            buttonStyleData: ButtonStyleData(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              elevation: 3,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),

            // ✅ Search Bar added here
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.label}...',
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value
                    .toString()
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
          ),
        ),
      ],
    );
  }
}
