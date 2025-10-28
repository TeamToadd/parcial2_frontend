import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_login_dto.dart';
import '../models/user_register_dto.dart';
import '../models/user_info_dto.dart';
import '../models/product_dto.dart';
import '../models/product_create_dto.dart';
import '../models/order_dto.dart';
import '../models/order_create_dto.dart';
import '../models/order_status_update_dto.dart';
import '../models/review_create_dto.dart';
import 'auth_storage.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();

  // Apunta a tu backend (termina en /api)
  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://app-251027203953.azurewebsites.net/api',
  );

  Future<Map<String, String>> _headers() async {
    final t = await AuthStorage.instance.readToken();
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  // ---------- Auth ----------
  Future<void> register(UserRegisterDto dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode >= 400) {
      throw Exception('Registro falló: ${res.body}');
    }
  }

  Future<void> login(UserLoginDto dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Login inválido');
    }
    final map = jsonDecode(res.body);
    final token = (map['token'] ?? map['Token'] ?? '').toString();
    if (token.isEmpty) throw Exception('Token no recibido');
    await AuthStorage.instance.saveToken(token);
  }

  Future<UserInfoDto> me() async {
    final res = await http.get(
      Uri.parse('$baseUrl/Users/me'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('No se pudo obtener /me');
    return UserInfoDto.fromJson(jsonDecode(res.body));
  }

  // ---------- Products ----------
  Future<List<ProductDto>> getProducts({
    int? companyId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final q = <String, String>{};
    if (companyId != null) q['companyId'] = '$companyId';
    if (minPrice != null) q['minPrice'] = '$minPrice';
    if (maxPrice != null) q['maxPrice'] = '$maxPrice';

    final uri = Uri.parse('$baseUrl/Products')
        .replace(queryParameters: q.isEmpty ? null : q);

    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('Error obteniendo productos: ${res.body}');
    }
    final List list = jsonDecode(res.body);
    return list.map((e) => ProductDto.fromJson(e)).toList();
  }

  Future<ProductDto> createProduct(ProductCreateDto dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Products'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error creando producto: ${res.body}');
    }
    return ProductDto.fromJson(jsonDecode(res.body));
  }

  Future<void> updateProduct(int id, ProductCreateDto dto) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Products/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Error actualizando producto: ${res.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/Products/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Error eliminando producto: ${res.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    final res = await http.get(
      Uri.parse('$baseUrl/Products/companies'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Error obteniendo empresas: ${res.body}');
    }
    final List list = jsonDecode(res.body);
    return list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ---------- Orders ----------
  Future<OrderDto> createOrder(OrderCreateDto dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Orders'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    // backend puede devolver 201 Created
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error creando pedido: ${res.body}');
    }
    return OrderDto.fromJson(jsonDecode(res.body));
  }

  Future<List<OrderDto>> myOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/Orders/mine'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Error listando mis pedidos: ${res.body}');
    }
    final List list = jsonDecode(res.body);
    return list.map((e) => OrderDto.fromJson(e)).toList();
  }

  Future<List<OrderDto>> companyOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/Orders/company'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Error listando pedidos de la empresa: ${res.body}');
    }
    final List list = jsonDecode(res.body);
    return list.map((e) => OrderDto.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(int id, OrderStatusUpdateDto dto) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/Orders/$id/status'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error cambiando estado: ${res.body}');
    }
  }

  // ---------- Reviews ----------
  Future<void> createReview(ReviewCreateDto dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Reviews'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Error creando reseña: ${res.body}');
    }
  }

  Future<List<dynamic>> productReviews(int productId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/Reviews/product/$productId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Error obteniendo reseñas: ${res.body}');
    }
    return jsonDecode(res.body) as List;
  }
}

