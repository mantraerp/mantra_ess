import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class PolicyDetailsPage extends StatefulWidget {
  final String policyName;

  const PolicyDetailsPage({super.key, required this.policyName});

  @override
  State<PolicyDetailsPage> createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
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
      appBar: AppBar(
        title: const Text(
          'Policy Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0072ff), Color(0xFF00c6ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
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
        _buildCard(
          title: 'Policy & Insurance',
          icon: Icons.policy,
          color: Colors.blue.shade50,
          trailing: _buildStatusTag(p),
          child: _buildLeftColumn(p),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: 'Policy Reminder Details',
          icon: Icons.notifications_active,
          color: Colors.green.shade50,
          child: _buildRightColumn(p),
        ),
        if (p['details'] != null && p['details'].toString().trim().isNotEmpty)
          const SizedBox(height: 16),
        if (p['details'] != null && p['details'].toString().trim().isNotEmpty)
          _buildCard(
            title: 'Policy Details',
            icon: Icons.description,
            color: Colors.white,
            child: _buildDetails(p),
          ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.indigo, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
        _buildField('Claim', p['claim']),
      ],
    );
  }

  Widget _buildRightColumn(Map<String, dynamic> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReminderField('First Reminder', p['reminder_1']),
        _buildField('Reminder Before Days', p['reminder1_before_days']),
        _buildReminderField('Second Reminder', p['reminder_2']),
        _buildField('Second Reminder Before Days', p['reminder2_before_days']),
        _buildReminderField('Third Reminder', p['reminder_3']),
        _buildField('Third Reminder Before Days', p['reminder3_before_days']),
      ],
    );
  }

  Widget _buildDetails(Map<String, dynamic> p) {
    return Text(
      p['details'] ?? '-',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.6,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.black87, fontSize: 14),
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
      iconWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          iconWidget,
        ],
      ),
    );
  }

  Widget _buildStatusTag(Map<String, dynamic> p) {
    String statusText = 'NEW';
    Color bgColor = Colors.green;
    IconData icon = Icons.fiber_new_rounded;

    if (p['expired'] == 1) {
      statusText = 'EXPIRED';
      bgColor = Colors.red;
      icon = Icons.cancel_outlined;
    } else if (p['renew'] == 1) {
      statusText = 'RENEW';
      bgColor = Colors.orange;
      icon = Icons.refresh_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor.withOpacity(0.8), bgColor.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
