import 'package:flutter_test/flutter_test.dart';
import 'package:sehatconnect/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SehatConnectApp());
  });
}
