import 'package:flutter/material.dart';
import 'package:mantra_ess/SerialNumberDetails/ShowSerialNumberDetails.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/SerialNumberDetails/ShowBatchNumberDetails.dart';
import 'package:mantra_ess/SerialNumberDetails/ErrorMessage.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a serial or batch number')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString().replaceFirst("error:", ""))),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ErrorPage(
            message: 'Serial and Batch data not found',
          ),
        ),
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Invalid type returned from server")),
      // );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Serial Or Batch Number',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : handleGetDetails,
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Get Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
