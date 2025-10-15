import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Policy/PolicyDetails.dart';

class Policylist extends StatefulWidget {
  const Policylist({super.key});

  @override
  PolicyListState createState() => PolicyListState();
}

class PolicyListState extends State<Policylist> {
  List<dynamic> listData = [];
  // dynamic listData;
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPolicyList();
  }

  Future<void> fetchPolicyList() async {
    try {
      var data = await apiPolicyList();
      if(data != null){
        setState(() {
          listData = data['data'];
          isLoading = false;
        });
      }else{
        setState(() {
          isLoading = false;
          errorMessage = 'No policy data found';
        });
      }
    }catch (e) {
      setState(() {
        listData = [];
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (listData.isEmpty) {
      return const Center(
        child: Text('No policy data found'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Policies'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchPolicyList,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: listData.length,
          itemBuilder: (context, index) {
            final policy = listData[index];
            final title = policy['name'] ?? 'Untitled Policy';
            final policy_name = policy['policy_name'] ?? 'N/A';
            final company = policy['insurance_company'] ?? 'N/A';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  'Policy Code: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        'Policy Name: $policy_name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                    ),

                    const SizedBox(height: 6),
                    Text(
                      'Insurance Company: $company',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                trailing: _buildStatusTag(policy),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PolicyDetailsPage(policyName: policy['name']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusTag(Map<String, dynamic> policy) {
    String statusText = 'NEW';
    Color statusColor = Colors.green;

    if (policy['expired'] == 1) {
      statusText = 'EXPIRED';
      statusColor = Colors.red;
    } else if (policy['renew'] == 1) {
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
          fontSize: 12,
        ),
      ),
    );
  }
}