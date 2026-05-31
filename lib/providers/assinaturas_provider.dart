import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assinatura.dart';

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

  Future<void> carregarDashboard(String userId, String token) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assinaturas')
          .where('usuario_id', isEqualTo: userId)
          .get();

      final todasAssinaturas = snapshot.docs.map((doc) {
        final data = doc.data();
        return Assinatura(
          id: doc.id,
          nome: data['nome'] ?? '',
          categoria: data['categoria'] ?? '',
          valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
          vencimento: data['vencimento'] ?? '',
          ativa: data['ativa'] ?? true,
        );
      }).toList();

      final ativasList = todasAssinaturas.where((a) => a.ativa).toList();
      final gastoMensal = ativasList.fold<double>(0.0, (acumulado, a) => acumulado + a.valor);

      final proximas = List<Assinatura>.from(ativasList);
      proximas.sort((a, b) {
        final diaA = int.tryParse(a.vencimento) ?? 999;
        final diaB = int.tryParse(b.vencimento) ?? 999;
        if (diaA != 999 && diaB != 999) {
          return diaA.compareTo(diaB);
        }
        return a.vencimento.compareTo(b.vencimento);
      });

      final proximosVencimentos = proximas.take(3).map((a) => {
        'id': a.id,
        'nome': a.nome,
        'categoria': a.categoria,
        'valor': a.valor,
        'vencimento': a.vencimento,
        'ativa': a.ativa,
      }).toList();

      _dashboard = {
        "gasto_mensal": gastoMensal,
        "gasto_anual": gastoMensal * 12,
        "total_ativas": ativasList.length,
        "proximos_vencimentos": proximosVencimentos,
      };
      _assinaturas = todasAssinaturas;
      _assinaturasController.add(_assinaturas);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Listar ─────────────────────────────────────────────────────────────────

  Future<void> carregarAssinaturas(String userId, String token) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assinaturas')
          .where('usuario_id', isEqualTo: userId)
          .get();

      _assinaturas = snapshot.docs.map((doc) {
        final data = doc.data();
        return Assinatura(
          id: doc.id,
          nome: data['nome'] ?? '',
          categoria: data['categoria'] ?? '',
          valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
          vencimento: data['vencimento'] ?? '',
          ativa: data['ativa'] ?? true,
        );
      }).toList();
      _assinaturasController.add(_assinaturas);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Criar ──────────────────────────────────────────────────────────────────

  Future<bool> criar({
    required String token,
    required String userId,
    required String nome,
    required String categoria,
    required double valor,
    required String vencimento,
  }) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('assinaturas').add({
        'nome': nome,
        'categoria': categoria,
        'valor': valor,
        'vencimento': vencimento,
        'ativa': true,
        'usuario_id': userId,
      });

      final novaAssinatura = Assinatura(
        id: docRef.id,
        nome: nome,
        categoria: categoria,
        valor: valor,
        vencimento: vencimento,
        ativa: true,
      );

      _assinaturas.add(novaAssinatura);
      _assinaturasController.add(_assinaturas);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Editar ─────────────────────────────────────────────────────────────────

  Future<bool> editar({
    required String userId,
    required String token,
    required String id,
    required Map<String, dynamic> campos,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('assinaturas')
          .doc(id)
          .update(campos);

      final idx = _assinaturas.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final antiga = _assinaturas[idx];
        _assinaturas[idx] = Assinatura(
          id: id,
          nome: campos['nome'] ?? antiga.nome,
          categoria: campos['categoria'] ?? antiga.categoria,
          valor: campos['valor'] != null ? (campos['valor'] as num).toDouble() : antiga.valor,
          vencimento: campos['vencimento'] ?? antiga.vencimento,
          ativa: campos['ativa'] ?? antiga.ativa,
        );
        _assinaturasController.add(_assinaturas);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Deletar ─────────────────────────────────────────────────────────────────

  Future<bool> deletar(String userId, String token, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('assinaturas')
          .doc(id)
          .delete();

      _assinaturas.removeWhere((a) => a.id == id);
      _assinaturasController.add(_assinaturas);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString();
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
