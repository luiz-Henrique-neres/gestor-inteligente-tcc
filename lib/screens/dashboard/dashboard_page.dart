import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assinaturas_provider.dart';
import '../assinaturas/assinaturas_page.dart';
import '../assinaturas/adicionar_assinatura_page.dart';
import '../sobre_page.dart';
import '../auth/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _abaSelecionada = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final token = context.read<AuthProvider>().token ?? '';
    final prov = context.read<AssinaturasProvider>();
    await prov.carregarDashboard(token);
    await prov.carregarAssinaturas(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Gestor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'sobre') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SobrePage()));
              } else if (v == 'sair') {
                _confirmarSaida();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'sobre', child: Text('Sobre')),
              const PopupMenuItem(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: _abaSelecionada == 0 ? _bodyDashboard() : const AssinaturasPage(),
      floatingActionButton: _abaSelecionada == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primario,
              foregroundColor: Colors.white,
              onPressed: () async {
                final token = context.read<AuthProvider>().token ?? '';
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdicionarAssinaturaPage(token: token)),
                );
                _carregar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaSelecionada,
        onDestinationSelected: (i) => setState(() => _abaSelecionada = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Assinaturas'),
        ],
      ),
    );
  }

  Widget _bodyDashboard() {
    final prov = context.watch<AssinaturasProvider>();
    final auth = context.watch<AuthProvider>();
    final dash = prov.dashboard;

    if (prov.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Saudação
          Text(
            'Olá, ${auth.usuario?.nome.split(' ').first ?? 'usuário'}! 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Veja o resumo das suas assinaturas.',
              style: TextStyle(color: AppTheme.textoSecundario)),
          const SizedBox(height: 24),

          // Cards de métricas
          Row(
            children: [
              Expanded(
                child: _cardMetrica(
                  'Gasto Mensal',
                  'R\$ ${(dash['gasto_mensal'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.calendar_month_outlined,
                  AppTheme.primario,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cardMetrica(
                  'Gasto Anual',
                  'R\$ ${(dash['gasto_anual'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.calendar_today_outlined,
                  AppTheme.secundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _cardMetrica(
            'Assinaturas Ativas',
            '${dash['total_ativas'] ?? 0}',
            Icons.check_circle_outline,
            AppTheme.sucesso,
            larga: true,
          ),
          const SizedBox(height: 28),

          // Próximos vencimentos
          const Text('Próximos Vencimentos',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if ((dash['proximos_vencimentos'] as List? ?? []).isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhuma assinatura ativa.',
                    style: TextStyle(color: AppTheme.textoSecundario)),
              ),
            )
          else
            ...(dash['proximos_vencimentos'] as List).map(
              (a) => _cardVencimento(a),
            ),
        ],
      ),
    );
  }

  Widget _cardMetrica(
      String titulo, String valor, IconData icon, Color cor,
      {bool larga = false}) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cor, cor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  Text(valor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardVencimento(Map<String, dynamic> a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primario.withOpacity(0.15),
          child: Text(
            (a['nome'] as String).substring(0, 1).toUpperCase(),
            style: const TextStyle(
                color: AppTheme.primario, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(a['nome'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Vence: ${a['vencimento'] ?? ''}',
            style: const TextStyle(color: AppTheme.textoSecundario)),
        trailing: Text(
          'R\$ ${(a['valor'] as num).toStringAsFixed(2)}',
          style: const TextStyle(
              color: AppTheme.primario,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ),
    );
  }

  void _confirmarSaida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja mesmo sair da conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.erro),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
