import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import '../models/usuario.dart';
// import '../services/api_service.dart'; // ApiService no longer needed for auth

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser; // Renamed to _firebaseUser
  Usuario? _usuario; // This will store our custom Usuario model
  bool _carregando = false;
  String? _erro;

  User? get firebaseUser => _firebaseUser;
  Usuario? get usuario => _usuario;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get autenticado => _firebaseUser != null;
  String? get token => _firebaseUser?.uid; // Adicionado getter para o token

  AuthProvider() {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      _usuario = user != null ? Usuario(
        id: user.uid,
        email: user.email!,
        nome: user.displayName ?? user.email!.split('@')[0],
        telefone: '', // Placeholder as Firebase Auth doesn't provide it directly
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
      await _salvarToken(_firebaseUser!.uid); // Using UID as a token for persistence
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
    required String telefone, // Telefone will not be directly used by Firebase Auth
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
        _firebaseUser = FirebaseAuth.instance.currentUser; // Get updated user
      }
      _usuario = _firebaseUser != null ? Usuario(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email!,
        nome: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
        telefone: telefone, // Keep telefone for our custom Usuario model
      ) : null;
      await _salvarToken(_firebaseUser!.uid);
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
      _erro = 'Link de redefinição de senha enviado para $email.'; // Sucesso
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
    await prefs.remove('token'); // Assuming 'token' was used to store UID
    notifyListeners();
  }

  // ─── Persistência ───────────────────────────────────────────────────────────

  Future<void> _salvarToken(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', uid);
  }

  Future<void> carregarSessao() async {
    // FirebaseAuth automatically handles session persistence
    // We can just ensure _firebaseUser and _usuario are up-to-date
    _firebaseUser = FirebaseAuth.instance.currentUser;
    _usuario = _firebaseUser != null ? Usuario(
      id: _firebaseUser!.uid,
      email: _firebaseUser!.email!,
      nome: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
      telefone: '', // Default or retrieve from Firestore if stored separately
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
