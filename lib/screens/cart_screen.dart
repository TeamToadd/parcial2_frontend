import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import '../models/order_create_dto.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;

  void _onCartChanged() => setState(() {});
  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  Future<void> _checkout() async {
    if (_cart.items.isEmpty || _cart.companyUserId == null) return;
    try {
      final dto = OrderCreateDto(
        companyUserId: _cart.companyUserId!,
        items: _cart.toOrderItems(),
      );
      await ApiService.instance.createOrder(dto);
      await _cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido realizado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _cart.items.values.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: entries.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final it = entries[i];
                      final p = it.snap;
                      return ListTile(
                        leading: p.imageUrl == null
                            ? const Icon(Icons.image)
                            : Image.network(
                                p.imageUrl!,
                                width: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                        title: Text(p.name ?? 'Producto ${p.id}'),
                        subtitle:
                            Text('\$${(p.price ?? 0).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => _cart.setQuantity(
                                    p.id, it.quantity - 1),
                                icon: const Icon(Icons.remove)),
                            Text('${it.quantity}'),
                            IconButton(
                                onPressed: () => _cart.setQuantity(
                                    p.id, it.quantity + 1),
                                icon: const Icon(Icons.add)),
                            IconButton(
                                onPressed: () => _cart.remove(p.id),
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: \$${_cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                          onPressed: _checkout,
                          child: const Text('Pedir ahora')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
