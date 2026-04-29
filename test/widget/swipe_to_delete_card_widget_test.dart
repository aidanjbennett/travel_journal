import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
import 'package:travel_journal/widgets/entries/swipe_to_delete_card_widget.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class FakeJournalEntry implements JournalEntryModel {
  @override
  final String entryId;
  @override
  final String title;
  @override
  final String body;
  @override
  final String locationName;
  @override
  final List<String> imagePaths;
  @override
  final List<String> audioPaths;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  FakeJournalEntry({
    this.entryId = 'test-id-1',
    this.title = 'Test Entry',
    this.body = 'Some body text',
    this.locationName = 'London, UK',
    this.imagePaths = const [],
    this.audioPaths = const [],
    this.latitude = 51.5,
    this.longitude = -0.1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime(2024, 1, 1),
       updatedAt = updatedAt ?? DateTime(2024, 1, 1);
}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

Widget _buildSubject(
  JournalEntryModel entry, {
  AppDatabase? db,
  List<NavigatorObserver> observers = const [],
}) {
  final mockDb = db ?? MockAppDatabase();
  return Provider<AppDatabase>.value(
    value: mockDb,
    child: MaterialApp(
      navigatorObservers: observers,
      home: Scaffold(body: SwipeToDeleteCardWidget(entry: entry)),
    ),
  );
}

void main() {
  group('SwipeToDeleteCardWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildSubject(FakeJournalEntry()));
      expect(find.byType(SwipeToDeleteCardWidget), findsOneWidget);
    });

    testWidgets('delete icon has zero opacity before any drag', (tester) async {
      await tester.pumpWidget(_buildSubject(FakeJournalEntry()));

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0.0);
    });

    testWidgets('delete icon becomes visible when dragging left', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(FakeJournalEntry()));

      await tester.drag(
        find.byType(SwipeToDeleteCardWidget),
        const Offset(-80, 0),
      );
      await tester.pump();

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, greaterThan(0.0));
    });

    testWidgets('delete icon becomes visible when dragging right', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(FakeJournalEntry()));

      await tester.drag(
        find.byType(SwipeToDeleteCardWidget),
        const Offset(80, 0),
      );
      await tester.pump();

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, greaterThan(0.0));
    });

    testWidgets('snaps back when drag is below threshold', (tester) async {
      await tester.pumpWidget(_buildSubject(FakeJournalEntry()));

      await tester.drag(
        find.byType(SwipeToDeleteCardWidget),
        const Offset(-80, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SwipeToDeleteCardWidget), findsOneWidget);
    });

    testWidgets('tapping card pushes a new route', (tester) async {
      final observer = _MockNavigatorObserver();
      registerFallbackValue(
        MaterialPageRoute<void>(builder: (_) => const SizedBox()),
      );

      final mockDb = MockAppDatabase();
      when(
        () => mockDb.watchEntry(any()),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        _buildSubject(FakeJournalEntry(), db: mockDb, observers: [observer]),
      );

      await tester.tap(find.byType(SwipeToDeleteCardWidget));
      await tester.pump();

      verify(
        () => observer.didPush(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
