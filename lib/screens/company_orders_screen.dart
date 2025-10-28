import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order_dto.dart';
import '../models/order_status_update_dto.dart';

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen> {
  List<OrderDto> orders = [];
  bool loading = true;

  Future<void> _load() async {
    setState(() => loading = true);
    orders = await ApiService.instance.companyOrders();
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _changeStatus(OrderDto o, int status) async {
    await ApiService.instance.updateOrderStatus(o.id, OrderStatusUpdateDto(status));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de mi empresa')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(
                  child: ListTile(
                    title: Text('Pedido #${o.id} - \$${o.total.toStringAsFixed(2)}'),
                    subtitle: Text('Estado: ${o.status}  |  ${o.createdAt}'),
                    trailing: PopupMenuButton<int>(
                      onSelected: (s) => _changeStatus(o, s),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 0, child: Text('Nuevo')),
                        PopupMenuItem(value: 1, child: Text('Enviado')),
                        PopupMenuItem(value: 2, child: Text('Entregado')),
                        PopupMenuItem(value: 3, child: Text('Cancelado')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
