import 'package:flutter/material.dart';
import '../models/user_register_dto.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();
  final company = TextEditingController();
  int role = 2; // 1 empresa, 2 cliente
  bool loading = false;
  String? msg;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      await ApiService.instance.register(UserRegisterDto(
        email: email.text.trim(),
        password: pass.text,
        role: role,
        name: name.text.trim().isEmpty ? null : name.text.trim(),
        companyName: role == 1 ? (company.text.trim().isEmpty ? null : company.text.trim()) : null,
      ));
      setState(() => msg = 'Cuenta creada. Ahora inicia sesión.');
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: role,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Empresa')),
              DropdownMenuItem(value: 2, child: Text('Cliente')),
            ],
            onChanged: (v) => setState(() => role = v ?? 2),
            decoration: const InputDecoration(labelText: 'Rol'),
          ),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: pass, decoration: const InputDecoration(labelText: 'Contraseña')),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre (opcional)')),
          if (role == 1)
            TextField(controller: company, decoration: const InputDecoration(labelText: 'Nombre de empresa')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: loading ? null : _submit, child: Text(loading ? '...' : 'Crear cuenta')),
          if (msg != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(msg!)),
        ],
      ),
    );
  }
}
