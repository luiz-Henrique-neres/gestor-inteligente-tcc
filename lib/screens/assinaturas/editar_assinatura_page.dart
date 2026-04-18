import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/assinatura.dart';
import '../../providers/assinaturas_provider.dart';

class EditarAssinaturaPage extends StatefulWidget {
  final Assinatura assinatura;
  final String token;
  const EditarAssinaturaPage(
      {super.key, required this.assinatura, required this.token});

  @override
  State<EditarAssinaturaPage> createState() => _EditarAssinaturaPageState();
}

class _EditarAssinaturaPageState extends State<EditarAssinaturaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _valorCtrl;
  late String _categoriaSelecionada;
  late bool _ativa;
  late DateTime _vencimento;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.assinatura.nome);
    _valorCtrl = TextEditingController(
        text: widget.assinatura.valor.toStringAsFixed(2));
    _categoriaSelecionada = categorias.contains(widget.assinatura.categoria)
        ? widget.assinatura.categoria
        : categorias.first;
    _ativa = widget.assinatura.ativa;
    final parts = widget.assinatura.vencimento.split('-');
    _vencimento = parts.length == 3
        ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
        : DateTime.now();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<AssinaturasProvider>();
    final ok = await prov.editar(
      token: widget.token,
      id: widget.assinatura.id,
      campos: {
        'nome': _nomeCtrl.text.trim(),
        'categoria': _categoriaSelecionada,
        'valor': double.parse(_valorCtrl.text.replaceAll(',', '.')),
        'vencimento':
            '${_vencimento.year}-${_vencimento.month.toString().padLeft(2, '0')}-${_vencimento.day.toString().padLeft(2, '0')}',
        'ativa': _ativa,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? 'Assinatura atualizada!' : (prov.erro ?? 'Erro ao atualizar.')),
        backgroundColor: ok ? AppTheme.sucesso : AppTheme.erro,
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssinaturasProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Assinatura')),
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
                    onPressed: _selecionarData, child: const Text('Alterar')),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Assinatura ativa',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_ativa ? 'Ativada' : 'Desativada',
                    style: const TextStyle(color: AppTheme.textoSecundario)),
                value: _ativa,
                activeThumbColor: AppTheme.primario,
                onChanged: (v) => setState(() => _ativa = v),
              ),
              const SizedBox(height: 24),
              prov.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar alterações'),
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
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _vencimento = picked);
  }
}
