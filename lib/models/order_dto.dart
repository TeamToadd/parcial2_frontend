class OrderDto {
  final int id;
  final int clientUserId;
  final int companyUserId;
  final DateTime createdAt;
  final int status; // 0..3
  final double total;
  final List<ItemDto> items;

  OrderDto({
    required this.id,
    required this.clientUserId,
    required this.companyUserId,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.items,
  });

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
        id: j['id'],
        clientUserId: j['clientUserId'],
        companyUserId: j['companyUserId'],
        createdAt: DateTime.parse(j['createdAt']),
        status: j['status'],
        total: (j['total'] as num).toDouble(),
        items: (j['items'] as List? ?? [])
            .map((e) => ItemDto.fromJson(e))
            .toList(),
      );
}

class ItemDto {
  final int productId;
  final String? productName;
  final int quantity;
  final double unitPrice;

  ItemDto({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory ItemDto.fromJson(Map<String, dynamic> j) => ItemDto(
        productId: j['productId'],
        productName: j['productName'],
        quantity: j['quantity'],
        unitPrice: (j['unitPrice'] as num).toDouble(),
      );
}
