import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Screens/toast_helper.dart';
import 'purchase_order_screen.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  final bool isNew; // Add this line

  const CreatePurchaseOrderScreen({Key? key, this.isNew = false}) : super(key: key);

  @override
  State<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen>
    with SingleTickerProviderStateMixin {
  final box = GetStorage();

  late TabController _tabController;
  int _lastTabIndex = 0;
  final Map<String, dynamic> _savedForm = {
    "details": {},
    "items": {},
    "taxes": {},

  };
  final Map<int, bool> _unsaved = {
    0: false,
    1: false,
    2: false,

  };
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _transactionDateController =
  TextEditingController();
  final TextEditingController _requiredByController = TextEditingController();
  final TextEditingController _odooPoController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  DateTime _transactionDate = DateTime.now();
  String? _selectedSeries;
  String? _selectedPurchaseType;
  String? _selectedSupplier; // this will contain the supplier "name" (unique id)
  String? _supplierName; // read-only human name fetched from party API
  String? _selectedPurchasePerson;
  String? _selectedPoApprover;
  String? _selectedCurrency;
  String? _selectedWarehouse;
  String? _selectedProject;
  String? _selectedCompany;
  List<String> _namingSeries = [];
  List<String> _purchaseTypes = [];
  List<String> _suppliers = [];
  List<String> _purchasePersons = [];
  List<String> _poApprovers = [];
  List<String> _currencies = [];
  List<TaxLine> _taxes = [];



  List<String> _warehouses = [];

  List<String> _projects = [];
  bool _loadingNamingSeries = true;
  bool _loadingPurchaseTypes = true;
  bool _loadingSuppliers = true;
  bool _loadingPurchasePersons = true;
  bool _loadingApprovers = true;
  bool _loadingCurrencies = true;
  bool _loadingProjects = true;
  bool _loadingWarehouses = true;
  List<PurchaseOrderItem> _items = [];

  bool _isSubmitting = false;
  final TextEditingController _dropdownSearchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    final box = GetStorage();
    if (widget.isNew == true) {
      box.remove('purchase_order_draft');
    }

    if(widget.isNew != true) {
      _loadSavedFromStorage();
    }

    _tabController = TabController(length: 5, vsync: this);


    _transactionDateController.text =
        DateFormat('dd-MM-yyyy').format(_transactionDate);
    _requiredByController.text = "";
    _loadAllDropdowns();
    _remarksController.addListener(() => _markUnsaved(0));
    _transactionDateController.addListener(() => _markUnsaved(0));
    _requiredByController.addListener(() => _markUnsaved(0));
    _odooPoController.addListener(() => _markUnsaved(0));
  }
  @override
  void dispose() {

    _transactionDateController.dispose();
    _requiredByController.dispose();
    _odooPoController.dispose();
    _remarksController.dispose();
    _dropdownSearchController.dispose();
    super.dispose();
  }
  void _loadSavedFromStorage() {
    try {
      final d = box.read('po_saved_details');
      if (d != null && d is Map) {
        _savedForm['details'] = Map<String, dynamic>.from(d);
        // restore into live fields
        _selectedSeries = _savedForm['details']['naming_series'];
        _selectedPurchaseType = _savedForm['details']['purchase_type'];
        _selectedSupplier = _savedForm['details']['supplier'];
        _supplierName = _savedForm['details']['supplier_name'];
        _transactionDateController.text =
            _savedForm['details']['transaction_date'] ??
                _transactionDateController.text;
        _requiredByController.text =
            _savedForm['details']['required_by_date'] ??
                _requiredByController.text;
        _selectedPurchasePerson = _savedForm['details']['purchase_person'];
        _selectedPoApprover = _savedForm['details']['po_approver'];
        _selectedCurrency = _savedForm['details']['currency'];
        _selectedCompany = _savedForm['details']['company'];
        _selectedWarehouse = _savedForm['details']['warehouse'];
        _selectedProject = _savedForm['details']['project'];
        _remarksController.text =
            _savedForm['details']['remarks'] ?? _remarksController.text;
        _odooPoController.text =
            _savedForm['details']['odoo_po'] ?? _odooPoController.text;
      }
      final it = box.read('po_saved_items');
      if (it != null && it is List) {
        _savedForm['items'] = List.from(it);
        _restoreItemsTab();
      }
      final tx = box.read('po_saved_taxes');
      if (tx != null && tx is List) {
        _savedForm['taxes'] = List.from(tx);
        _restoreTaxesTab();
      }
    } catch (e) {
      debugPrint("Error loading saved PO from storage: $e");
    }
  }
  Future<void> _persistTabToStorage(String tabKey) async {
    try {
      switch (tabKey) {
        case 'details':
          await box.write('po_saved_details', _savedForm['details']);
          break;
        case 'items':
          await box.write('po_saved_items', _savedForm['items']);
          break;
        case 'taxes':
          await box.write('po_saved_taxes', _savedForm['taxes']);
          break;


      }
    } catch (e) {
      debugPrint("Error persisting $tabKey to storage: $e");
    }
  }
  void _markUnsaved(int tabIndex) {
    setState(() {
      _unsaved[tabIndex] = true;
    });
  }
  void _clearUnsaved(int tabIndex) {
    setState(() {
      _unsaved[tabIndex] = false;
    });
  }
  void _saveTabByIndex(int index) {
    switch (index) {
      case 0:
        _saveDetailsTab();
        break;
      case 1:
        _saveItemsTab();
        break;
      case 2:
        _saveTaxesTab();
        break;
    }
  }
  void _restoreTabByIndex(int index) {
    switch (index) {
      case 0:
        _restoreDetailsTab();
        break;
      case 1:
        _restoreItemsTab();
        break;
      case 2:
        _restoreTaxesTab();
        break;
    }
  }
  Future<void> _loadAllDropdowns() async {
    setState(() {
      _loadingNamingSeries = _loadingPurchaseTypes = _loadingSuppliers =
          _loadingPurchasePersons = _loadingApprovers = _loadingCurrencies =
          _loadingProjects = _loadingWarehouses = true;
    });
    await Future.wait([
      _fetchNamingSeries(),
      _fetchPurchaseTypes(),
      _fetchSuppliers(),
      _fetchPurchasePersons(),
      _fetchPoApprovers(),
      _fetchCurrencies(),
      _fetchWarehouses(),
      _fetchProject(),
      _fetchCompany()
    ]);
    setState(() {});
  }
  Future<void> _fetchNamingSeries() async {
    try {
      final url = Uri.parse("$GetPoNamingSeries");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"]?['naming_series'] ?? j["data"];
        if (data is List) {
          _namingSeries = List<String>.from(data.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint("NamingSeries fetch error: $e");
    } finally {
      _loadingNamingSeries = false;
      setState(() {});
    }
  }
  Future<void> _fetchPurchaseTypes() async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetPoPurchaseType");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) _purchaseTypes = List<String>.from(data.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint("PurchaseType fetch error: $e");
    } finally {
      _loadingPurchaseTypes = false;
      setState(() {});
    }
  }
  Future<void> _fetchSuppliers({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Supplier&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"] ?? j;
        if (data is List) {
          _suppliers = List<String>.from(data.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint("Suppliers fetch error: $e");
    } finally {
      _loadingSuppliers = false;
      setState(() {});
    }
  }
  Future<void> _fetchCompany({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Company&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"] ?? j;
        if (data is List) {
          setState(() => _selectedCompany = j['data'][0]?.toString());
        }
      }
    } catch (e) {
      debugPrint("Suppliers fetch error: $e");
    } finally {
      _loadingSuppliers = false;
      setState(() {});
    }
  }
  Future<void> _fetchPurchasePersons({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Purchase Person&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) _purchasePersons = List<String>.from(data.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint("PurchasePerson fetch error: $e");
    } finally {
      _loadingPurchasePersons = false;
      setState(() {});
    }
  }
  Future<void> _fetchPoApprovers() async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetPoApprover");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) _poApprovers = List<String>.from(data.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint("Approvers fetch error: $e");
    } finally {
      _loadingApprovers = false;
      setState(() {});
    }
  }
  Future<void> _fetchCurrencies({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Currency&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) {
          _currencies = List<String>.from(data.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint("Currencies fetch error: $e");
    } finally {
      _loadingCurrencies = false;
      setState(() {});
    }
  }
  Future<void> _fetchWarehouses({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Warehouse&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) {
          _warehouses = List<String>.from(data.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint("Warehouses fetch error: $e");
    } finally {
      _loadingWarehouses = false;
      setState(() {});
    }
  }
  Future<void> _fetchProject({String search = ""}) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetMasterList?doctype=Project&search_text=${Uri.encodeQueryComponent(search)}");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final data = j["data"];
        if (data is List) {
          _projects = List<String>.from(data.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint("project fetch error: $e");
    } finally {
      _loadingProjects = false;
      setState(() {});
    }
  }
  Future<void> _fetchSupplierName(String supplierId) async {
    try {
      final sid = box.read("SID");
      final url = Uri.parse("$GetPartyName?party_type=Supplier&party=$_selectedSupplier");
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        setState(() => _supplierName = j['data']?.toString() ?? supplierId);
      }
    } catch (e) {
      debugPrint("Supplier name fetch error: $e");
      setState(() => _supplierName = supplierId);
    }
  }
  Future<void> _pickTransactionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _transactionDate = picked;
        _transactionDateController.text =
            DateFormat('dd-MM-yyyy').format(picked);
        _markUnsaved(0);
      });
    }
  }
  Future<void> _pickRequiredByDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _requiredByController.text = DateFormat('dd-MM-yyyy').format(picked);
        _markUnsaved(0);
      });
    }
  }
  void _saveDetailsTab() {
    _savedForm['details'] = {
      'naming_series': _selectedSeries,
      'purchase_type': _selectedPurchaseType,
      'supplier': _selectedSupplier,
      'supplier_name': _supplierName,
      'transaction_date': _transactionDateController.text,
      'required_by_date': _requiredByController.text,
      'purchase_person': _selectedPurchasePerson,
      'po_approver': _selectedPoApprover,
      'currency': _selectedCurrency,
      'company': _selectedCompany,
      'warehouse': _selectedWarehouse,
      'project': _selectedProject,
      'remarks': _remarksController.text,

    };
    _persistTabToStorage('details');
    _clearUnsaved(0);

  }
  void _restoreDetailsTab() {
    final Map? d = _savedForm['details'] as Map?;
    if (d == null) return;
    setState(() {
      _selectedSeries = d['naming_series'];
      _selectedPurchaseType = d['purchase_type'];
      _selectedSupplier = d['supplier'];
      _supplierName = d['supplier_name'];
      _transactionDateController.text =
          d['transaction_date'] ?? _transactionDateController.text;
      _requiredByController.text =
          d['required_by_date'] ?? _requiredByController.text;
      _selectedPurchasePerson = d['purchase_person'];
      _selectedPoApprover = d['po_approver'];
      _selectedCurrency = d['currency'];
      _selectedCompany = d['company'];
      _selectedWarehouse = d['warehouse'];
      _selectedProject = d['project'];
      _remarksController.text = d['remarks'] ?? _remarksController.text;
      _odooPoController.text = d['odoo_po'] ?? _odooPoController.text;
    });
  }
  void _saveItemsTab() {
    _savedForm['items'] = _items
        .map((it) => {
      'item_code': it.itemCode,
      'description': it.description,
      'qty': it.qty,
      'rate': it.rate,
    })
        .toList();
    _persistTabToStorage('items');
    _clearUnsaved(1);

  }
  void _restoreItemsTab() {
    final data = _savedForm['items'];
    if (data is List) {
      setState(() {
        _items = data.map<PurchaseOrderItem>((m) {
          return PurchaseOrderItem(
            itemCode: (m['item_code'] ?? '').toString(),
            description: (m['description'] ?? '').toString(),
            qty: (m['qty'] is num)
                ? (m['qty'] as num).toDouble()
                : double.tryParse((m['qty'] ?? '0').toString()) ?? 0,
            rate: (m['rate'] is num)
                ? (m['rate'] as num).toDouble()
                : double.tryParse((m['rate'] ?? '0').toString()) ?? 0,
          );
        }).toList();
      });
    }
  }
  void _saveTaxesTab() {
    _persistTabToStorage('taxes');
    _clearUnsaved(2);

  }

  void _restoreTaxesTab() {
    final data = _savedForm['taxes'];
    if (data is List) {
      setState(() {
        _taxes = data.map((t) => TaxLine(
          description: t['description'],
          rate: t['rate'],

        )).toList();
      });
    }
  }


  Future<bool> _confirmSaveDiscardIfUnsaved(int fromIndex) async {
    if (_unsaved[fromIndex] != true) return true; // nothing to do
    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Unsaved changes"),
        content: const Text("Save or discard changes before leaving this tab?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, 'discard'), child: const Text("Discard")),
          TextButton(onPressed: () => Navigator.pop(c, 'save'), child: const Text("Save")),
        ],
      ),
    );
    if (res == 'save') {
      _saveTabByIndex(fromIndex);
      return true;
    } else if (res == 'discard') {
      // reload from savedForm (discard changes)
      _restoreTabByIndex(fromIndex);
      _clearUnsaved(fromIndex);
      return true;
    } else {
      return false; // canceled
    }
  }
  Future<void> _showAddEditItemDialog({PurchaseOrderItem? item, int? index}) async {
    final codeCtrl = TextEditingController(text: item?.itemCode ?? "");
    final descCtrl = TextEditingController(text: item?.description ?? "");
    final qtyCtrl = TextEditingController(text: item != null ? item.qty.toString() : "1");
    final rateCtrl = TextEditingController(text: item != null ? item.rate.toStringAsFixed(2) : "0.00");
    final stockUomCtrl = TextEditingController(text: item?.stockUom ?? "Nos");

    String? selectedItemCode = item?.itemCode;
    String? selectedUom = item?.uom;

    bool loadingItems = true;
    bool loadingUoms = true;

    List<String> itemCodes = [];
    List<String> uoms = [];

    // Load item codes
    Future<void> _loadItems({String search = ""}) async {
      try {
        final sid = box.read("SID");
        final url = Uri.parse("$GetMasterList?doctype=Item&search_text=${Uri.encodeQueryComponent(search)}");
        final res = await http.get(url, headers: headers);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          itemCodes = (data["data"] as List).map((e) => e.toString()).toList();
        }
      } catch (e) {
        debugPrint("Error loading items: $e");
      }
    }

    // Load UOM list
    Future<void> _loadUom({String search = ""}) async {
      try {
        final sid = box.read("SID");
        final url = Uri.parse("$GetMasterList?doctype=UOM&search_text=${Uri.encodeQueryComponent(search)}");
        final res = await http.get(url, headers: headers);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          uoms = (data["data"] as List).map((e) => e.toString()).toList();
        }
      } catch (e) {
        debugPrint("Error loading UOMs: $e");
      }
    }

    // Fetch details for selected item
    Future<void> _fetchItemDetails(String itemCode, void Function(void Function()) setDialogState) async {
      try {
        final res = await http.get(Uri.parse(
          "$GetItemDetails?item_code=$itemCode&company=${_selectedCompany ?? ''}",

        ),  headers:headers);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final details = data["data"]["item_detail"];
          setDialogState(() {
            descCtrl.text = details["description"] ?? "";
            stockUomCtrl.text = details["stock_uom"] ?? "Nos";
            selectedUom = details["stock_uom"] ?? "Nos";
          });
        } else {
          debugPrint("Failed to fetch item details: ${res.body}");
        }
      } catch (e) {
        debugPrint("Error fetching item details: $e");
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          if (loadingItems) {
            loadingItems = false;
            _loadItems().then((_) => setDialogState(() {}));
          }
          if (loadingUoms) {
            loadingUoms = false;
            _loadUom().then((_) => setDialogState(() {}));
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

            title: Text(
              item == null ? "Add Item" : "Edit Item",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ITEM CODE (Searchable Dropdown)
                    DropdownButtonFormField2<String>(
                      decoration: _inputDecoration("Item Code *"),
                      isExpanded: true,
                      value: selectedItemCode,
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        maxHeight: 300,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: TextEditingController(),
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search Item...',
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) async {
                              await _loadItems(search: value);
                              setDialogState(() {});
                            },
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                        },
                      ),
                      items: itemCodes
                          .map((code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      ))
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setDialogState(() {
                          selectedItemCode = value;
                        });
                        await _fetchItemDetails(value, setDialogState);
                      },
                    ),
                    const SizedBox(height: 12),

                    // DESCRIPTION (readonly)
                    TextFormField(
                      controller: descCtrl,
                      readOnly: true,
                      decoration: _inputDecoration("Description"),
                    ),
                    const SizedBox(height: 12),

                    // QUANTITY
                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration("Quantity *"),
                    ),
                    const SizedBox(height: 12),

                    // RATE
                    TextFormField(
                      controller: rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration("Rate *"),
                    ),
                    const SizedBox(height: 12),

                    // STOCK UOM (readonly)
                    TextFormField(
                      controller: stockUomCtrl,
                      readOnly: true,
                      decoration: _inputDecoration("Stock UOM"),
                    ),
                    const SizedBox(height: 12),

                    // UOM (Searchable)
                    DropdownButtonFormField2<String>(
                      decoration: _inputDecoration("UOM"),
                      isExpanded: true,
                      value: selectedUom,
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        maxHeight: 300,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: TextEditingController(),
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search UOM...',
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) async {
                              await _loadUom(search: value);
                              setDialogState(() {});
                            },
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                        },
                      ),
                      items: uoms
                          .map((uom) => DropdownMenuItem<String>(
                        value: uom,
                        child: Text(uom),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUom = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                onPressed: () {
                  final code = selectedItemCode ?? "";
                  final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0;
                  final rate = double.tryParse(rateCtrl.text.trim()) ?? 0;

                  if (code.isEmpty || qty <= 0) {
                    ToastUtils.show(context,"Enter valid item code and quantity");

                    return;
                  }

                  final newItem = PurchaseOrderItem(
                    itemCode: code,
                    description: descCtrl.text.trim(),
                    qty: qty,
                    rate: rate,
                    stockUom: stockUomCtrl.text,
                    uom: selectedUom ?? "Nos",
                  );

                  setState(() {
                    if (index != null) {
                      _items[index] = newItem;
                    } else {
                      _items.add(newItem);
                    }
                    _markUnsaved(1);
                  });
                  Navigator.pop(ctx);
                },
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          );
        });
      },
    );
  }

// 🔹 Helper: modern input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }


  Future<void> _confirmDeleteItem(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to remove this item?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Yes")),
        ],
      ),
    );
    if (ok == true) setState(() {
      _items.removeAt(index);
      _markUnsaved(1);
    });
  }



  /// ---------- Submit ----------
  Map<String, dynamic> _buildPayload() {
    final itemsPayload = _items.map((it) => {
      "doctype": "Purchase Order Item",
      "item_code": it.itemCode,
      "description": it.description,
      "qty": it.qty,
      "rate": it.rate,
      "amount": it.qty * it.rate,
      "stock_uom":it.stockUom,
      "uom":it.uom
    }).toList();

    // final taxesPayload = _taxes.map((t) => {
    //   "description": t.description,
    //   "rate": t.rate,
    // }).toList();

    return {
      "naming_series": _selectedSeries,
      "purchase_type": _selectedPurchaseType,
      "supplier": _selectedSupplier,
      "supplier_name": _supplierName,
      "transaction_date": DateFormat('yyyy-MM-dd').format(_transactionDate),
      "required_by_date": _requiredByController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_requiredByController.text)) : null,
      "purchase_person": _selectedPurchasePerson,
      "po_approver": _selectedPoApprover,
      "currency": _selectedCurrency,
      "company": _selectedCompany,
      "items": itemsPayload,
      "project":_selectedProject,
      "warehouse":_selectedWarehouse
      // // "taxes": taxesPayload,
      // "terms": _terms,
      // // attachments not implemented in this example; you can add file ids if uploaded
    };
  }



  Future<void> _addTaxForSupplier(String supplierName) async {
    try {
      final encodedSupplier = Uri.encodeComponent(supplierName);

      final url = Uri.parse(
          '$GetPartyInfo'
              '?party=$encodedSupplier'
              '&party_type=Supplier'
              '&doctype=Purchase Order'
              '&company=Mantra Softech India Private Limited'
              '&ignore_permissions=1');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiTaxes = data['message']['taxes'] ?? [];

        print(apiTaxes);

        if (apiTaxes.isNotEmpty) {
          // Remove previous supplier taxes
          _taxes.removeWhere((t) => t.supplierTax);
        }

        // Add new taxes from API
        for (var tax in apiTaxes) {
          _taxes.add(TaxLine(
            description: tax['description'] ?? "GST",
            rate: tax['rate']?.toDouble() ?? 0.0,
            amount: 0,
            supplierTax: true,
          ));
        }



        setState(() {});
      } else {
        print('Failed to fetch supplier info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier info: $e');
    }
  }

  Future<void> _submit() async {
    if (!_detailsFormKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }


    _saveTabByIndex(_tabController.index);

    setState(() => _isSubmitting = true);
    try {
      final sid = box.read("SID");
      final payload = _buildPayload();
      print(payload);
      final url = Uri.parse("$CreatePurchaseOrder"); // replace with actual PO creation endpoint
      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        final name = body['data']['name'];
        ToastUtils.show(context,"Purchase Order created: ${name ?? 'Success'}");

        await box.remove('po_saved_details');
        await box.remove('po_saved_items');
        await box.remove('po_saved_taxes');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseOrderListScreen(refresh: true),
          ),
        );
      } else {

        ToastUtils.show(context,"Failed to create PO (${resp.statusCode})");

      }
    } catch (e) {

      ToastUtils.show(context,"Error creating PO: $e");

    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// ---------- UI helpers ----------
  Widget _buildTextFieldLikeDropdown({
    required String label,
    required TextEditingController controller,

    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: maxLines == 1 ? 44 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            minLines: minLines,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _markUnsaved(0),
            decoration: InputDecoration(
              hintText: hint ?? "Enter $label",
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool loading,
    String? hint,
    required int tabIndex,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                value: value,
                hint: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hint ?? "Select $label",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                items: items
                    .map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                    .toList(),
                onChanged: loading ? null : (v) {
                  onChanged(v);
                  _markUnsaved(tabIndex);
                },
                buttonStyleData: ButtonStyleData(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.grey.shade50,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 250,
                  elevation: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: _dropdownSearchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: TextField(
                      controller: _dropdownSearchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        hintText: 'Search...',
                        hintStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value
                        .toString()
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
                onMenuStateChange: (isOpen) {
                  if (!isOpen) _dropdownSearchController.clear();
                },
              ),
            ),

            // Tiny loader on right side
            if (loading)
              const Positioned(
                right: 10,
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ],
    );
  }

  double get _subTotal => _items.fold(0.0, (s, it) => s + (it.qty * it.rate));
  double get _taxTotal {
    double total = 0;
    for (final tax in _taxes) {
      // Calculate tax amount based on current subtotal or grand total
      total += _subTotal * (tax.rate / 100.0);
      // Also update the individual tax amount in TaxLine if you want
      tax.amount = _subTotal * (tax.rate / 100.0);
    }
    return total;
  }

  double get _grandTotal => _subTotal + _taxTotal;

  // ---------------- Build UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Purchase Order"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          // IMPORTANT: intercept taps to confirm save/discard when leaving current tab
          onTap: (newIndex) async {
            final currentIndex = _tabController.index;
            if (newIndex == currentIndex) return;
            final ok = await _confirmSaveDiscardIfUnsaved(currentIndex);
            if (ok) {
              // restore next tab from savedForm in case we discarded
              _restoreTabByIndex(newIndex);
              _tabController.animateTo(newIndex);
            }
            // if ok==false (user cancelled), do nothing - stay on current tab
          },
          tabs: const [
            Tab(text: "Details"),
            Tab(text: "Items"),
            Tab(text: "Taxes"),



          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // disable swipe to prevent bypassing onTap confirmation
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ---------------- DETAILS TAB ----------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _detailsFormKey,
              child: ListView(
                children: [
                  // Naming Series
                  _buildDropdownField(
                    label: "Naming Series *",
                    value: _selectedSeries,
                    items: _namingSeries,
                    onChanged: (v) => setState(() => _selectedSeries = v),
                    loading: _loadingNamingSeries,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // Purchase Type
                  _buildDropdownField(
                    label: "Purchase Type *",
                    value: _selectedPurchaseType,
                    items: _purchaseTypes,
                    onChanged: (v) => setState(() => _selectedPurchaseType = v),
                    loading: _loadingPurchaseTypes,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // Supplier
                  _buildDropdownField(
                    label: "Supplier *",
                    value: _selectedSupplier,
                    items: _suppliers,
                    onChanged: (v) async {
                      setState(() {
                        _selectedSupplier = v;
                        _supplierName = null;
                      });
                      if (v != null && v.isNotEmpty) {
                        await _fetchSupplierName(v);
                        _markUnsaved(0);
                        _addTaxForSupplier(v);
                      }
                    },
                    loading: _loadingSuppliers,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // Supplier Name
                  if (_selectedSupplier != null && _supplierName != null) ...[
                    _buildTextFieldLikeDropdown(
                      label: "Supplier Name",
                      controller: TextEditingController(text: _supplierName),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildTextFieldLikeDropdown(
                    label: "Purchase Order Date",
                    controller: _transactionDateController,
                    readOnly: true,
                    hint: "Select Date",
                    onTap: _pickTransactionDate,
                  ),
                  const SizedBox(height: 12),

                  // Required By Date
                  _buildTextFieldLikeDropdown(
                    label: "Required By Date *",
                    controller: _requiredByController,
                    readOnly: true,
                    hint: "Select Date",
                    onTap: _pickRequiredByDate,
                  ),
                  const SizedBox(height: 12),

                  // Purchase Person
                  _buildDropdownField(
                    label: "Purchase Person *",
                    value: _selectedPurchasePerson,
                    items: _purchasePersons,
                    onChanged: (v) => setState(() => _selectedPurchasePerson = v),
                    loading: _loadingPurchasePersons,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // PO Approver
                  _buildDropdownField(
                    label: "PO Approver *",
                    value: _selectedPoApprover,
                    items: _poApprovers,
                    onChanged: (v) => setState(() => _selectedPoApprover = v),
                    loading: _loadingApprovers,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // Currency
                  _buildDropdownField(
                    label: "Currency *",
                    value: _selectedCurrency,
                    items: _currencies,
                    onChanged: (v) => setState(() => _selectedCurrency = v),
                    loading: _loadingCurrencies,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  _buildDropdownField(
                    label: "Project *",
                    value: _selectedProject,
                    items: _projects,
                    onChanged: (v) => setState(() => _selectedProject = v),
                    loading: _loadingProjects,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  _buildDropdownField(
                    label: "Warehouse *",
                    value: _selectedWarehouse,
                    items: _warehouses,
                    onChanged: (v) => setState(() => _selectedWarehouse = v),
                    loading: _loadingWarehouses,
                    tabIndex: 0,
                  ),
                  const SizedBox(height: 12),

                  // Company
                  _buildTextFieldLikeDropdown(
                    label: "Company",
                    controller: TextEditingController(text: _selectedCompany),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),



                  const SizedBox(height: 20),


                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        _saveDetailsTab();
                        _saveItemsTab();
                        _saveTaxesTab();
                        print(_savedForm);
                        List<String> missingFields = [];

                        List<String> requiredFields = [
                          "supplier",
                          "naming_series",
                          "purchase_type",
                          "purchase_person",
                          "po_approver",
                          "currency",
                          "project",
                          "warehouse",
                          "company",
                          "items",
                        ];


                        for (var field in requiredFields) {
                          dynamic value;

                          // Items is at root, all others are inside details
                          if (field == "items") {
                            value = _savedForm[field];
                          } else {
                            value = _savedForm['details'][field];
                          }

                          // Now check empty/null value
                          if ((value is String && value.isEmpty) ||
                              (value is List && value.isEmpty) ||
                              value == null) {

                            missingFields.add(
                                field
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map((w) => "${w[0].toUpperCase()}${w.substring(1)}")
                                    .join(' ')
                            );
                          }
                        }



                        // Add more checks for other mandatory fields as needed

                        if (missingFields.isNotEmpty) {
                          // Show error dialog
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, size: 50, color: Colors.red),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Mandatory Fields Missing",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Please fill the following fields:",
                                        style: TextStyle(fontSize: 16, color: Colors.black54),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      // List of missing fields
                                      ...missingFields.map((f) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Icon(Icons.circle, size: 8, color: Colors.redAccent),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                f,
                                                style: TextStyle(fontSize: 16, color: Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text(
                                            "OK",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          return; // stop further execution
                        }


                        final shouldSave = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Create"),
                            content: const Text("Do you want to Create Purchase Order?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );

                        if (shouldSave == true) {
                          await _submit();
                        }
                      },
                      label: const Text("Create"),
                    ),
                  ),



                ],
              ),
            ),
          ),

          // ---------------- ITEMS TAB ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(onPressed: () => _showAddEditItemDialog(), icon: const Icon(Icons.add), label: const Text("Add Item")),
                    const SizedBox(width: 12),

                    const Spacer(),
                    Text("Sub Total: ${_subTotal.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text("No items added"))
                      : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final it = _items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(it.itemCode),
                          subtitle: Text("${it.description}\nQty: ${it.qty} × Rate: ${it.rate.toStringAsFixed(2)}"),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') _showAddEditItemDialog(item: it, index: i);
                              if (val == 'delete') _confirmDeleteItem(i);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [


                    const Spacer(),
                    Text("Grand Total: ${_grandTotal.toStringAsFixed(2)}"),
                  ],
                )
              ],
            ),
          ),

          // ---------------- TAXES TAB ----------------
                  Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
    children: [
    Row(
    children: [

    const Spacer(),
    Text(
    "Tax Total: ${_taxTotal.toStringAsFixed(2)}",
    style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    ],
    ),
    const SizedBox(height: 12),

    // Display tax lines as cards
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _taxes.length,
        itemBuilder: (context, index) {
          final tax = _taxes[index];
          final amount = _subTotal * (tax.rate / 100); // calculate tax amount

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                tax.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "Amount: ₹${amount.toStringAsFixed(2)}", // show calculated amount
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              trailing: Text(
                "${tax.rate.toStringAsFixed(2)}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),

    ],
    ),
    )],
    ),

    );
  }
}

/// Simple models used in this single-file screen
class PurchaseOrderItem {
  String itemCode;
  String description;
  double qty;
  double rate;
  String stockUom;
  String uom;

  PurchaseOrderItem({
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.rate,
    this.stockUom = "Nos",
    this.uom = "Nos",
  });

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "description": description,
    "qty": qty,
    "rate": rate,
    "stock_uom": stockUom,
    "uom": uom,
  };
}

class TaxLine {
  String description;
  double rate;
  double amount;       // calculated tax amount
  bool supplierTax;    // indicates if tax is from supplier

  TaxLine({
    required this.description,
    required this.rate,
    this.amount = 0.0,           // default 0
    this.supplierTax = false,    // default false for manually added taxes
  });
}
