import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDialogBase extends StatefulWidget {
  final String title;
  final String fromDate;
  final String toDate;
  final List<String> statusOptions;
  final String? selectedStatus;
  final Function(String from, String to, String? status) onApply;

  const FilterDialogBase({
    Key? key,
    required this.title,
    required this.fromDate,
    required this.toDate,
    required this.statusOptions,
    this.selectedStatus,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialogBase> createState() => _FilterDialogBaseState();
}

class _FilterDialogBaseState extends State<FilterDialogBase> {
  late String tempFrom;
  late String tempTo;
  String? tempStatus;

  @override
  void initState() {
    super.initState();
    tempFrom = widget.fromDate;
    tempTo = widget.toDate;
    tempStatus = widget.selectedStatus ?? "All";
  }

  String formatDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> pickDate(bool isFrom) async {
    final initial = DateTime.parse(isFrom ? tempFrom : tempTo);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          tempFrom = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          tempTo = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void _validateAndApply() {
    final from = DateTime.parse(tempFrom);
    final to = DateTime.parse(tempTo);

    // Validation: From Date cannot be after To Date
    if (from.isAfter(to)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invalid Date Range"),
          content: const Text("From Date cannot be after To Date."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Validation: Date range cannot exceed 60 days
    if (to.difference(from).inDays > 60) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invalid Date Range"),
          content: const Text("Date range cannot exceed 60 days."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Apply if valid
    Navigator.pop(context);
    widget.onApply(tempFrom, tempTo, tempStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),

            _datePickerRow("From Date", formatDate(tempFrom), () => pickDate(true)),
            const SizedBox(height: 12),
            _datePickerRow("To Date", formatDate(tempTo), () => pickDate(false)),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: tempStatus,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Status",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              items: widget.statusOptions
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text(e),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (v) => setState(() => tempStatus = v),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Apply"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _validateAndApply,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _datePickerRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
