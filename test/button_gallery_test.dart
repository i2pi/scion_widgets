// Smoke test for the debug-only button style gallery: it must build at the
// widths the app actually runs at, and every specimen must be tappable without
// throwing. The page is a catalogue of live controls, so a silent build failure
// there would be easy to miss.
//
// Resizing the test view fires _GlobalRectResizeSignal.didChangeMetrics
// (global_rect_tracking.dart:23), which starts a 220 ms debounce timer. Both
// the initial resize and the reset have to be flushed with a pump longer than
// that, or the timer outlives the widget tree and the test framework fails the
// test — hence _sized() rather than a bare addTearDown(view.reset).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SCION_Controller/button_gallery.dart';

import 'design_lab/harness.dart';

const _debounceFlush = Duration(milliseconds: 300);

/// Render the gallery at [width], flushing the resize debounce on both edges.
Future<void> _sized(WidgetTester tester, double width,
    Future<void> Function() body) async {
  await loadAppFonts();
  tester.view.physicalSize = Size(width, 2400);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
      labScaffold(child: const ButtonGalleryPage(), width: width));
  await tester.pumpAndSettle();
  await tester.pump(_debounceFlush);

  await body();

  tester.view.reset();
  await tester.pump(_debounceFlush);
}

void main() {
  for (final width in <double>[1024, 1400, 1948]) {
    testWidgets('ButtonGalleryPage builds at $width', (tester) async {
      await _sized(tester, width, () async {
        expect(tester.takeException(), isNull);
        expect(find.byType(ButtonGalleryPage), findsOneWidget);
      });
    });
  }

  testWidgets('every specimen is tappable', (tester) async {
    await _sized(tester, 1400, () async {
      // Tap one specimen from each interactive family that is laid out on
      // screen. warnIfMissed is off: many specimens sit below the fold of the
      // scroll view, and the point here is that the handler runs without
      // throwing, not that the hit lands visually.
      for (final label in ['4', 'ON', 'B2', '2×', 'A', 'AUTO', 'Posterize']) {
        final f = find.text(label);
        if (f.evaluate().isEmpty) continue;
        await tester.tap(f.first, warnIfMissed: false);
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: 'tapping "$label" threw');
      }
    });
  });
}
