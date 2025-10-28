class ProductCreateDto {
  final String name;
  final String? description;
  final double? price;
  final int? stock;
  final String? imageUrl;

  ProductCreateDto({
    required this.name,
    this.description,
    this.price,
    this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
      };
}
