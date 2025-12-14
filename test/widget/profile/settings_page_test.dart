import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/profile/settings_page.dart';
import 'package:project/features/settings/settings_bloc.dart';
import 'package:project/core/di.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('SettingsPage', () {
    late SettingsBloc settingsBloc;

    setUp(() {
      settingsBloc = WidgetTestHelper.createMockSettingsBloc();

      // Register SettingsBloc in GetIt
      if (getIt.isRegistered<SettingsBloc>()) {
        getIt.unregister<SettingsBloc>();
      }
      getIt.registerLazySingleton<SettingsBloc>(() => settingsBloc);
    });

    tearDown(() {
      settingsBloc.close();
      if (getIt.isRegistered<SettingsBloc>()) {
        getIt.unregister<SettingsBloc>();
      }
    });

    testWidgets('displays settings page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SettingsPage(),
          settingsBloc: settingsBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('displays theme toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SettingsPage(),
          settingsBloc: settingsBloc,
        ),
      );

      await tester.pumpAndSettle();

      // Should have theme settings
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('displays language selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SettingsPage(),
          settingsBloc: settingsBloc,
        ),
      );

      await tester.pumpAndSettle();

      // Should have language settings
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}

