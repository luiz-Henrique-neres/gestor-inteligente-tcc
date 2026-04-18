import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  String? _token;
  bool _carregando = false;
  String? _erro;

  Usuario? get usuario => _usuario;
  String? get token => _token;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get autenticado => _token != null;

  // ─── Login ──────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final data = await ApiService.login(email, senha);
      _token = data['token'];
      _usuario = Usuario.fromJson(data['usuario']);
      await _salvarToken(_token!);
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Cadastro ───────────────────────────────────────────────────────────────

  Future<bool> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String confirmarSenha,
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final data = await ApiService.cadastro(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
        confirmarSenha: confirmarSenha,
      );
      _token = data['token'];
      _usuario = Usuario.fromJson(data['usuario']);
      await _salvarToken(_token!);
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Recuperar Senha ────────────────────────────────────────────────────────

  Future<bool> recuperarSenha(String email) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      await ApiService.recuperarSenha(email);
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _token = null;
    _usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  // ─── Persistência ───────────────────────────────────────────────────────────

  Future<void> _salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }
}
