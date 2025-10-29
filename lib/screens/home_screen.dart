import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../services/cart_service.dart';
import '../models/product_dto.dart';
import '../models/user_info_dto.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'company_orders_screen.dart';
import 'login_screen.dart';
import 'product_form_screen.dart';
import '../widgets/quantity_selector_dialog.dart';
import '../models/product_create_dto.dart';
import '../widgets/stock_editor_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserInfoDto? me;
  List<ProductDto> products = [];
  bool loading = true;
  int? companyFilter;
  double? minPrice, maxPrice;
  List<Map<String, dynamic>> companies = [];

  Future<void> _load() async {
    setState(() => loading = true);
    me = await ApiService.instance.me();
    companies = await ApiService.instance.getCompanies();
    products = await ApiService.instance.getProducts(
      companyId: companyFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    CartService.instance.load(); // carrito persistente
    _load();
  }

  Future<void> _logout() async {
    await AuthStorage.instance.clear();
    await CartService.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
    if (mounted) _load(); // refresca stock
  }

  void _openCreate() async {
    final ok = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (ok == true) _load();
  }

  // devuelve el nombre público de la empresa según su companyUserId
  String _companyNameFor(int companyUserId) {
    final match = companies.firstWhere(
      (c) => c['id'] == companyUserId,
      orElse: () => <String, dynamic>{},
    );
    // backend /api/Products/companies te devuelve algo como:
    // { "id": 7, "name": "Mi Empresa SRL" }
    final name = match['name'];

    if (name == null || name.toString().trim().isEmpty) {
      return 'Empresa $companyUserId';
    }
    return name.toString();
  }
  @override
  Widget build(BuildContext context) {
    final isEmpresa = me?.role == 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcial2 - Productos'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          if (isEmpresa)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanyOrdersScreen()),
              ),
              icon: const Icon(Icons.assignment),
            ),
          if (!isEmpresa)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              ),
              icon: const Icon(Icons.receipt_long),
            ),
          IconButton(
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: isEmpresa
          ? FloatingActionButton(
              onPressed: _openCreate,
              child: const Icon(Icons.add),
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros simples
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<int?>(
                        value: companyFilter,
                        hint: const Text('Empresa'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ...companies.map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as int,
                              child: Text(
                                c['name']?.toString() ?? 'Empresa ${c['id']}',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => companyFilter = v),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Min \$',
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (v) =>
                              setState(() => minPrice = double.tryParse(v)),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Max \$',
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (v) =>
                              setState(() => maxPrice = double.tryParse(v)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Filtrar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final p = products[i];
                        return Card(
                          child: ListTile(
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
                            subtitle: Text(
                              '\$${(p.price ?? 0).toStringAsFixed(2)}  |  Stock: ${p.stock}\n'
                              'Empresa: ${_companyNameFor(p.companyUserId)}',
                            ),

                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                if (!isEmpresa)
                                  IconButton(
                                    onPressed: () async {
                                      final qty = await showDialog<int>(
                                        context: context,
                                        builder: (_) =>
                                            const QuantitySelectorDialog(
                                              initial: 1,
                                            ),
                                      );
                                      if (qty == null) return;
                                      final ok = await CartService.instance.add(
                                        p,
                                        qty: qty,
                                      );
                                      if (!mounted) return;
                                      if (!ok) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Solo puedes mezclar productos de una misma empresa',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Agregado ${p.name} x$qty al carrito',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.add_shopping_cart),
                                  ),

                                if (isEmpresa)
                                  IconButton(
                                    tooltip: 'Editar stock',
                                    onPressed: () async {
                                      final newStock = await showDialog<int>(
                                        context: context,
                                        builder: (_) => StockEditorDialog(
                                          initial: p.stock,
                                          title:
                                              'Stock de ${p.name ?? 'producto'}',
                                          current: p.stock,
                                        ),
                                      );
                                      if (newStock == null ||
                                          newStock == p.stock)
                                        return;

                                      final dto = ProductCreateDto(
                                        name: p.name ?? '',
                                        price: p.price ?? 0,
                                        stock: newStock,
                                        imageUrl: p.imageUrl,
                                        description: p.description,
                                      );
                                      await ApiService.instance.updateProduct(
                                        p.id,
                                        dto,
                                      );
                                      _load();
                                    },
                                    icon: const Icon(Icons.inventory_2),
                                  ),

                                if (isEmpresa)
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    onPressed: () async {
                                      await ApiService.instance.deleteProduct(
                                        p.id,
                                      );
                                      _load();
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
