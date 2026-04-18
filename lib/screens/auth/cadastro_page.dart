import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final bool _senhaVisivel = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.cadastro(
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim(),
      senha: _senhaCtrl.text,
      confirmarSenha: _confirmarCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Bem-vindo(a)!'),
          backgroundColor: AppTheme.sucesso,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao cadastrar.'),
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preencha seus dados para começar.',
                    style:
                        TextStyle(color: AppTheme.textoSecundario, fontSize: 14)),
                const SizedBox(height: 24),
                _campo('Nome completo', _nomeCtrl, Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o nome.' : null),
                _campo('E-mail', _emailCtrl, Icons.email_outlined,
                    tipo: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o e-mail.';
                      if (!v.contains('@')) return 'E-mail inválido.';
                      return null;
                    }),
                _campo('Telefone', _telefoneCtrl, Icons.phone_outlined,
                    tipo: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o telefone.' : null),
                _campoSenha('Senha', _senhaCtrl, validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha.';
                  if (v.length < 6) return 'Mínimo 6 caracteres.';
                  return null;
                }),
                _campoSenha('Confirmar senha', _confirmarCtrl, validator: (v) {
                  if (v != _senhaCtrl.text) return 'Senhas não coincidem.';
                  return null;
                }),
                const SizedBox(height: 24),
                auth.carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _cadastrar,
                        child: const Text('Criar conta'),
                      ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Já tenho conta',
                        style: TextStyle(color: AppTheme.primario)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, IconData icon,
      {TextInputType tipo = TextInputType.text,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: tipo,
          decoration: InputDecoration(prefixIcon: Icon(icon)),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _campoSenha(String label, TextEditingController ctrl,
      {String? Function(String?)? validator}) {
    return StatefulBuilder(builder: (context, setState) {
      bool visivel = false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            obscureText: !visivel,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(visivel
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => visivel = !visivel),
              ),
            ),
            validator: validator,
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}
