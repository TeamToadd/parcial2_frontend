import 'package:flutter/material.dart';

class QuantitySelectorDialog extends StatefulWidget {
  const QuantitySelectorDialog({super.key, this.initial = 1});
  final int initial;

  @override
  State<QuantitySelectorDialog> createState() => _QuantitySelectorDialogState();
}

class _QuantitySelectorDialogState extends State<QuantitySelectorDialog> {
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cantidad'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => setState(() => qty = (qty - 1).clamp(1, 9999)), icon: const Icon(Icons.remove)),
          Text('$qty', style: const TextStyle(fontSize: 18)),
          IconButton(onPressed: () => setState(() => qty += 1), icon: const Icon(Icons.add)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop<int>(context, qty), child: const Text('OK')),
      ],
    );
  }
}
