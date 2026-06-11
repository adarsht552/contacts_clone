import 'package:flutter_test/flutter_test.dart';
import 'package:contacts_app/main.dart';

void main() {
  testWidgets('Contacts app shows bottom navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ContactsApp());
    await tester.pumpAndSettle();

    expect(find.text('Contacts'), findsWidgets);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
