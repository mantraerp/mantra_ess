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
      if (data != null && data['data'] != null) {
        setState(() {
          listData = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No policy data found';
        });
      }
    } catch (e) {
      setState(() {
        listData = [];
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Policies'
        ),
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Color(0xFF0072ff), Color(0xFF00c6ff)],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        centerTitle: true,

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : listData.isEmpty
          ? const Center(
        child: Text(
          'No policy data found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchPolicyList,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: listData.length,
          itemBuilder: (context, index) {
            final policy = listData[index];
            final policyName = policy['title'] ?? 'N/A';
            final policyDetails = policy['details'] ?? 'No Details Found';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PolicyDetailsPage(policyName: policy['name'], policyDetails : policy['detail']),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 11),
                                child: Text(
                                  policyName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),
                              // Text(
                              //   'Policy Code: $policyCode',
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                              // const SizedBox(height: 4),
                              // Text(
                              //   'Insurance Company: $company',
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // _buildStatusTag(policy),
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

  Widget _buildStatusTag(Map<String, dynamic> policy) {
    String statusText = 'NEW';
    Color bgColor = Colors.green.shade600;
    IconData icon = Icons.fiber_new_rounded;

    if (policy['expired'] == 1) {
      statusText = 'EXPIRED';
      bgColor = Colors.red.shade600;
      icon = Icons.cancel_outlined;
    } else if (policy['renew'] == 1) {
      statusText = 'RENEW';
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