import 'package:flutter/foundation.dart';
import '../models/assinatura.dart';
import '../services/api_service.dart';

class AssinaturasProvider extends ChangeNotifier {
  List<Assinatura> _assinaturas = [];
  Map<String, dynamic> _dashboard = {};
  bool _carregando = false;
  String? _erro;

  List<Assinatura> get assinaturas => _assinaturas;
  List<Assinatura> get ativas => _assinaturas.where((a) => a.ativa).toList();
  Map<String, dynamic> get dashboard => _dashboard;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // ─── Dashboard ──────────────────────────────────────────────────────────────

  Future<void> carregarDashboard(String token) async {
    try {
      _dashboard = await ApiService.getDashboard(token);
      notifyListeners();
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ─── Listar ─────────────────────────────────────────────────────────────────

  Future<void> carregarAssinaturas(String token) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final lista = await ApiService.getAssinaturas(token);
      _assinaturas = lista.map((j) => Assinatura.fromJson(j)).toList();
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Criar ──────────────────────────────────────────────────────────────────

  Future<bool> criar({
    required String token,
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    try {
      final data = await ApiService.criarAssinatura(
        token: token,
        nome: nome,
        categoria: categoria,
        valor: valor,
        vencimento: vencimento,
      );
      _assinaturas.add(Assinatura.fromJson(data));
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ─── Editar ─────────────────────────────────────────────────────────────────

  Future<bool> editar({
    required String token,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    try {
      final data = await ApiService.editarAssinatura(
        token: token,
        id: id,
        campos: campos,
      );
      final idx = _assinaturas.indexWhere((a) => a.id == id);
      if (idx != -1) _assinaturas[idx] = Assinatura.fromJson(data);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ─── Deletar ─────────────────────────────────────────────────────────────────

  Future<bool> deletar(String token, String id) async {
    try {
      await ApiService.deletarAssinatura(token, id);
      _assinaturas.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
