import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_crochet/app.dart';

void main() {
  testWidgets('PixelApp builds without errors', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixelApp()));

    expect(find.byType(PixelApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
