// const String BASE_URL= "https://smartfzco.milaap.ai";
// const String BASE_URL= "https://mantratec.milaap.ai";
const String BASE_URL = "http://192.168.11.66:8014";

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

const String GetExpenseClaims =
    SUB_BASE_URL + "erp_mobile.api.expense_claim.get_expences";

const String DeleteExpenseClaim =
    SUB_BASE_URL + "erp_mobile.api.expense_claim.delete_expense";

const String GetExpenseClaimName =
    SUB_BASE_URL + "erp_mobile.api.expense_claim.get_expense_claim_name";

const String CreateExpenseClaim =
    SUB_BASE_URL + "erp_mobile.api.expense_claim.create_expense_claim";


const String uploadAttachment =
    SUB_BASE_URL + "erp_mobile.api.attach.upload_attachment";

const String DeleteAttachment =
    SUB_BASE_URL + "erp_mobile.api.attach.remove_file";




const String URLLogout = SUB_BASE_URL + "logout";

const String URLGetSalarySlip =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_salary_slips";


const String DownloadSalarySlip =
    SUB_BASE_URL + "erp_mobile.api.masterdata.download_salary_slip";

const String GetPurchaseOrders =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_purchase_orders";

const String CreatePurchaseOrder =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.create_purchase_order";

const String GetPartyInfo =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_party_info";

const String GetHoliday =
    SUB_BASE_URL + "erp_mobile.api.holiday.get_holidays";
const String GetPurchaseOrderStatus =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_po_status";

const String GetPurchaseOrderDetail =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.purchase_order_details";

const String GetItemDetails =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_item_details";

const String GetItemList =
    SUB_BASE_URL + "erp_mobile.api.item.get_item_list";

const String GetItemAndStockDetail =
    SUB_BASE_URL + "erp_mobile.api.item.get_item_details";

const String GetSalesOrders =
    SUB_BASE_URL + "erp_mobile.api.sales_order.get_sales_orders";

const String GetSalesOrderStatus =
    SUB_BASE_URL + "erp_mobile.api.sales_order.get_so_status";

const String GetSalesOrderDetail =
    SUB_BASE_URL + "erp_mobile.api.sales_order.so_details";

const String GetSalesInvoices =
    SUB_BASE_URL + "erp_mobile.api.sales_invoice.get_sales_invoices";

const String GetSalesInvoiceStatus =
    SUB_BASE_URL + "erp_mobile.api.sales_invoice.get_si_status";

const String GetSalesInvoiceDetail =
    SUB_BASE_URL + "erp_mobile.api.sales_invoice.get_sales_invoice_details";

const String GetActivityLogs =
    SUB_BASE_URL + "erp_mobile.api.activity.get_activity_logs";


const String GetDeliveryNotes =
    SUB_BASE_URL + "erp_mobile.api.delivery_note.get_delivery_notes";

const String GetDeliveryNoteStatus =
    SUB_BASE_URL + "erp_mobile.api.delivery_note.get_dn_status";

const String GetDeliveryNoteDetail =
    SUB_BASE_URL + "erp_mobile.api.delivery_note.get_delivery_note_details";





const String GetPurchaseReceipts =
    SUB_BASE_URL + "erp_mobile.api.purchase_receipt.get_purchase_receipts";

const String GetPurchaseReceiptStatus =
    SUB_BASE_URL + "erp_mobile.api.purchase_receipt.get_pr_status";

const String GetPurchaseReceiptDetail =
    SUB_BASE_URL + "erp_mobile.api.purchase_receipt.get_purchase_receipt_details";


const String GetPurchaseInvoices =
    SUB_BASE_URL + "erp_mobile.api.purchase_invoice.get_purchase_invoices";

const String GetPurchaseInvoiceStatus =
    SUB_BASE_URL + "erp_mobile.api.purchase_invoice.get_pi_status";

const String GetPurchaseInvoiceDetail =
    SUB_BASE_URL + "erp_mobile.api.purchase_invoice.get_purchase_invoice_details";


const String GetMasterList =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_master_list";

const String GetMaterialRequest =
    SUB_BASE_URL + "erp_mobile.api.material_request.get_material_requests";

const String GetMateriaRequestStatus =
    SUB_BASE_URL + "erp_mobile.api.material_request.get_mr_purpose_series";


const String GetMateriaRequestDetail =
    SUB_BASE_URL + "erp_mobile.api.material_request.get_material_request_details";


const String PaymentPagePaymentEntries =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_payment_entries";


const String PaymentPageApprovePaymentEntries =
    SUB_BASE_URL + "erp_mobile.api.payment_page_approve.get_payment_entries";


const String PaymentPageRefrenceDetails =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_payment_entry_reference_details";


const String PaymentPageUpdateRemark =
    SUB_BASE_URL + "erp_mobile.api.payment_page.update_payment_entry_remark";


const String PaymentPageBankList =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_banks";


const String PaymentPageBankAccountList =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_bank_accounts";


const String PaymentPageMonthList =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_payroll_months";


const String PaymentPageCancelPaymentEntry =
    SUB_BASE_URL + "erp_mobile.api.payment_page.cancel_payment_entries";


const String PaymentPageApprovePaymentEntry =
    SUB_BASE_URL + "erp_mobile.api.payment_page_approve.approve_payment_entries";

const String PaymentPageApproveHoldPaymentEntry =
    SUB_BASE_URL + "erp_mobile.api.payment_page_approve.hold_payment_entries";

const String PaymentPagePayrollEntriesList =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_payroll_entries";


const String PaymentPageSalarySlipsList =
    SUB_BASE_URL + "erp_mobile.api.payment_page.get_salary_slips";


const String PaymentPageHoldSalarySlip =
    SUB_BASE_URL + "erp_mobile.api.payment_page.hold_salary_slip";

const String PaymentPageSendOtp =
    SUB_BASE_URL + "erp_mobile.api.payment_page.send_otp_api";

const String PaymentPageVerifyOtp =
    SUB_BASE_URL + "erp_mobile.api.payment_page.verify_otp_api";



const String GetPoPurchaseType =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_purchase_type";

const String GetPoApprover =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_po_approver";

const String GetPoNamingSeries =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_po_series";

const String GetPartyName =
    SUB_BASE_URL + "erp_mobile.api.purchase_order.get_party_name";


const String GetPolicyDetails =
    SUB_BASE_URL + "erp_mobile.api.policy.get_policy_details";


const String GetPolicy =
    SUB_BASE_URL + "erp_mobile.api.policy.get_policies";

const String GetSerialorBatchNumber =
    SUB_BASE_URL + "erp_mobile.api.serial_no.check_serial_or_batch";

const String GetTrackDetails =
    SUB_BASE_URL + "erp_mobile.api.serial_no.track_batch_details";

const String GetSerialTrackDetails =
    SUB_BASE_URL + "erp_mobile.api.serial_no.track_serial_number";