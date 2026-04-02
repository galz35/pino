import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pino_mobile/app/app.dart';

void main() {
  testWidgets('renders pino app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PinoApp()));

    await tester.pump();

    expect(find.text('Pino Mobile'), findsOneWidget);
  });
}
