class KinaTransaction {
  int? id;
  DateTime? date;
  String? transactionType; // income or expense
  String? basket; // Sylver or Ruth
  String? description;
  double? amount;
  bool? split;
  bool? paid;
  bool? isSelected;
  KinaTransaction({
    this.id,
    this.date,
    this.transactionType,
    this.basket,
    this.description,
    this.amount,
    this.split,
    this.paid,
    this.isSelected = false,
  });

  transactionMap() {
    var mapping = <String, dynamic>{};
    mapping['id'] = id;
    mapping['date'] = date?.toIso8601String();
    mapping['transaction_type'] = transactionType;
    mapping['basket'] = basket;
    mapping['description'] = description;
    mapping['amount'] = amount;
    mapping['split'] = split! ? 1 : 0;
    mapping['paid'] = paid! ? 1 : 0;
    return mapping;
  }
}
