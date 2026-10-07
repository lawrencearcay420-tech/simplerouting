import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:routing/pages/sample_page.dart';

class MockApiClient extends http.BaseClient {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response(
      jsonEncode([
        {'id': 1, 'title': 'First post', 'body': 'This is the body text'},
        {'id': 2, 'title': 'Second post', 'body': 'Another body text'},
      ]),
      200,
    );
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return http.Response('', 200);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.empty(), 200);
  }
}

void main() {
  testWidgets('Sample page loads posts and removes one when deleted', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: SamplePage(client: MockApiClient())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Sample Page'), findsOneWidget);
    expect(find.text('First post'), findsOneWidget);
    expect(find.text('Second post'), findsOneWidget);
    expect(find.byIcon(Icons.delete_forever), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.delete_forever).first);
    await tester.pumpAndSettle();

    expect(find.text('First post'), findsNothing);
    expect(find.byIcon(Icons.delete_forever), findsOneWidget);
  });
}
