import 'package:flutter/material.dart';

class QuantitySelectorDialog extends StatefulWidget {
  final int initial;
  final int? max; // opcional: límite superior (stock)
  const QuantitySelectorDialog({super.key, required this.initial, this.max});

  @override
  State<QuantitySelectorDialog> createState() => _QuantitySelectorDialogState();
}

class _QuantitySelectorDialogState extends State<QuantitySelectorDialog> {
  late int _qty;

  @override
  void initState() {
    super.initState();
    _qty = widget.initial.clamp(1, widget.max ?? 1 << 30);
  }

  void _dec() {
    setState(() => _qty = (_qty - 1).clamp(1, widget.max ?? 1 << 30));
  }

  void _inc() {
    final max = widget.max ?? (1 << 30);
    setState(() => _qty = (_qty + 1).clamp(1, max));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cantidad'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: _dec, icon: const Icon(Icons.remove)),
          Text('$_qty', style: const TextStyle(fontSize: 20)),
          IconButton(onPressed: _inc, icon: const Icon(Icons.add)),
          if (widget.max != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('/ ${widget.max}', style: const TextStyle(color: Colors.grey)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop<int>(context, _qty), child: const Text('Agregar')),
      ],
    );
  }
}
