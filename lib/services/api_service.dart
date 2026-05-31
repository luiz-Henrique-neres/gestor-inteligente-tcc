import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ATENÇÃO: Se rodar no emulador Android, mude para 'http://10.0.2.2:8000'
  // Se rodar no dispositivo físico, coloque o IP do seu notebook (ex: 'http://192.168.15.25:8000')
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao carregar dashboard.');
  }

  // ─── Listar Assinaturas ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getAssinaturas(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assinaturas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Erro ao carregar assinaturas.');
  }

  // ─── Criar Assinatura ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> criarAssinatura({
    required String token,
    required String userId, 
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assinaturas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  // ─── Editar Assinatura ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> editarAssinatura({
    required String userId,
    required String token,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assinaturas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(campos),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Erro ao editar assinatura.');
  }

  // ─── Deletar Assinatura ─────────────────────────────────────────────────────
  static Future<void> deletarAssinatura(String userId, String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assinaturas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir assinatura.');
    }
  }
}