import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/assinatura.dart';
import '../services/api_service.dart';

class AssinaturasProvider extends ChangeNotifier {
  List<Assinatura> _assinaturas = [];
  Map<String, dynamic> _dashboard = {};
  bool _carregando = false;
  String? _erro;

  final _assinaturasController = StreamController<List<Assinatura>>.broadcast();
  Stream<List<Assinatura>> get assinaturasStream => _assinaturasController.stream;

  List<Assinatura> get assinaturas => _assinaturas;
  List<Assinatura> get ativas => _assinaturas.where((a) => a.ativa).toList();
  Map<String, dynamic> get dashboard => _dashboard;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // ─── Dashboard ──────────────────────────────────────────────────────────────

  Future<void> carregarDashboard(String userId) async {
    try {
      _dashboard = await ApiService.getDashboard(userId);
      notifyListeners();
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ─── Listar ─────────────────────────────────────────────────────────────────

  Future<void> carregarAssinaturas(String userId) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final lista = await ApiService.getAssinaturas(userId);
      _assinaturas = lista.map((j) => Assinatura.fromJson(j)).toList();
      _assinaturasController.add(_assinaturas);
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Criar ──────────────────────────────────────────────────────────────────

  Future<bool> criar({
    required String userId,
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    try {
      final data = await ApiService.criarAssinatura(
        userId: userId,
        nome: nome,
        categoria: categoria,
        valor: valor,
        vencimento: vencimento,
      );
      _assinaturas.add(Assinatura.fromJson(data));
      _assinaturasController.add(_assinaturas);
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
    required String userId,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    try {
      final data = await ApiService.editarAssinatura(
        userId: userId,
        id: id,
        campos: campos,
      );
      final idx = _assinaturas.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _assinaturas[idx] = Assinatura.fromJson(data);
        _assinaturasController.add(_assinaturas);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ─── Deletar ─────────────────────────────────────────────────────────────────

  Future<bool> deletar(String userId, String id) async {
    try {
      await ApiService.deletarAssinatura(userId, id);
      _assinaturas.removeWhere((a) => a.id == id);
      _assinaturasController.add(_assinaturas);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _assinaturasController.close();
    super.dispose();
  }
}
