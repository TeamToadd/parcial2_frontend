import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../models/user_login_dto.dart';
import '../models/user_register_dto.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _loading = false;
  String? _error;
  bool _hasToken = false;

  // Login
  final _emailLogin = TextEditingController();
  final _passLogin = TextEditingController();

  // Registro
  final _emailReg = TextEditingController();
  final _passReg = TextEditingController();
  final _nameReg = TextEditingController();
  final _lastNameReg = TextEditingController();
  final _userNameReg = TextEditingController();
  final _addressReg = TextEditingController();
  final _phoneReg = TextEditingController();
  final _companyReg = TextEditingController();
  int _roleReg = 2; // 1=Empresa, 2=Cliente (según tu Swagger)

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _checkToken();
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailLogin.dispose();
    _passLogin.dispose();
    _emailReg.dispose();
    _passReg.dispose();
    _nameReg.dispose();
    _lastNameReg.dispose();
    _userNameReg.dispose();
    _addressReg.dispose();
    _phoneReg.dispose();
    _companyReg.dispose();
    super.dispose();
  }

  Future<void> _checkToken() async {
    final t = await AuthStorage.instance.readToken();
    setState(() => _hasToken = t != null && t.isNotEmpty);
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.instance.login(
        UserLoginDto(email: _emailLogin.text.trim(), password: _passLogin.text),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.instance.register(
        UserRegisterDto(
          email: _emailReg.text.trim(),
          password: _passReg.text,
          role: _roleReg,
          name: _nameReg.text.trim().isEmpty ? null : _nameReg.text.trim(),
          lastName: _lastNameReg.text.trim().isEmpty ? null : _lastNameReg.text.trim(),
          userName: _userNameReg.text.trim().isEmpty ? null : _userNameReg.text.trim(),
          address: _addressReg.text.trim().isEmpty ? null : _addressReg.text.trim(),
          phone: _phoneReg.text.trim().isEmpty ? null : _phoneReg.text.trim(),
          companyName: _companyReg.text.trim().isEmpty ? null : _companyReg.text.trim(),
          profileImageUrl: null,
        ),
      );
      // auto-login
      await ApiService.instance.login(
        UserLoginDto(email: _emailReg.text.trim(), password: _passReg.text),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearToken() async {
    await AuthStorage.instance.clear();
    setState(() => _hasToken = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token limpiado')));
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Ingresar'), Tab(text: 'Crear cuenta')],
        ),
        actions: [
          if (_hasToken)
            TextButton(
              onPressed: disabled ? null : _clearToken,
              child: const Text('Limpiar token'),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      // ----------- TAB LOGIN -----------
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailLogin,
                              decoration: const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              enabled: !disabled,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passLogin,
                              decoration: const InputDecoration(labelText: 'Contraseña'),
                              obscureText: true,
                              enabled: !disabled,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: disabled ? null : _login,
                              child: _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Ingresar'),
                            ),
                          ],
                        ),
                      ),
                      // ----------- TAB REGISTRO -----------
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<int>(
                              value: _roleReg,
                              items: const [
                                DropdownMenuItem(value: 2, child: Text('Cliente')),
                                DropdownMenuItem(value: 1, child: Text('Empresa')),
                              ],
                              onChanged: disabled ? null : (v) => setState(() => _roleReg = v ?? 2),
                              decoration: const InputDecoration(labelText: 'Rol'),
                            ),
                            TextField(
                              controller: _emailReg,
                              decoration: const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              enabled: !disabled,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passReg,
                              decoration: const InputDecoration(labelText: 'Contraseña'),
                              obscureText: true,
                              enabled: !disabled,
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameReg,
                                    decoration: const InputDecoration(labelText: 'Nombre'),
                                    enabled: !disabled,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lastNameReg,
                                    decoration: const InputDecoration(labelText: 'Apellido'),
                                    enabled: !disabled,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _userNameReg,
                              decoration: const InputDecoration(labelText: 'Usuario'),
                              enabled: !disabled,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressReg,
                              decoration: const InputDecoration(labelText: 'Dirección'),
                              enabled: !disabled,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _phoneReg,
                              decoration: const InputDecoration(labelText: 'Teléfono'),
                              keyboardType: TextInputType.phone,
                              enabled: !disabled,
                            ),
                            if (_roleReg == 1) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: _companyReg,
                                decoration: const InputDecoration(labelText: 'Nombre de empresa'),
                                enabled: !disabled,
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: disabled ? null : _register,
                              child: _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Crear cuenta'),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'La contraseña será válida sin importar su contenido (política relajada).',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
