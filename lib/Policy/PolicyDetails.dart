import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class PolicyDetailsPage extends StatefulWidget {
  final String policyName;

  const PolicyDetailsPage({super.key, required this.policyName});

  @override
  State<PolicyDetailsPage> createState() => _PolicyDetailsPageState();
}
class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
  // dynamic policyData, Recipients;
  Map<String, dynamic>? policyData;
  List<Map<String, dynamic>> Recipients = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPolicyDetails();
  }


  Future<void> fetchPolicyDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await apifetchPolicyDetails(widget.policyName);
      if (data['data'] != null) {
        setState(() {
          policyData = data['data'];
          Recipients = List<Map<String, dynamic>>.from(data['data']['recipients'] ?? []);
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          policyData = null;
          Recipients = [];
          errorMessage = data['message'] ?? 'No data found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        policyData = null;
        Recipients = [];
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policy Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: buildPolicyForm(),
      ),
    );
  }

  Widget buildPolicyForm() {
    final p = policyData ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Card
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Policy And Insurance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  _buildStatusTag(p),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLeftColumn(p)),
                  const SizedBox(width: 20),
                  // Expanded(child: _buildRightColumn(p)),
                ],
              ),

            ],
          ),
        ),

        // Space between cards (one row height)
        const SizedBox(height: 16),

        // Second Card
        Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Policy Reminder Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRightColumn(p)),
                  const SizedBox(width: 20),
                  // You can use another _buildRightColumn here if needed
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        //Details Card
        if (p['details'] != null && p['details'].toString().trim().isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Policy Details',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetails(p), // full-width paragraph
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeftColumn(Map<String, dynamic> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Code', p['name']),
        _buildField('Policy Name', p['policy_name']),
        _buildField('Insurance Types', p['insurance_types']),
        _buildField('Description', p['description']),
        _buildField('Insurance Company', p['insurance_company']),
        _buildField('Previous Policy No', p['previous_policy_no']),
        _buildField('Final Total Premium', p['final_total_premium']),
        _buildField('Start Date', p['period_from']),
        _buildField('End Date', p['period_to']),
        _buildField('Insured Name', p['insured_name']),
        _buildField('Insured Address', p['insured_address']),
        _buildField('Total Insured', p['total_sum_insured']),
        _buildField('claim', p['claim']),
      ],
    );
  }

  Widget _buildRightColumn(Map<String, dynamic> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReminderField('First Reminder', p['reminder_1']),
        _buildField('Reminder Before Days', p['reminder1_before_days']),
        _buildReminderField('Second Reminders', p['reminder_2']),
        _buildField('Second Reminder Before Days', p['reminder2_before_days']),
        _buildReminderField('Third Reminder', p['reminder_3']),
        _buildField('Third Reminder Before Days', p['reminder3_before_days']),
      ],
    );
  }


  Widget _buildDetails(Map<String, dynamic> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p['details'] ?? '-',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5, // adds line spacing for readability
          ),
          textAlign: TextAlign.left, // ensures left alignment
        ),
      ],
    );
  }

  Widget _buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderField(String label, dynamic value) {
    Widget iconWidget;
    if (value == 1 || value == '1') {
      iconWidget = const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else if (value == 0 || value == '0') {
      iconWidget = const Icon(Icons.cancel, color: Colors.red, size: 20);
    } else {
      iconWidget = const SizedBox(); // no icon for other values
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              // style: const TextStyle(fontSize: 16),
            ),
          ),
          iconWidget,
        ],
      ),
    );
  }

  Widget _buildStatusTag(Map<String, dynamic> p) {
    String statusText = 'NEW';
    Color statusColor = Colors.green;

    if (p['expired'] == 1) {
      statusText = 'EXPIRED';
      statusColor = Colors.red;
    } else if (p['renew'] == 1) {
      statusText = 'RENEW';
      statusColor = Colors.yellow.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}