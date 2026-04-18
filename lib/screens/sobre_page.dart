import 'package:flutter/material.dart';
import '../app_theme.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primario, AppTheme.secundario],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Meu Gestor de Assinaturas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text('Versão 1.0.0',
                style: TextStyle(color: AppTheme.textoSecundario)),
            const SizedBox(height: 32),
            _secao(
              titulo: 'Objetivo',
              conteudo:
                  'Aplicativo multiplataforma desenvolvido para auxiliar usuários no gerenciamento de suas assinaturas e serviços recorrentes, permitindo visualizar gastos, controlar vencimentos e manter o orçamento organizado.',
              icone: Icons.info_outline,
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Equipe de Desenvolvimento',
              conteudo: 'Luiz Henrique Neres Santos',
              icone: Icons.people_outline,
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Disciplina',
              conteudo: 'Engenharia de Software',
              icone: Icons.school_outlined,
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Instituição',
              conteudo:
                  'Faculdade de Tecnologia de Ribeirão Preto — FATEC\nCentro Paula Souza',
              icone: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 16),
            _secao(
              titulo: 'Tecnologias',
              conteudo: 'Flutter • Dart • FastAPI • Python\nProvider (ChangeNotifier)',
              icone: Icons.code_outlined,
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2025 Meu Gestor de Assinaturas\nTodos os direitos reservados.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppTheme.textoSecundario, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao(
      {required String titulo,
      required String conteudo,
      required IconData icone}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primario.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, color: AppTheme.primario, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(conteudo,
                      style: const TextStyle(
                          color: AppTheme.textoSecundario, fontSize: 14,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
