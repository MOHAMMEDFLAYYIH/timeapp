// Basic Flutter widget test for Task Manager App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskManagerApp());

    // Verify Tasks text exists (in AppBar and/or NavigationBar)
    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
  });
}
