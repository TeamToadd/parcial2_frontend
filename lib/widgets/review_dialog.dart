import 'package:flutter/material.dart';

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key, required this.productName});

  final String productName;

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Calificar ${widget.productName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Puntaje (1 a 5)'),
          ),
          DropdownButton<int>(
            value: _rating,
            items: [1, 2, 3, 4, 5]
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text('$r ★'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _rating = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop<Map<String, dynamic>>(context, {
              'rating': _rating,
              'comment': _commentController.text.trim(),
            });
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
