import 'package:flutter/material.dart';
import '../models/product_dto.dart';

class ProductTile extends StatelessWidget {
  final ProductDto p;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductTile({super.key, required this.p, this.onAdd, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: p.imageUrl == null ? const Icon(Icons.image) : Image.network(p.imageUrl!, width: 56, fit: BoxFit.cover),
        title: Text(p.name ?? 'Producto ${p.id}'),
        subtitle: Text('${p.description ?? '-'}\n\$${p.price!.toStringAsFixed(2)}  |  Stock: ${p.stock}'),
        isThreeLine: true,
        trailing: Wrap(spacing: 8, children: [
          if (onAdd != null) IconButton(onPressed: onAdd, icon: const Icon(Icons.add_shopping_cart)),
          if (onEdit != null) IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          if (onDelete != null) IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
        ]),
      ),
    );
  }
}
