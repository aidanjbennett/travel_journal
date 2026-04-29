// test/widget/settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/providers/settings_view_model.dart';
import 'package:travel_journal/screens/setting_screen.dart';

class MockSettingsViewModel extends Mock implements SettingsViewModel {}

Widget _buildSubject(SettingsViewModel vm) {
  return ChangeNotifierProvider<SettingsViewModel>.value(
    value: vm,
    child: const MaterialApp(home: SettingScreen()),
  );
}

MockSettingsViewModel _fakeVm() {
  final vm = MockSettingsViewModel();
  when(() => vm.isDarkMode).thenReturn(false);
  return vm;
}

void main() {
  group('SettingScreen - clear all data', () {
    testWidgets('tapping Clear All Data shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(_fakeVm()));

      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Clear All Data'), findsWidgets);
      expect(
        find.text(
          'This will permanently delete all journal entries. This cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets(
      'tapping Cancel dismisses dialog without calling clearAllData',
      (tester) async {
        final vm = _fakeVm();

        await tester.pumpWidget(_buildSubject(vm));

        await tester.tap(find.text('Clear All Data'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        verifyNever(() => vm.clearAllData());
      },
    );

    testWidgets('tapping Clear calls clearAllData and shows snackbar', (
      tester,
    ) async {
      final vm = _fakeVm();
      when(() => vm.clearAllData()).thenAnswer((_) async => true);

      await tester.pumpWidget(_buildSubject(vm));

      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(() => vm.clearAllData()).called(1);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('All data cleared.'), findsOneWidget);
    });
  });
}
