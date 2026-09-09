import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_chat_application/apps/app.dart';

void main() {
  testWidgets('Home screen renders welcome message', (tester) async {
    await tester.pumpWidget(const RealtimeChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Realtime Chat'), findsOneWidget);
    expect(find.text('Open Chat'), findsOneWidget);
  });
}
