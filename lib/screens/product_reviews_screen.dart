import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/review_create_dto.dart';

class ProductReviewsScreen extends StatefulWidget {
  final int productId;
  const ProductReviewsScreen({super.key, required this.productId});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  List<dynamic> reviews = [];
  final comment = TextEditingController();
  int rating = 5;

  Future<void> _load() async {
    reviews = await ApiService.instance.productReviews(widget.productId);
    setState(() {});
  }

  Future<void> _send() async {
    await ApiService.instance.createReview(ReviewCreateDto(productId: widget.productId, rating: rating, comment: comment.text.trim()));
    comment.clear();
    _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (_, i) => ListTile(title: Text('⭐ ${reviews[i]['rating'] ?? '-'}'), subtitle: Text(reviews[i]['comment']?.toString() ?? '')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              DropdownButton<int>(
                value: rating,
                items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text('⭐ $e'))).toList(),
                onChanged: (v) => setState(() => rating = v ?? 5),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: comment, decoration: const InputDecoration(labelText: 'Comentario'))),
              const SizedBox(width: 12),
              FilledButton(onPressed: _send, child: const Text('Enviar'))
            ]),
          )
        ],
      ),
    );
  }
}
