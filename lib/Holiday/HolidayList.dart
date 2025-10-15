import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  HolidayListState createState() => HolidayListState();
}

class HolidayListState extends State<HolidayList> {
  List<dynamic> hilidayData = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPolicyList();
  }

  Future<void> fetchPolicyList() async {
    try {
      var data = await apiHolidayList();
      if (data != null) {
        setState(() {
          hilidayData = data['data'];
          _sortHolidays();
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
        hilidayData = [];
        errorMessage = 'Error fetching data: $e';
      });
    }
  }


  void _sortHolidays() {
    hilidayData.sort((a, b) {
      var dateA = a['holiday_date'].split('-');
      var dateB = b['holiday_date'].split('-');

      int yearA = int.parse(dateA[2]);
      int yearB = int.parse(dateB[2]);
      if (yearA != yearB) return yearA.compareTo(yearB);

      int monthA = int.parse(dateA[1]);
      int monthB = int.parse(dateB[1]);
      if (monthA != monthB) return monthA.compareTo(monthB);

      int dayA = int.parse(dateA[0]);
      int dayB = int.parse(dateB[0]);
      return dayA.compareTo(dayB);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday List'),
        // backgroundColor: Color(white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: hilidayData.length,
        itemBuilder: (context, index) {
          var holiday = hilidayData[index];
          String holidayDate = holiday['holiday_date'];
          String description = holiday['description'];

          var dateParts = holidayDate.split('-');
          String day = dateParts[0];
          String month = _getMonthName(int.parse(dateParts[1]));
          String year = dateParts[2];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$day $month, $year',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Right side: Holiday Description
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
