class ProductDto {
  final int id;
  final int companyUserId;
  final String? name;
  final String? description;
  final double? price;
  final int stock;
  final String? imageUrl;
  final double? avgRating;

  ProductDto({
    required this.id,
    required this.companyUserId,
    this.name,
    this.description,
    this.price,
    required this.stock,
    this.imageUrl,
    this.avgRating,
  });

  factory ProductDto.fromJson(Map<String, dynamic> j) => ProductDto(
        id: j['id'],
        companyUserId: j['companyUserId'],
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num?)?.toDouble(),
        stock: j['stock'] ?? 0,
        imageUrl: j['imageUrl'],
        avgRating: (j['avgRating'] as num?)?.toDouble(),
      );
}
