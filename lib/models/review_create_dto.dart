class ReviewCreateDto {
  final int productId;
  final int rating; // 1..5
  final String? comment;

  ReviewCreateDto({required this.productId, required this.rating, this.comment});

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'rating': rating, 'comment': comment};
}
