class SalarySlip {
  final String id;
  final String party;
  final String partyName;
  final double amount;
  final String? bankName;
  final String? bankAccount;
  final String postingDate;
  final String payrollEntry;
  final String? remarks;

  SalarySlip({
    required this.id,
    required this.party,
    required this.partyName,
    required this.amount,
    this.bankName,
    this.bankAccount,
    required this.postingDate,
    required this.payrollEntry,
    this.remarks,
  });

  factory SalarySlip.fromJson(Map<String, dynamic> json) {
    return SalarySlip(
      id: json['name'],
      party: json['party'],
      partyName: json['party_name'],
      amount: (json['base_paid_amount_after_tax'] ?? 0).toDouble(),
      bankName: json['bank_name'],
      bankAccount: json['bank_account_no'],
      postingDate: json['posting_date'],
      payrollEntry: json['payroll_entry'],
      remarks: "Payroll: ${json['payroll_entry']}",
    );
  }
}
