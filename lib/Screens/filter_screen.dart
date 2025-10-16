import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;

  const FilterDialog({
    Key? key,
    required this.title,
    required this.options,
    this.selectedOption,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? tempSelected; // null means All Status

  @override
  void initState() {
    super.initState();
    tempSelected = widget.selectedOption; // null if All Status
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // title left, close right
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context), // closes dialog
                  ),
                ],
              ),

            ),

            const Divider(height: 1),

            // Scrollable list with "All Status" at top
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.options.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // All Status option
                      return RadioListTile<String?>(
                        title: const Text("All Status"),
                        value: null, // null represents All Status
                        groupValue: tempSelected,
                        onChanged: (val) {
                          setState(() => tempSelected = val);
                          Navigator.pop(context, null); // API gets null
                        },
                      );
                    }

                    final option = widget.options[index - 1];
                    return RadioListTile<String?>(
                      title: Text(option), // show full name
                      value: option,
                      groupValue: tempSelected,
                      onChanged: (val) {
                        setState(() => tempSelected = val);
                        Navigator.pop(context, val); // API gets full value
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
