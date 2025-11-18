import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  HolidayListState createState() => HolidayListState();
}

class HolidayListState extends State<HolidayList> {
  List<dynamic> holidayData = [];
  List<dynamic> filteredHolidays = [];
  String errorMessage = '';
  bool isLoading = true;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchHolidayList();
  }

  Future<void> fetchHolidayList() async {
    try {
      var data = await apiHolidayList();
      if (data != null && data['data'] != null) {
        setState(() {
          holidayData = data['data'];
          _sortHolidays();
          _filterCurrentMonth();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No holiday data found';
        });
      }
    } catch (e) {
      setState(() {
        holidayData = [];
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  void _sortHolidays() {
    holidayData.sort((a, b) {
      var dateA = DateFormat("dd-MM-yyyy").parse(a['holiday_date']);
      var dateB = DateFormat("dd-MM-yyyy").parse(b['holiday_date']);
      return dateA.compareTo(dateB);
    });
  }

  void _filterCurrentMonth() {
    filteredHolidays = holidayData.where((holiday) {
      DateTime date = DateFormat("dd-MM-yyyy").parse(holiday['holiday_date']);
      return date.month == _focusedDay.month && date.year == _focusedDay.year;
    }).toList();
  }

  List<DateTime> _getHolidayDates() {
    return holidayData.map((h) {
      DateTime d = DateFormat("dd-MM-yyyy").parse(h['holiday_date']);
      return DateTime(d.year, d.month, d.day);
    }).toList();
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      _focusedDay = newDate;
      _filterCurrentMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final holidayDates = _getHolidayDates();
    const holidayColor = Color(0xFFBBDEFB); // Light blue color

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.indigo),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.indigo),
                titleTextStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPageChanged: (focusedDay) {
                _onMonthChanged(focusedDay);
              },
              // Disable day selection
              selectedDayPredicate: (_) => false,
              onDaySelected: (_, __) {},
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isHoliday = holidayDates.any((d) =>
                  d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day);
                  if (isHoliday) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: holidayColor,
                        shape: BoxShape.circle, // round circle
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),

          // Holiday List Below Calendar
          Expanded(
            child: filteredHolidays.isEmpty
                ? const Center(
              child: Text(
                'No holidays this month',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: filteredHolidays.length,
              itemBuilder: (context, index) {
                var holiday = filteredHolidays[index];
                String holidayDate = holiday['holiday_date'];
                String description = holiday['description'];
                DateTime parsedDate =
                DateFormat("dd-MM-yyyy").parse(holidayDate);
                String formattedDate =
                DateFormat("d MMM, yyyy").format(parsedDate);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event,
                        color: Colors.indigo),
                    title: Text(
                      description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(formattedDate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
