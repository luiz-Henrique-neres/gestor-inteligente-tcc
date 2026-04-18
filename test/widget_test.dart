import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_assinaturas/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuGestorApp());
    expect(find.text('Meu Gestor'), findsOneWidget);
  });
}
