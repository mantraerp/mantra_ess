import 'package:flutter/material.dart';
import 'package:mantra_ess/SerialNumberDetails/ShowSerialNumberDetails.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/SerialNumberDetails/ShowBatchNumberDetails.dart';
import '../Screens/toast_helper.dart';

class SerialNumberList extends StatefulWidget {
  const SerialNumberList({super.key});

  @override
  SerialNumberListState createState() => SerialNumberListState();
}

class SerialNumberListState extends State<SerialNumberList> {
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false;

  Future<void> handleGetDetails() async {
    String number = _textController.text.trim();

    if (number.isEmpty) {
      ToastUtils.show(context, 'Please enter a serial or batch number');
      return;
    }

    setState(() {
      isLoading = true;
    });

    dynamic result = await apiCheckSerialOrBatchType(number);

    setState(() {
      isLoading = false;
    });

    if (result.toString().startsWith("error:")) {
      ToastUtils.show(
        context,
        result.toString().replaceFirst("error:", ""),
      );
    } else if (result == "serial") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SerialDetailsPage(serialNumber: number),
        ),
      );
    } else if (result == "batch") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BatchDetailsPage(batchNumber: number),
        ),
      );
    } else {
      ToastUtils.show(context, 'Serial and Batch data not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Serial Or Batch Number'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter Serial or Batch Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey), // keep gray on focus
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),

                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: handleGetDetails,
                  child: const Text(
                    'Get Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            /// Loader BELOW
            if (isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}
