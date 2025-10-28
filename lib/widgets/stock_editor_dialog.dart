import 'package:flutter/material.dart';

class StockEditorDialog extends StatefulWidget {
  const StockEditorDialog({super.key, required this.current, required int initial, required String title});
  final int current;

  @override
  State<StockEditorDialog> createState() => _StockEditorDialogState();
}

class _StockEditorDialogState extends State<StockEditorDialog> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.current.toString());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar stock'),
      content: TextField(
        controller: _c,
        decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final v = int.tryParse(_c.text) ?? widget.current;
            Navigator.pop(context, v < 0 ? 0 : v);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
