import 'package:flutter/material.dart';
import '../models/product_create_dto.dart';
import '../models/product_dto.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.edit});
  final ProductDto? edit;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final name = TextEditingController();
  final desc = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final image = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      name.text = e.name ?? '';
      desc.text = e.description ?? '';
      price.text = (e.price ?? 0).toString();
      stock.text = e.stock.toString();
      image.text = e.imageUrl ?? '';
    }
  }

  Future<void> _save() async {
    final dto = ProductCreateDto(
      name: name.text.trim(),
      description: desc.text.trim().isEmpty ? null : desc.text.trim(),
      price: double.tryParse(price.text.trim()),
      stock: int.tryParse(stock.text.trim()),
      imageUrl: image.text.trim().isEmpty ? null : image.text.trim(),
    );

    if (widget.edit == null) {
      await ApiService.instance.createProduct(dto);
    } else {
      await ApiService.instance.updateProduct(widget.edit!.id, dto);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    name.dispose();
    desc.dispose();
    price.dispose();
    stock.dispose();
    image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.edit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar producto' : 'Nuevo producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nombre'), controller: name),
            TextField(decoration: const InputDecoration(labelText: 'Descripción'), controller: desc),
            TextField(decoration: const InputDecoration(labelText: 'Precio'), controller: price, keyboardType: TextInputType.number),
            TextField(decoration: const InputDecoration(labelText: 'Stock'), controller: stock, keyboardType: TextInputType.number),
            TextField(decoration: const InputDecoration(labelText: 'Imagen URL'), controller: image),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Guardar' : 'Crear')),
          ],
        ),
      ),
    );
  }
}
