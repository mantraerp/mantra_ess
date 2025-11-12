// create_purchase_order_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mantra_ess/Global/constant.dart';

// ---------------------
// Edit these to match your server (GetPoNamingSeries etc. should be provided in webService)
// ---------------------

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

  // Saved form per tab (in-memory)
  final Map<String, dynamic> _savedForm = {
    "details": {},
    "items": {},
    "taxes": {},
    "terms": {},
    "attachments": {},
  };

  // Track unsaved changes per tab
  final Map<int, bool> _unsaved = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
  };

  // Form keys and controllers
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _transactionDateController =
  TextEditingController();
  final TextEditingController _requiredByController = TextEditingController();
  final TextEditingController _odooPoController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  DateTime _transactionDate = DateTime.now();

  // Details fields
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


  // Dropdown data and loading flags
  List<String> _namingSeries = [];
  List<String> _purchaseTypes = [];
  List<String> _suppliers = [];
  List<String> _purchasePersons = [];
  List<String> _poApprovers = [];
  List<String> _currencies = [];

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

  // Items child table
  List<PurchaseOrderItem> _items = [];

  // Taxes (simple)
  // List<TaxLine> _taxes = [];

  // Terms
  List<String> _terms = [];

  // Attachments placeholder (store file paths or server ids once implemented)
  List<String> _attachments = [];

  // Submit state
  bool _isSubmitting = false;

  // Dropdown search controller used by DropdownButton2
  final TextEditingController _dropdownSearchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    final box = GetStorage();
    print(widget.isNew);
    // 🟠 Clear previous draft if this is a new PO
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

    // Attach listeners to mark unsaved
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

  // ---------------- Persistent storage helpers ----------------
  void _loadSavedFromStorage() {
    // Load each tab saved JSON (if present)
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

      final tr = box.read('po_saved_terms');
      if (tr != null && tr is List) {
        _savedForm['terms'] = List<String>.from(tr);
        _restoreTermsTab();
      }

      final at = box.read('po_saved_attachments');
      if (at != null && at is List) {
        _savedForm['attachments'] = List<String>.from(at);
        _restoreAttachmentsTab();
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
        case 'terms':
          await box.write('po_saved_terms', _savedForm['terms']);
          break;
        case 'attachments':
          await box.write('po_saved_attachments', _savedForm['attachments']);
          break;
      }
    } catch (e) {
      debugPrint("Error persisting $tabKey to storage: $e");
    }
  }

  // ---------------- mark unsaved ----------------
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

  /// ---------- Tab save / restore ----------
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
      case 3:
        _saveTermsTab();
        break;
      case 4:
        _saveAttachmentsTab();
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
      case 3:
        _restoreTermsTab();
        break;
      case 4:
        _restoreAttachmentsTab();
        break;
    }
  }

  /// ---------- Load dropdown data ----------
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
      final sid = box.read("SID");
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
        print(data);
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

  /// ---------- Fetch supplier display name ----------
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

  /// ---------- Date pickers ----------
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

  /// ---------- Save/Restore for each tab ----------
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
    // persist
    _persistTabToStorage('details');
    _clearUnsaved(0);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Details saved")));
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
    // _items is already the canonical list; save a serializable copy
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Items saved")));
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
    // _savedForm['taxes'] =
    //     _taxes.map((t) => {'description': t.description, 'rate': t.rate}).toList();
    _persistTabToStorage('taxes');
    _clearUnsaved(2);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Taxes saved")));
  }

  void _restoreTaxesTab() {
    // final data = _savedForm['taxes'];
    // if (data is List) {
    //   setState(() {
    //     _taxes = data.map<TaxLine>((m) {
    //       return TaxLine(
    //           description: (m['description'] ?? '').toString(),
    //           rate: (m['rate'] is num)
    //               ? (m['rate'] as num).toDouble()
    //               : double.tryParse((m['rate'] ?? '0').toString()) ?? 0);
    //     }).toList();
    //   });
    // }
  }

  void _saveTermsTab() {
    _savedForm['terms'] = List<String>.from(_terms);
    _persistTabToStorage('terms');
    _clearUnsaved(3);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Terms saved")));
  }

  void _restoreTermsTab() {
    final data = _savedForm['terms'];
    if (data is List) {
      setState(() => _terms = List<String>.from(data));
    }
  }

  void _saveAttachmentsTab() {
    _savedForm['attachments'] = List<String>.from(_attachments);
    _persistTabToStorage('attachments');
    _clearUnsaved(4);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Attachments saved")));
  }

  void _restoreAttachmentsTab() {
    final data = _savedForm['attachments'];
    if (data is List) setState(() => _attachments = List<String>.from(data));
  }

  /// ---------- Confirm before navigating (used by TabBar onTap) ----------
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
        ));
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter valid item code and quantity")),
                    );
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

  /// ---------- Taxes & Terms simple editors ----------
  Future<void> _addTaxLine() async {
    final desc = TextEditingController();
    final rate = TextEditingController(text: "0");
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Add Tax Line"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 8),
            TextFormField(controller: rate, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Rate (%)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // setState(() {
              //   _taxes.add(TaxLine(description: desc.text.trim(), rate: double.tryParse(rate.text) ?? 0));
              //   _markUnsaved(2);
              // });
              Navigator.pop(c);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addTerm() async {
    final t = TextEditingController();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Add Term/Condition"),
        content: TextFormField(controller: t, decoration: const InputDecoration(labelText: "Term")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => setState(() {
            _terms.add(t.text.trim());
            _markUnsaved(3);
            Navigator.pop(c);
          }), child: const Text("Add")),
        ],
      ),
    );
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
      // // "taxes": taxesPayload,
      // "terms": _terms,
      // // attachments not implemented in this example; you can add file ids if uploaded
    };
  }

  Future<void> _submit() async {
    if (!_detailsFormKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    if (_items.isEmpty) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one item")));
      return;
    }

    // Make sure last tab is saved before final submission
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Purchase Order created: ${name ?? 'Success'}")));
        // clear saved storage and in-memory forms after successful submit
        await box.remove('po_saved_details');
        await box.remove('po_saved_items');
        await box.remove('po_saved_taxes');
        await box.remove('po_saved_terms');
        await box.remove('po_saved_attachments');
        Navigator.pop(context, true);
      } else {
        debugPrint("Create PO failed: ${resp.statusCode} ${resp.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create PO (${resp.statusCode})")));
      }
    } catch (e) {
      debugPrint("Create PO error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error creating PO: $e")));
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
    double t = 0;
    // for (final tax in _taxes) {
    //   t += _subTotal * (tax.rate / 100.0);
    // }
    return t;
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
            Tab(text: "Terms"),
            Tab(text: "Attachment"),


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
                    width: double.infinity, // full width
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        final shouldSave = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false, // user must choose Yes/No
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Save"),
                            content: const Text("Do you want to save details before proceeding?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false), // No
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), // Yes
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );

                        if (shouldSave == true) {
                          await _saveDetailsTab; // ✅ call the function (you missed parentheses earlier)
                        }

                        // ✅ Navigate to next tab in both cases
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Save"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity, // full width
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        final shouldSave = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false, // user must choose Yes/No
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Create"),
                            content: const Text("Do you want to Create Purchase Order?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false), // No
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), // Yes
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );

                        if (shouldSave == true) {
                          await _submit(); // ✅ call the function (you missed parentheses earlier)
                        }


                      },
                      icon: const Icon(Icons.arrow_forward),
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
                    ElevatedButton.icon(onPressed: _items.isNotEmpty ? () => _tabController.animateTo(2) : null, icon: const Icon(Icons.check), label: const Text("Done")),
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
                    ElevatedButton.icon(onPressed: _addTaxLine, icon: const Icon(Icons.add), label: const Text("Add Tax")),
                    const Spacer(),
                    Text("Tax Total: ${_taxTotal.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 12),
                // Expanded(
                //   child: _taxes.isEmpty
                //       ? const Center(child: Text("No tax lines"))
                //       : ListView.builder(
                //     itemCount: _taxes.length,
                //     itemBuilder: (ctx, i) {
                //       final t = _taxes[i];
                //       return ListTile(
                //         title: Text(t.description.isNotEmpty ? t.description : "Tax ${i + 1}"),
                //         subtitle: Text("Rate: ${t.rate}%"),
                //         trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {
                //           setState(() {
                //             _taxes.removeAt(i);
                //             _markUnsaved(2);
                //           });
                //         }),
                //       );
                //     },
                //   ),
                // ),
                Row(
                  children: [
                    ElevatedButton(onPressed: _saveTaxesTab, child: const Text("Save Taxes")),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () async {
                      final ok = await _confirmSaveDiscardIfUnsaved(2);
                      if (ok) _tabController.animateTo(3);
                    }, child: const Text("Go to Terms")),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- TERMS TAB ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton.icon(onPressed: _addTerm, icon: const Icon(Icons.add), label: const Text("Add Term")),
                const SizedBox(height: 12),
                Expanded(
                  child: _terms.isEmpty
                      ? const Center(child: Text("No terms added"))
                      : ListView.builder(
                    itemCount: _terms.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(_terms[i]),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {
                          setState(() {
                            _terms.removeAt(i);
                            _markUnsaved(3);
                          });
                        }),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(onPressed: _saveTermsTab, child: const Text("Save Terms")),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () async {
                      final ok = await _confirmSaveDiscardIfUnsaved(3);
                      if (ok) _tabController.animateTo(4);
                    }, child: const Text("Go to Attachments")),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- ATTACHMENTS TAB ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // placeholder: implement file picker & upload
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File upload not implemented in this sample")));
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Add Attachment"),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _attachments.isEmpty ? const Center(child: Text("No attachments")) : ListView.builder(
                    itemCount: _attachments.length,
                    itemBuilder: (ctx, i) => ListTile(title: Text(_attachments[i])),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(onPressed: _saveAttachmentsTab, child: const Text("Save Attachments")),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () async {
                      final ok = await _confirmSaveDiscardIfUnsaved(4);
                      if (ok) _tabController.animateTo(0);
                    }, child: const Text("Back to Details")),
                    const Spacer(),
                       ],
                ),
              ],
            ),
          ),
        ],
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

