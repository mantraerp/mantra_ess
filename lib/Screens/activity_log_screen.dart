// base_activity_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../Global/webService.dart';
import 'package:mantra_ess/Global/constant.dart';

class BaseActivityScreen extends StatefulWidget {
  final String doctype;
  final String docname;

  const BaseActivityScreen({
    Key? key,
    required this.doctype,
    required this.docname,
  }) : super(key: key);

  @override
  State<BaseActivityScreen> createState() => _BaseActivityScreenState();
}

class _BaseActivityScreenState extends State<BaseActivityScreen> {
  final box = GetStorage();
  bool _logExpanded = false;
  bool _logLoading = false;
  bool _showAllLogs = false;
  List<dynamic> _activityLogs = [];

  // === Fetch Activity Logs ===
  Future<void> _fetchActivityLog() async {
    setState(() => _logLoading = true);

    try {
      final sid = box.read('SID');
      final response = await http.get(
        Uri.parse(
            "$GetActivityLogs?doctype=${widget.doctype}&name=${widget.docname}"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _activityLogs = data["data"] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error loading activity logs: $e");
    } finally {
      setState(() => _logLoading = false);
    }
  }

  void _toggleActivityLog() {
    setState(() => _logExpanded = !_logExpanded);
    if (_logExpanded && _activityLogs.isEmpty) {
      _fetchActivityLog();
    }
  }

  IconData _getLogIcon(String content) {
    final lower = content.toLowerCase();
    if (lower.contains("created")) return Icons.add_circle;
    if (lower.contains("updated")) return Icons.edit;
    if (lower.contains("submitted")) return Icons.check_circle;
    if (lower.contains("cancelled")) return Icons.cancel;
    if (lower.contains("changed")) return Icons.check_circle_outline;
    return Icons.history;
  }

  Color _getLogColor(String content) {
    final lower = content.toLowerCase();
    if (lower.contains("created")) return Colors.green;
    if (lower.contains("updated")) return Colors.blue;
    if (lower.contains("submitted")) return Colors.teal;
    if (lower.contains("cancelled")) return Colors.red;
    if (lower.contains("changed")) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: _toggleActivityLog,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Activity Log",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (_activityLogs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          "(${_activityLogs.length})",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Icon(
                  _logExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.deepOrange,
                ),
              ],
            ),
          ),
        ),
        if (_logExpanded) const SizedBox(height: 8),

        if (_logExpanded)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 250),
            child: _logLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
                : _activityLogs.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "No recent activity found.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ..._activityLogs
                          .take((_showAllLogs ||
                          _activityLogs.length <= 2)
                          ? _activityLogs.length
                          : 2)
                          .map((log) {
                        final content = log["content"] ?? "-";
                        final timestamp = log["timestamp"] ?? "";
                        return Container(
                          margin:
                          const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.orange.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _getLogColor(content)
                                    .withOpacity(0.2),
                                child: Icon(
                                  _getLogIcon(content),
                                  size: 13,
                                  color: _getLogColor(content),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      timestamp,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (_activityLogs.length > 2)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllLogs = !_showAllLogs;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showAllLogs
                                      ? "Show Less"
                                      : "Show More",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showAllLogs
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
