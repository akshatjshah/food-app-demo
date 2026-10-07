import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parabdi/core/widgets/app_refresh.dart';

void main() {
  group('AppPullToRefresh', () {
    testWidgets('pull triggers the real backend reload callback',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPullToRefresh(
              onRefresh: () async {
                calls++;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 30,
                itemBuilder: (_, i) => ListTile(title: Text('Row $i')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Row 0'), findsOneWidget);
      await tester.fling(
          find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(calls, 1);
    });
  });

  group('AppRefreshIconButton', () {
    testWidgets('tap runs refresh and stays silent on success',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                AppRefreshIconButton(
                  onRefresh: () async {
                    calls++;
                  },
                  hasError: () => false,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Refresh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 1);
      // No error snackbar on success; good data stays put.
      expect(find.text('Could not refresh. Showing saved data.'),
          findsNothing);
    });

    testWidgets('failed refresh shows snackbar with working Retry',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                AppRefreshIconButton(
                  errorMessage: 'Could not refresh. Showing saved data.',
                  onRefresh: () async {
                    calls++;
                  },
                  hasError: () => true,
                ),
              ],
            ),
            body: const Text('good data'),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Refresh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 1);
      // Existing good data is NOT cleared...
      expect(find.text('good data'), findsOneWidget);
      // ...and the failure surfaces as snackbar + Retry.
      expect(find.text('Could not refresh. Showing saved data.'),
          findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 2);
    });
  });
}
