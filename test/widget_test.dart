import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_lms/core/localization/app_localizations.dart';
import 'package:thaheen_lms/features/progress/domain/entities/lesson_progress.dart';
import 'package:thaheen_lms/features/progress/presentation/widgets/progress_badge.dart';

void main() {
  testWidgets('ProgressBadge displays correct label and icon for completed status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ar')],
        locale: Locale('ar'),
        home: Scaffold(
          body: ProgressBadge(status: LessonStatus.completed),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('مكتمل'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('ProgressBadge displays correct label and icon for locked status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ar')],
        locale: Locale('ar'),
        home: Scaffold(
          body: ProgressBadge(status: LessonStatus.locked),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('مُقفل'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });
}
