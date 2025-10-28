class OrderItemReq {
  final int productId;
  final int quantity;
  OrderItemReq({required this.productId, this.quantity = 1});
  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}

class OrderCreateDto {
  final int companyUserId;
  final List<OrderItemReq> items;
  OrderCreateDto({required this.companyUserId, required this.items});
  Map<String, dynamic> toJson() =>
      {'companyUserId': companyUserId, 'items': items.map((e) => e.toJson()).toList()};
}
