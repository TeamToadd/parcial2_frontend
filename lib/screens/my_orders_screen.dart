import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order_dto.dart';
import '../models/review_create_dto.dart';
import '../widgets/review_dialog.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderDto> orders = [];
  bool loading = true;

  Future<void> _load() async {
    setState(() => loading = true);
    orders = await ApiService.instance.myOrders();
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _review(int productId, String productName) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ReviewDialog(productName: productName),
    );
    if (data == null) return;

    try {
      await ApiService.instance.createReview(
        ReviewCreateDto(
          productId: productId,
          rating: data['rating'] as int,
          comment: (data['comment'] as String).isEmpty ? null : data['comment'] as String,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu reseña!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando reseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(
                  child: ExpansionTile(
                    title: Text('Pedido #${o.id} - \$${o.total.toStringAsFixed(2)}'),
                    subtitle: Text('Estado: ${o.status}  |  ${o.createdAt}'),
                    children: [
                      if (o.items != null)
                        ...o.items!.map((it) => ListTile(
                              title: Text(it.productName ?? 'Producto ${it.productId}'),
                              subtitle: Text('Cantidad: ${it.quantity}  |  \$${it.unitPrice.toStringAsFixed(2)}'),
                              trailing: TextButton.icon(
                                onPressed: () => _review(it.productId, it.productName ?? 'Producto'),
                                icon: const Icon(Icons.reviews),
                                label: const Text('Calificar'),
                              ),
                            )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
