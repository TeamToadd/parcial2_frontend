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

  // 👇 IMPORTANTE
  // Necesitamos saber quién soy yo para detectar si "ya reseñé".
  // Opción 1 (simple): lo pedimos acá con /Users/me cuando cargamos.
  int? myUserId;

  Future<void> _load() async {
    setState(() => loading = true);

    // quién soy
    final me = await ApiService.instance.me();
    myUserId = me.id;

    // mis pedidos
    orders = await ApiService.instance.myOrders();

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------- Helpers para reseñas ----------

  Future<List<dynamic>> _fetchReviewsForProduct(int productId) async {
    // GET /Reviews/product/{productId}
    return await ApiService.instance.productReviews(productId);
  }

  /// true si ESTE usuario (myUserId) ya reseñó ese producto
  bool _alreadyReviewedByMe(List<dynamic> reviews) {
    if (myUserId == null) return false;
    for (final r in reviews) {
      final uid = r['userId'];
      if (uid == myUserId) return true;
    }
    return false;
  }

  /// UI que muestra las reseñas debajo del item del pedido
  Widget _reviewsSection(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      return const Text(
        'Sin reseñas todavía',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews.map((r) {
        final rating = r['rating'];
        final comment = (r['comment'] ?? '').toString();
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '★$rating  $comment',
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  /// Abre el diálogo para mandar una reseña nueva
  Future<void> _sendReview(int productId, String productName) async {
    // ReviewDialog te devuelve un map con rating/comment
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ReviewDialog(productName: productName),
    );
    if (data == null) return; // canceló

    try {
      await ApiService.instance.createReview(
        ReviewCreateDto(
          productId: productId,
          rating: data['rating'] as int,
          comment: (data['comment'] as String).trim().isEmpty
              ? null
              : data['comment'] as String,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu reseña!')),
      );

      setState(() {
        // refrescamos UI para que desaparezca el botón "Calificar"
        // porque ahora ya tiene reseña
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando reseña: $e')),
      );
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final uid = myUserId; // solo para leer más corto

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
                    title: Text(
                      'Pedido #${o.id} - \$${o.total.toStringAsFixed(2)}',
                    ),
                    subtitle: Text(
                      'Estado: ${o.status}  |  ${o.createdAt}',
                    ),
                    children: [
                      if (o.items != null)
                        ...o.items!.map((it) {
                          // para cada ítem del pedido mostramos:
                          //  - nombre, cantidad, precio
                          //  - reseñas existentes (FutureBuilder)
                          //  - botón "Calificar" si:
                          //      * pedido ENTREGADO (status == 2)
                          //      * este usuario NO reseñó aún
                          //
                          // Status mapping (acordate):
                          // 0 = Nuevo
                          // 1 = Enviado
                          // 2 = Entregado  ✅ <-- sólo acá se permite reseñar
                          // 3 = Cancelado

                          return FutureBuilder<List<dynamic>>(
                            future: _fetchReviewsForProduct(it.productId),
                            builder: (context, snap) {
                              final reviews = snap.data ?? [];
                              final bool canReview = (o.status == 2) &&
                                  (uid != null) &&
                                  !_alreadyReviewedByMe(reviews);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Datos del producto comprado
                                    Text(
                                      it.productName ??
                                          'Producto ${it.productId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Cantidad: ${it.quantity} | \$${it.unitPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),

                                    // Reseñas existentes
                                    if (snap.connectionState ==
                                        ConnectionState.waiting)
                                      const Text(
                                        'Cargando reseñas...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else
                                      _reviewsSection(reviews),

                                    // Botón "Calificar" sólo si aplica
                                    if (canReview)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton.icon(
                                          icon: const Icon(Icons.rate_review),
                                          label: const Text('Calificar'),
                                          onPressed: () async {
                                            await _sendReview(
                                              it.productId,
                                              it.productName ??
                                                  'Producto ${it.productId}',
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
