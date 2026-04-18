import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/auth_provider.dart';

class EsqueceuSenhaPage extends StatefulWidget {
  const EsqueceuSenhaPage({super.key});

  @override
  State<EsqueceuSenhaPage> createState() => _EsqueceuSenhaPageState();
}

class _EsqueceuSenhaPageState extends State<EsqueceuSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _enviado = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.recuperarSenha(_emailCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _enviado = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao recuperar senha.'),
          backgroundColor: AppTheme.erro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.superficieClara,
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _enviado ? _telaConfirmacao() : _formulario(auth),
        ),
      ),
    );
  }

  Widget _formulario(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primario.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_outlined,
                  color: AppTheme.primario, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Esqueceu sua senha?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Informe seu e-mail e enviaremos\ninstruções para redefinição.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textoSecundario),
            ),
          ),
          const SizedBox(height: 32),
          const Text('E-mail cadastrado',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'seu@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe o e-mail.';
              if (!v.contains('@')) return 'E-mail inválido.';
              return null;
            },
          ),
          const SizedBox(height: 24),
          auth.carregando
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _enviar,
                  child: const Text('Enviar link de recuperação'),
                ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primario.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primario, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'O link expira em 1 hora. Verifique também a pasta de spam.',
                    style: TextStyle(color: AppTheme.primario, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _telaConfirmacao() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            color: AppTheme.sucesso, size: 80),
        const SizedBox(height: 24),
        const Text('E-mail enviado!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Enviamos instruções de recuperação para\n${_emailCtrl.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textoSecundario),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar para o Login'),
        ),
      ],
    );
  }
}
