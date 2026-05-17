import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Estes métodos não são mais usados, pois a autenticação é tratada pelo Firebase Auth
  // static Future<Map<String, dynamic>> login(String email, String senha) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/auth/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'senha': senha}),
  //   );
  //   final data = jsonDecode(utf8.decode(response.bodyBytes));
  //   if (response.statusCode == 200) return data;
  //   throw Exception(data['detail'] ?? 'Erro ao fazer login.');
  // }

  // static Future<Map<String, dynamic>> cadastro({
  //   required String nome,
  //   required String email,
  //   required String telefone,
  //   required String senha,
  //   required String confirmarSenha,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/auth/cadastro'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'nome': nome,
  //       'email': email,
  //       'telefone': telefone,
  //       'senha': senha,
  //       'confirmar_senha': confirmarSenha,
  //     }),
  //   );
  //   final data = jsonDecode(utf8.decode(response.bodyBytes));
  //   if (response.statusCode == 201) return data;
  //   throw Exception(data['detail'] ?? 'Erro ao cadastrar.');
  // }

  // static Future<void> recuperarSenha(String email) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/auth/recuperar-senha'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email}),
  //   );
  //   if (response.statusCode != 200) {
  //     final data = jsonDecode(utf8.decode(response.bodyBytes));
  //     throw Exception(data['detail'] ?? 'Erro ao recuperar senha.');
  //   }
  // }


  static Future<Map<String, dynamic>> getDashboard(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard?userId=$userId'),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao carregar dashboard.');
  }

  static Future<List<dynamic>> getAssinaturas(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assinaturas?userId=$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Erro ao carregar assinaturas.');
  }

  static Future<Map<String, dynamic>> criarAssinatura({
    required String userId,
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assinaturas?userId=$userId'),
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
    required String userId,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assinaturas/$id?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(campos),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao editar assinatura.');
  }

  static Future<void> deletarAssinatura(String userId, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assinaturas/$id?userId=$userId'),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir assinatura.');
    }
  }
}
