




import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});


  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  bool serviceCall = false;



  @override
  void initState() {
    super.initState();

    _getDashboradMenuOption();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  _getDashboradMenuOption() async {

    if(serviceCall){return;}
    setState(() {serviceCall = true;});


    apiGetDashboardMenu().then((response)
    {
      serviceCall = false;
      if (response.runtimeType==bool)
      {
        setState(() {});
      }
      else
      {
        var allKeys = response.keys;

      }
    });
  }
}