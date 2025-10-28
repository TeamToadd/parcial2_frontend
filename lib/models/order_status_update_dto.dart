class OrderStatusUpdateDto {
  final int status; // 0..3
  OrderStatusUpdateDto(this.status);
  Map<String, dynamic> toJson() => {'status': status};
}
