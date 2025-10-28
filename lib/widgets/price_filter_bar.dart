import 'package:flutter/material.dart';

class PriceFilterBar extends StatefulWidget {
  final double? initialMin;
  final double? initialMax;
  final void Function(double? min, double? max) onApply;

  const PriceFilterBar({
    super.key,
    this.initialMin,
    this.initialMax,
    required this.onApply,
  });

  @override
  State<PriceFilterBar> createState() => _PriceFilterBarState();
}

class _PriceFilterBarState extends State<PriceFilterBar> {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(
        text: widget.initialMin == null ? '' : widget.initialMin!.toString());
    _maxCtrl = TextEditingController(
        text: widget.initialMax == null ? '' : widget.initialMax!.toString());
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            controller: _minCtrl,
            decoration: const InputDecoration(labelText: 'Min \$'),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _maxCtrl,
            decoration: const InputDecoration(labelText: 'Max \$'),
            keyboardType: TextInputType.number,
          ),
        ),
        FilledButton(
          onPressed: () {
            final min = double.tryParse(_minCtrl.text.trim());
            final max = double.tryParse(_maxCtrl.text.trim());
            widget.onApply(min, max);
          },
          child: const Text('Filtrar'),
        ),
        TextButton(
          onPressed: () {
            _minCtrl.clear();
            _maxCtrl.clear();
            widget.onApply(null, null);
          },
          child: const Text('Limpiar'),
        ),
      ],
    );
  }
}
