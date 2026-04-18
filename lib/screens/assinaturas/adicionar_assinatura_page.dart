import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/assinaturas_provider.dart';

class AdicionarAssinaturaPage extends StatefulWidget {
  final String token;
  const AdicionarAssinaturaPage({super.key, required this.token});

  @override
  State<AdicionarAssinaturaPage> createState() =>
      _AdicionarAssinaturaPageState();
}

class _AdicionarAssinaturaPageState extends State<AdicionarAssinaturaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  String _categoriaSelecionada = categorias.first;
  DateTime _vencimento = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<AssinaturasProvider>();
    final ok = await prov.criar(
      token: widget.token,
      nome: _nomeCtrl.text.trim(),
      categoria: _categoriaSelecionada,
      valor: double.parse(_valorCtrl.text.replaceAll(',', '.')),
      vencimento:
          '${_vencimento.year}-${_vencimento.month.toString().padLeft(2, '0')}-${_vencimento.day.toString().padLeft(2, '0')}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? 'Assinatura adicionada!' : (prov.erro ?? 'Erro ao adicionar.')),
        backgroundColor: ok ? AppTheme.sucesso : AppTheme.erro,
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssinaturasProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Assinatura')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nome do serviço'),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                    hintText: 'Ex: Netflix, Spotify...',
                    prefixIcon: Icon(Icons.subscriptions_outlined)),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome.' : null,
              ),
              const SizedBox(height: 20),
              _label('Categoria'),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined)),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _categoriaSelecionada = v ?? categorias.first),
              ),
              const SizedBox(height: 20),
              _label('Valor mensal (R\$)'),
              TextFormField(
                controller: _valorCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    hintText: '0,00',
                    prefixIcon: Icon(Icons.attach_money_outlined)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor.';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _label('Data de vencimento'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined,
                    color: AppTheme.primario),
                title: Text(
                  '${_vencimento.day.toString().padLeft(2, '0')}/${_vencimento.month.toString().padLeft(2, '0')}/${_vencimento.year}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: TextButton(
                  onPressed: _selecionarData,
                  child: const Text('Alterar'),
                ),
              ),
              const Divider(),
              const SizedBox(height: 24),
              prov.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar Assinatura'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vencimento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _vencimento = picked);
  }
}
