class SalesInvoiceSummaryModel {
  final int id;
  final String invoiceNo;
  final String invoiceDate;
  final int? customerId;
  final String customerName;
  final String? customerCompany;
  final double grandTotal;
  final double balanceDue;
  final String paymentStatus;
  final String status;

  SalesInvoiceSummaryModel({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    this.customerId,
    required this.customerName,
    this.customerCompany,
    required this.grandTotal,
    required this.balanceDue,
    required this.paymentStatus,
    required this.status,
  });

  factory SalesInvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceSummaryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      customerId: json['customer_id'] != null ? int.tryParse(json['customer_id'].toString()) : null,
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerCompany: json['customer_company']?.toString(),
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      balanceDue: double.tryParse(json['balance_due']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      status: json['status']?.toString() ?? 'confirmed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_company': customerCompany,
      'grand_total': grandTotal.toStringAsFixed(2),
      'balance_due': balanceDue.toStringAsFixed(2),
      'payment_status': paymentStatus,
      'status': status,
    };
  }

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
}

class SalesInvoiceItemModel {
  final int id;
  final String itemName;
  final double quantity;
  final double rate;
  final double gstRate;
  final double totalAmount;

  SalesInvoiceItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.gstRate,
    required this.totalAmount,
  });

  factory SalesInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
      gstRate: double.tryParse(json['gst_rate']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity.toStringAsFixed(2),
      'rate': rate.toStringAsFixed(2),
      'gst_rate': gstRate.toStringAsFixed(2),
      'total_amount': totalAmount.toStringAsFixed(2),
    };
  }
}

class SalesInvoiceDetailModel {
  final int id;
  final String invoiceNo;
  final String invoiceDate;
  final String customerName;
  final String? customerPhone;
  final String? customerGstin;
  final double subTotal;
  final double taxAmount;
  final double grandTotal;
  final String paymentStatus;
  final List<SalesInvoiceItemModel> items;

  SalesInvoiceDetailModel({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    this.customerPhone,
    this.customerGstin,
    required this.subTotal,
    required this.taxAmount,
    required this.grandTotal,
    required this.paymentStatus,
    required this.items,
  });

  factory SalesInvoiceDetailModel.fromJson(Map<String, dynamic> json, List<dynamic> itemsJson) {
    final invMap = json['invoice'] is Map<String, dynamic> ? json['invoice'] as Map<String, dynamic> : json;
    final parsedItems = itemsJson.map((i) => SalesInvoiceItemModel.fromJson(i as Map<String, dynamic>)).toList();

    return SalesInvoiceDetailModel(
      id: invMap['id'] is int ? invMap['id'] : int.tryParse(invMap['id']?.toString() ?? '0') ?? 0,
      invoiceNo: invMap['invoice_no']?.toString() ?? '',
      invoiceDate: invMap['invoice_date']?.toString() ?? '',
      customerName: invMap['customer_name']?.toString() ?? 'Customer',
      customerPhone: invMap['customer_phone']?.toString(),
      customerGstin: invMap['customer_gstin']?.toString(),
      subTotal: double.tryParse(invMap['sub_total']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(invMap['tax_amount']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(invMap['grand_total']?.toString() ?? '0') ?? 0.0,
      paymentStatus: invMap['payment_status']?.toString() ?? 'unpaid',
      items: parsedItems,
    );
  }
}

