class LineItem {
  final int? id;
  final String itemName;
  final double? itemPrice;

  LineItem({
    this.id,
    required this.itemName,
    this.itemPrice,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      id: json['id'],
      itemName: json['item_name'],
      itemPrice: json['item_price'] != null ? (json['item_price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'item_name': itemName,
      if (itemPrice != null) 'item_price': itemPrice,
    };
  }
}

class Document {
  final int? id;
  final String? imagePath;
  final String docType;
  final String? merchantName;
  final String? docDate;
  final double? totalAmount;
  final String currency;
  final String? rawText;
  final List<LineItem> items;

  Document({
    this.id,
    this.imagePath,
    this.docType = 'receipt',
    this.merchantName,
    this.docDate,
    this.totalAmount,
    this.currency = 'USD',
    this.rawText,
    this.items = const [],
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int?,
      imagePath: json['image_path'] as String?,
      docType: json['doc_type'] as String? ?? 'receipt',
      merchantName: json['merchant_name'] as String?,
      docDate: json['doc_date'] as String?,
      totalAmount: json['total_amount'] != null ? (json['total_amount'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? 'USD',
      rawText: json['raw_text'] as String?,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => LineItem.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      'doc_type': docType,
      if (merchantName != null) 'merchant_name': merchantName,
      if (docDate != null) 'doc_date': docDate,
      if (totalAmount != null) 'total_amount': totalAmount,
      'currency': currency,
      if (rawText != null) 'raw_text': rawText,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
