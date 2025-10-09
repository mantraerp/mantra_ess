
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/AppWidget.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';

class salaryslip_list extends StatefulWidget {
  const salaryslip_list({super.key});

  @override
  salaryslip_listState createState() => salaryslip_listState();
}

class salaryslip_listState extends State<salaryslip_list> {

  bool serviceCall = false;

  TextEditingController editingController = TextEditingController();
  List<dynamic> items = [];
  List<dynamic> itemsAll = [];
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPendingTourPlan();
  }

  void loadPendingTourPlan() {

    if (serviceCall) {
      return;
    }
    setState(() {
      serviceCall = true;
    });

    apiSalarySlipList().then((response) {
      serviceCall = false;
      if (response.runtimeType == bool) {
        // setState(() {});
      } else {
        itemsAll = response;
        items = response;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: appWhite, elevation: 1, centerTitle: true, title: const Text( 'Salary Slip', style: TextStyle( color: appBlack, fontWeight: FontWeight.w600, fontSize: 18, ), ), iconTheme: const IconThemeData(color: appBlack), ),
      body: Container(
        color: appWhite,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 0, right: 0, bottom: 0),
              child: searchbar(),
            ),
            const Divider(color: appGray,),
            Expanded(child: myListView()),
          ],
        ),
      ),
    );
  }

  Widget searchbar() {
    if (itemsAll.isEmpty) {
      return Container();
    }

    DateTime? fromDate;
    DateTime? toDate;

    String formatDate(DateTime? date) {
      if (date == null) return 'Select Date';
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }

    Future<void> selectDate(BuildContext context, bool isFrom) async {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          if (isFrom) {
            fromDate = picked;
          } else {
            toDate = picked;
          }
        });
      }
    }

    return SizedBox(
      height: 40,
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: appGray, width: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDate(fromDate),
                        style: const TextStyle(fontSize: 13, color: appBlack)),
                    const Icon(Icons.calendar_today, size: 16, color: appGray),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: appGray, width: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDate(toDate),
                        style: const TextStyle(fontSize: 13, color: appBlack)),
                    const Icon(Icons.calendar_today, size: 16, color: appGray),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (fromDate == null || toDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select both dates')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Filtering from ${formatDate(fromDate)} to ${formatDate(toDate)}',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Filter',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }



  void beforeServiceCall() {
    setState(() {
      serviceCall = false;
    });
  }

  Future<void> _getData() async {
    loadPendingTourPlan();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Widget myListView(){

    if (items.isEmpty) {
      return showLoaderText('');
    }

    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: RefreshIndicator(
          color:appGray,
          onRefresh: _getData,
          child:ListView.builder(
            padding: const EdgeInsets.only(left: 10,right: 10),
            controller: _controller,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () async {
                    // items(items[index]);
                  },
                  child:ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 142.0,),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10,right: 10, bottom: 10,top: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10,right: 10, bottom: 10,top: 10),
                          decoration: BoxDecoration(
                              color: appWhite,
                              border: Border.all(
                                width:0.6,
                                color: appGray,
                              ),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(4.0)
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(1, 1), // changes position of shadow
                                ),
                              ]
                          ),
                          child: productCell(items[index]),
                        ),
                      )
                  )
              );
            },
          ),
        )
    );
  }
  Widget productCell(dynamic salon) { return Container( padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(8), gradient: LinearGradient( colors: [Colors.white, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight, ), boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.25), blurRadius: 6, offset: const Offset(2, 2), ), ], ), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Flexible( child: Text( salon['name'] ?? '', style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w600, color: appBlack, ), ), ), Container( padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), ), child: Text( salon['payment_status'] ?? 'N/A', style: const TextStyle( fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500, ), ), ), ], ), const SizedBox(height: 6), Text( salon['employee_name'] ?? '', style: const TextStyle( fontSize: 14, color: appGray, ), ), const Divider(height: 18, thickness: 0.8, color: appGray), Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( "Gross Pay", style: TextStyle(fontSize: 13, color: appGray), ), Text( "₹${salon['gross_pay']?.toStringAsFixed(0) ?? '0'}", style: const TextStyle( fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green, ), ), ], ), Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( "Deductions", style: TextStyle(fontSize: 13, color: appGray), ), Text( "₹${salon['total_deduction']?.toStringAsFixed(0) ?? '0'}", style: const TextStyle( fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent, ), ), ], ), Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( "Net Pay", style: TextStyle(fontSize: 13, color: appGray), ), Text( "₹${salon['net_pay']?.toStringAsFixed(0) ?? '0'}", style: const TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black, ), ), ], ), ], ), const SizedBox(height: 6), Align( alignment: Alignment.bottomRight, child: Text( "${salon['start_date'] ?? ''} - ${salon['end_date'] ?? ''}", style: const TextStyle(fontSize: 12, color: appGray), ), ), ], ), ); }

  void filterSearchResults(String query) {

    List<dynamic> dummySearchList = [];
    dummySearchList.addAll(itemsAll);
    if (query.isNotEmpty)
    {
      List<dynamic> dummyListData = [];
      for (var item in dummySearchList) {
        if (item['supplier'].toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        else if (item['supplier'].toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    }
    else
    {
      setState(() {
        items.clear();
        items.addAll(itemsAll);
      });
    }
  }
}
