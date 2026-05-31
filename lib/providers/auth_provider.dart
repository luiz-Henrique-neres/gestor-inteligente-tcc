import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  Usuario? _usuario;
  bool _carregando = false;
  String? _erro;

  User? get firebaseUser => _firebaseUser;
  Usuario? get usuario => _usuario;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get autenticado => _firebaseUser != null;
  Future<String?>? get idToken => _firebaseUser?.getIdToken();

  AuthProvider() {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      _usuario = user != null ? Usuario(
        id: user.uid,
        email: user.email!,
        nome: user.displayName ?? user.email!.split('@')[0],
        telefone: '', 
      ) : null;
      notifyListeners();
    });
  }

  // ─── Login ──────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _firebaseUser = userCredential.user;
      _usuario = _firebaseUser != null ? Usuario(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email!,
        nome: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
        telefone: '',
      ) : null;
      
      final String? idToken = await _firebaseUser!.getIdToken();
      await _salvarToken(idToken); 

      // 👇 ADICIONADO AQUI: Salvando email e senha localmente para o requisito
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('salvou_email', email);
      await prefs.setString('salvou_senha', senha);
      // 👆 FIM DA ADIÇÃO

      return true;
    } on FirebaseAuthException catch (e) {
      _erro = _getFirebaseAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      _erro = 'Erro desconhecido: ${e.toString()}';
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
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _firebaseUser = userCredential.user;
      if (_firebaseUser != null) {
        await _firebaseUser!.updateDisplayName(nome);
        await _firebaseUser!.reload();
        _firebaseUser = FirebaseAuth.instance.currentUser; 
      }
      _usuario = _firebaseUser != null ? Usuario(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email!,
        nome: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
        telefone: telefone, 
      ) : null;
      final String? idToken = await _firebaseUser!.getIdToken();
      await _salvarToken(idToken);
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = _getFirebaseAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      _erro = 'Erro desconhecido: ${e.toString()}';
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
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _erro = 'Link de redefinição de senha enviado para $email.'; 
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = _getFirebaseAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      _erro = 'Erro desconhecido: ${e.toString()}';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 

    // 👇 ADICIONADO AQUI: Limpando as credenciais ao sair
    await prefs.remove('salvou_email');
    await prefs.remove('salvou_senha');
    // 👆 FIM DA ADIÇÃO

    notifyListeners();
  }

  // ─── Persistência ───────────────────────────────────────────────────────────

  Future<void> _salvarToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('token', token);
    } else {
      await prefs.remove('token');
    }
  }

  Future<void> carregarSessao() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    _usuario = _firebaseUser != null ? Usuario(
      id: _firebaseUser!.uid,
      email: _firebaseUser!.email!,
      nome: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
      telefone: '', 
    ) : null;
    notifyListeners();
  }

  // ─── Mapeamento de Erros FirebaseAuth ────────────────────────────────────────

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado para este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'O endereço de e-mail é inválido.';
      case 'operation-not-allowed':
        return 'Login com e-mail e senha não está habilitado.';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Tente novamente mais tarde.';
      default:
        return 'Um erro desconhecido ocorreu. Código: $errorCode';
    }
  }
}
