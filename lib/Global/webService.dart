// const String BASE_URL= "https://smartfzco.milaap.ai";
// const String BASE_URL= "https://mantratec.milaap.ai";
const String BASE_URL = "http://192.168.11.66:8011";

const String SUB_BASE_URL = BASE_URL + "/api/method/";
const String SUB_RESOURCE_URL = BASE_URL + "/resource/";

const String URLLogin = SUB_BASE_URL + "erp_mobile.api.login.login";
const String URLOTPVerification =
    SUB_BASE_URL + "erp_mobile.api.login.verify_code";
const String URLGetMenu =
    SUB_BASE_URL + "erp_mobile.api.masterdata.check_serial_no";

const String URLGetProfile =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_user_profile";

const String URLGetAttendance =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_attendance";


const String URLLogout = SUB_BASE_URL + "logout";

const String URLGetSalarySlip =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_salary_slips";


const String DownloadSalarySlip =
    SUB_BASE_URL + "erp_mobile.api.masterdata.download_salary_slip";

const String GetPurchaseOrders =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_order.get_purchase_orders";

const String GetPurchaseOrderStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_order.get_po_status";

const String GetPurchaseOrderDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_order.purchase_order_details";

const String GetSalesOrders =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_order.get_sales_orders";

const String GetSalesOrderStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_order.get_so_status";

const String GetSalesOrderDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_order.so_details";

const String GetSalesInvoices =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_invoice.get_sales_invoices";

const String GetSalesInvoiceStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_invoice.get_si_status";

const String GetSalesInvoiceDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.sales_invoice.get_sales_invoice_details";

const String GetActivityLogs =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.activity.get_activity_logs";


const String GetDeliveryNotes =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.delivery_note.get_delivery_notes";

const String GetDeliveryNoteStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.delivery_note.get_dn_status";

const String GetDeliveryNoteDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.delivery_note.get_delivery_note_details";





const String GetPurchaseReceipts =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_receipt.get_purchase_receipts";

const String GetPurchaseReceiptStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_receipt.get_pr_status";

const String GetPurchaseReceiptDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_receipt.get_purchase_receipt_details";


const String GetPurchaseInvoices =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_invoice.get_purchase_invoices";

const String GetPurchaseInvoiceStatus =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_invoice.get_pi_status";

const String GetPurchaseInvoiceDetail =
    "http://192.168.11.66:8017/api/method/" + "erp_mobile.api.purchase_invoice.get_purchase_invoice_details";