import 'package:flutter/material.dart';

class CompanyFilterBar extends StatelessWidget {
  final List<Map<String, dynamic>> companies; // [{id, name}, ...]
  final int? selectedCompanyId;
  final ValueChanged<int?> onChanged;
  final VoidCallback onApply;

  const CompanyFilterBar({
    super.key,
    required this.companies,
    required this.selectedCompanyId,
    required this.onChanged,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Empresa:'),
        DropdownButton<int?>(
          value: selectedCompanyId,
          hint: const Text('Todas'),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
            ...companies.map(
              (c) => DropdownMenuItem<int?>(
                value: c['id'] as int,
                child: Text((c['name'] ?? 'Empresa ${c['id']}').toString()),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
        FilledButton.icon(
          onPressed: onApply,
          icon: const Icon(Icons.filter_list),
          label: const Text('Aplicar'),
        ),
      ],
    );
  }
}
