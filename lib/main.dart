import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/assinaturas_provider.dart';
import 'screens/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuGestorApp());
}

class MeuGestorApp extends StatelessWidget {
  const MeuGestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AssinaturasProvider()),
      ],
      child: MaterialApp(
        title: 'Meu Gestor de Assinaturas',
        theme: AppTheme.tema,
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
