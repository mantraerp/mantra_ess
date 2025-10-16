class PaymentEntry {
  final String id;
  final String partyName;
  final double amount;
  final String? remarks;

  PaymentEntry({
    required this.id,
    required this.partyName,
    required this.amount,
    this.remarks,
  });

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      id: json['name'] ?? '',
      partyName: json['party_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'party_name': partyName,
      'amount': amount,
      'remarks': remarks,
    };
  }
}
