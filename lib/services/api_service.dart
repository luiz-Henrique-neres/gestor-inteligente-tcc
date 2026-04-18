import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao fazer login.');
  }

  static Future<Map<String, dynamic>> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String confirmarSenha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'senha': senha,
        'confirmar_senha': confirmarSenha,
      }),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) return data;
    throw Exception(data['detail'] ?? 'Erro ao cadastrar.');
  }

  static Future<void> recuperarSenha(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/recuperar-senha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['detail'] ?? 'Erro ao recuperar senha.');
    }
  }

  static Future<Map<String, dynamic>> getDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard?token=$token'),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao carregar dashboard.');
  }

  static Future<List<dynamic>> getAssinaturas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assinaturas?token=$token'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Erro ao carregar assinaturas.');
  }

  static Future<Map<String, dynamic>> criarAssinatura({
    required String token,
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assinaturas?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'categoria': categoria,
        'valor': valor,
        'vencimento': vencimento,
      }),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) return data;
    throw Exception(data['detail'] ?? 'Erro ao criar assinatura.');
  }

  static Future<Map<String, dynamic>> editarAssinatura({
    required String token,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assinaturas/$id?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(campos),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao editar assinatura.');
  }

  static Future<void> deletarAssinatura(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assinaturas/$id?token=$token'),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir assinatura.');
    }
  }
}
