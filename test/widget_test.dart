import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_chat_application/apps/app.dart';

void main() {
  testWidgets('App loads auth', (tester) async {
    await tester.pumpWidget(const RealtimeChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Auth'), findsOneWidget);
  });
}
