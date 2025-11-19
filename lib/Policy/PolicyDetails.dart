import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import '../Global/webService.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/constant.dart';
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;


class PolicyDetailsPage extends StatefulWidget {
  final String policyName;
  final String policyDetails;

  const PolicyDetailsPage({super.key, required this.policyName,required this.policyDetails});

  @override
  State<PolicyDetailsPage> createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {


  final box = GetStorage();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "No Policy Details is Found";
  String policyDetailPlainText = '';
  Map<String, dynamic>? policyData;
  bool isLoading = true;
  String errorMessage = '';
  String? policyDetailHtml;


  String cleanHtmlToPlainText(String htmlString) {
    final nonNullHtml = htmlString ?? '';
    dom.Document document = html_parser.parse(nonNullHtml);
    String cleanText = document.body?.text ?? '';
    return cleanText.trim();

  }

  @override
  void initState() {
    super.initState();
    policyDetailHtml = widget.policyDetails;
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Policy Details"),
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : _hasError
          ? Center(child: Text('Error: $_errorMessage')) // Show error message
          : (policyDetailHtml == null || policyDetailHtml!.trim().isEmpty)
          ? Center(child: Text("No policy details available"))
          : myListView(),
    );
  }
  Widget myListView(){

    return Center(
      child: SingleChildScrollView(
        child: Html(
          data: policyDetailHtml,
        ),
      ),
    );
  }
}