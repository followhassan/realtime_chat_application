import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_chat_application/apps/app.dart';

void main() {
  testWidgets('App loads login screen', (tester) async {
    await tester.pumpWidget(const RealtimeChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Join room'), findsOneWidget);
    expect(find.text('Join Room'), findsOneWidget);
  });
}
