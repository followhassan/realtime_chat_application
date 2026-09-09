import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_chat_application/core/utils/identity.dart';

void main() {
  test('same email maps to same identity key and avatar colour', () {
    const a = 'Alex@Example.com';
    const b = 'alex@example.com';
    expect(EmailUtils.docId(a), EmailUtils.docId(b));
    expect(avatarColorFromEmail(a), avatarColorFromEmail(b));
  });

  test('email validation', () {
    expect(EmailUtils.isValid('a@b.com'), isTrue);
    expect(EmailUtils.isValid('bad'), isFalse);
  });
}
