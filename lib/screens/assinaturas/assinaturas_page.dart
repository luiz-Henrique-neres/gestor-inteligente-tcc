import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/assinatura.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assinaturas_provider.dart';
import 'editar_assinatura_page.dart';

class AssinaturasPage extends StatelessWidget {
  const AssinaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssinaturasProvider>();
    final token = context.read<AuthProvider>().token ?? '';

    if (prov.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.assinaturas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textoSecundario),
            SizedBox(height: 16),
            Text('Nenhuma assinatura encontrada.',
                style: TextStyle(color: AppTheme.textoSecundario)),
            SizedBox(height: 8),
            Text('Toque em "Adicionar" para começar.',
                style: TextStyle(color: AppTheme.textoSecundario, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prov.assinaturas.length,
      itemBuilder: (context, i) {
        final a = prov.assinaturas[i];
        return _CardAssinatura(assinatura: a, token: token);
      },
    );
  }
}

class _CardAssinatura extends StatelessWidget {
  final Assinatura assinatura;
  final String token;

  const _CardAssinatura({required this.assinatura, required this.token});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primario.withOpacity(0.15),
                  radius: 24,
                  child: Text(
                    assinatura.nome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assinatura.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(assinatura.categoria,
                          style: const TextStyle(
                              color: AppTheme.textoSecundario, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: assinatura.ativa
                        ? AppTheme.sucesso.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assinatura.ativa ? 'Ativa' : 'Inativa',
                    style: TextStyle(
                        color: assinatura.ativa
                            ? AppTheme.sucesso
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info('Valor mensal',
                    'R\$ ${assinatura.valor.toStringAsFixed(2)}'),
                _info('Vencimento', assinatura.vencimento),
                _info('Custo anual',
                    'R\$ ${(assinatura.valor * 12).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditarAssinaturaPage(
                            assinatura: assinatura, token: token),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primario,
                      side: const BorderSide(color: AppTheme.primario),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmarCancelamento(context),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.erro,
                      side: const BorderSide(color: AppTheme.erro),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textoSecundario, fontSize: 11)),
        Text(valor,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  void _confirmarCancelamento(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar assinatura'),
        content: Text(
            'Deseja remover a assinatura "${assinatura.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.erro),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context
                  .read<AssinaturasProvider>()
                  .deletar(token, assinatura.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? '${assinatura.nome} removida com sucesso.'
                      : 'Erro ao remover assinatura.'),
                  backgroundColor: ok ? AppTheme.sucesso : AppTheme.erro,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
