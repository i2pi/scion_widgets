// button_gallery.dart — living catalogue of every clickable style in the app.
//
// This page exists to drive the button consolidation: it renders each family
// side by side so the visual differences (and the states they do or don't
// support) are judgeable at a glance rather than by reading source.
//
// IMPORTANT: the specimens here are deliberately VERBATIM copies of the
// inline recipes at their origin sites, not calls into shared widgets — that
// is the whole point, since most of these styles have no shared widget to call.
// Each group names its origin as file:line. When a family is consolidated,
// delete its card here rather than "fixing" it, so this page always shows what
// the app actually looks like today. The one exception is the before/after card
// at the top, kept deliberately as the migration record while family C is still
// pending — its left column is dead code by design.
//
// Debug-only: main.dart gates both the page and its rail destination on
// kDebugMode, so it never ships.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_alert.dart';
import 'app_button.dart';
import 'grid.dart';
import 'labeled_card.dart';
import 'lighting_settings.dart';
import 'osc_checkbox.dart';
import 'osc_dropdown.dart';
import 'osc_radiolist.dart';
import 'panel.dart';

class ButtonGalleryPage extends StatefulWidget {
  const ButtonGalleryPage({super.key});

  @override
  State<ButtonGalleryPage> createState() => _ButtonGalleryPageState();
}

class _ButtonGalleryPageState extends State<ButtonGalleryPage> {
  // Demo state — every specimen is live so hover/press/selected can be felt.
  int _chipRegion = 2;
  int _appBtnRegion = 2;
  bool _redOn = false;
  bool _redOnApp = false;
  int _bits = 0x05;
  int _bitsApp = 0x05;
  String _tool = 'draw';
  bool _poster = false;
  bool _appSelected = true;
  int _tile = 0;
  int _sourceTile = 1;
  bool _check = true;
  int _radio = 1;
  String _dropdown = '1080p59.94';
  bool _keyReverse = false;
  bool _linked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageGutter = constraints.maxWidth * AppGrid.gutterFraction;
          final t = GridTokens(constraints.maxWidth);
          return GridProvider(
            tokens: t,
            child: GridGutterProvider(
              gutter: pageGutter,
              child: SingleChildScrollView(
                padding: t.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _comparison(t),
                    SizedBox(height: t.panelGap),
                    _familyA(t),
                    SizedBox(height: t.panelGap),
                    _familyC(t),
                    SizedBox(height: t.panelGap),
                    _familyDE(t),
                    SizedBox(height: t.panelGap),
                    _familyF(t),
                    SizedBox(height: t.panelGap),
                    _familyG(t),
                    SizedBox(height: t.panelGap),
                    _familyHIJ(t),
                    SizedBox(height: t.panelGap),
                    _familyK(t),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------- consolidation preview ---

  /// The A-vs-B/C decision, rendered directly: the same three controls in
  /// today's flat chip and in a dense [AppButton]. Both rows are live, so the
  /// real comparison — chips have no hover or press feedback at all — shows up
  /// under the pointer rather than in a diff.
  Widget _comparison(GridTokens t) {
    return LabeledCard(
      title: 'Migrated: flat chip → AppButton (before/after reference)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _note(t,
                'Family B is DONE — the left column no longer exists anywhere '
                'in the app and is kept only as the before/after record while '
                'family C is still pending the same decision. Hover and press '
                'each row: the chips had no hover or press feedback at all, and '
                'the ON/OFF chip resized as its label changed, shoving its '
                'neighbours.'),
            SizedBox(height: t.md),
            _compareRow(
              t,
              'Region tabs (radio group)',
              chips: Row(mainAxisSize: MainAxisSize.min, children: [
                for (int r = 1; r <= 4; r++) ...[
                  _flatChip(t, '$r', _chipRegion == r,
                      const Color(0xFF4A6A8A), const Color(0xFF6A9ACA),
                      () => setState(() => _chipRegion = r)),
                  SizedBox(width: t.xs),
                ],
              ]),
              buttons: Row(mainAxisSize: MainAxisSize.min, children: [
                for (int r = 1; r <= 4; r++) ...[
                  AppButton(
                    label: '$r',
                    dense: true,
                    selected: _appBtnRegion == r,
                    accentColor: kSelectAccent,
                    onPressed: () => setState(() => _appBtnRegion = r),
                  ),
                  SizedBox(width: t.xs),
                ],
              ]),
            ),
            SizedBox(height: t.md),
            _compareRow(
              t,
              'ON/OFF toggle — the loudest difference',
              chips: _flatChip(
                  t,
                  _redOn ? 'ON' : 'OFF',
                  _redOn,
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF6B6B),
                  () => setState(() => _redOn = !_redOn)),
              buttons: AppButton(
                label: _redOnApp ? 'ON' : 'OFF',
                sizeToLabels: const ['ON', 'OFF'],
                dense: true,
                selected: _redOnApp,
                accentColor: kToggleAccent,
                onPressed: () => setState(() => _redOnApp = !_redOnApp),
              ),
            ),
            SizedBox(height: t.md),
            _compareRow(
              t,
              'Bit toggles (amber, black label when set)',
              chips: Row(mainAxisSize: MainAxisSize.min, children: [
                for (int b = 0; b < 4; b++) ...[
                  _flatChip(
                      t,
                      'B$b',
                      (_bits & (1 << b)) != 0,
                      const Color(0xFFFFF176),
                      const Color(0xFFFFF176),
                      () => setState(() => _bits ^= (1 << b)),
                      selectedFg: Colors.black),
                  SizedBox(width: t.xs),
                ],
              ]),
              buttons: Row(mainAxisSize: MainAxisSize.min, children: [
                for (int b = 0; b < 4; b++) ...[
                  AppButton(
                    label: 'B$b',
                    dense: true,
                    selected: (_bitsApp & (1 << b)) != 0,
                    accentColor: kFlagAccent,
                    onPressed: () => setState(() => _bitsApp ^= (1 << b)),
                  ),
                  SizedBox(width: t.xs),
                ],
              ]),
            ),
            SizedBox(height: t.md),
            _note(t,
                'Blocked state: the chips carry Opacity(0.35) + forbidden '
                'cursor + tooltip (sprite_controls.dart:597, send_text.dart:283). '
                'AppButton has no equivalent — onPressed: null only dims the '
                'face and reverts the cursor to basic.'),
            SizedBox(height: t.sm),
            Row(children: [
              _blockedChip(t, '3'),
              SizedBox(width: t.md),
              const AppButton(label: '3', dense: true, onPressed: null),
              SizedBox(width: t.sm),
              Text('← AppButton disabled, for comparison',
                  style: t.textCaption),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(GridTokens t, String label,
      {required Widget chips, required Widget buttons}) {
    Widget side(String tag, Widget child) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tag, style: t.textCaption),
              SizedBox(height: t.xs),
              Align(alignment: Alignment.centerLeft, child: child),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: t.textLabel.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: t.xs),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          side('today — flat chip', chips),
          side('proposed — AppButton(dense: true)', buttons),
        ]),
      ],
    );
  }

  // ------------------------------------------------------------- family A ---

  Widget _familyA(GridTokens t) {
    return LabeledCard(
      title: 'A — AppButton (canonical, 34 call sites)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(t, 'app_button.dart — the only affordance with a press '
                'animation (AnimatedScale 0.97 / 110ms) and hover elevation.'),
            SizedBox(height: t.sm),
            _specRow(t, [
              _spec(t, 'label', AppButton(label: 'Apply', onPressed: () {})),
              _spec(t, 'icon only',
                  AppButton(icon: Icons.refresh, onPressed: () {})),
              _spec(
                  t,
                  'label + icon',
                  AppButton(
                      label: 'Upload',
                      icon: Icons.upload_file,
                      onPressed: () {})),
              _spec(
                  t,
                  'selected',
                  AppButton(
                      label: 'Lock',
                      icon: Icons.lock,
                      selected: _appSelected,
                      onPressed: () =>
                          setState(() => _appSelected = !_appSelected))),
              _spec(t, 'disabled',
                  const AppButton(label: 'Apply', onPressed: null)),
            ]),
            SizedBox(height: t.md),
            _origin(
                t,
                'Every accent that pairs with selected in the app, so the '
                'lit-face tint (app_button.dart:_face, now 0.85) can be judged '
                'against each. Tap to toggle.'),
            SizedBox(height: t.xs),
            Wrap(spacing: t.sm, runSpacing: t.sm, children: [
              for (final a in const [
                (Color(0xFF7A5CFF), 'Copper — sprite_controls:434'),
                (Color(0xFF4E8A62), 'Show — sprite_controls:690'),
                (Color(0xFFF0B830), 'Genlock — sync_mode_selection:157'),
                (Color(0xFFE05C5C), 'LUT chan R — lut_editor:951'),
                (Color(0xFF5CE07A), 'LUT chan G — lut_editor:951'),
                (Color(0xFF5C8AE0), 'LUT chan B — lut_editor:951'),
              ])
                _AccentProbe(accent: a.$1, caption: a.$2),
            ]),
            SizedBox(height: t.md),
            _specRow(t, [
              _spec(
                  t,
                  'accent (unselected → rim)',
                  AppButton(
                      label: 'Reset',
                      accentColor: const Color(0xFFE08A8E),
                      onPressed: () {})),
              _spec(
                  t,
                  'accent + selected',
                  AppButton(
                      label: 'R',
                      accentColor: const Color(0xFFE08A8E),
                      selected: true,
                      onPressed: () {})),
              _spec(t, 'dense',
                  AppButton(label: 'Clear All', dense: true, onPressed: () {})),
              _spec(
                  t,
                  'dense + icon',
                  AppButton(
                      icon: Icons.refresh, dense: true, onPressed: () {})),
              _spec(
                  t,
                  'tooltip',
                  AppButton(
                      icon: Icons.help_outline,
                      tooltip: 'Hover me',
                      onPressed: () {})),
            ]),
          ],
        ),
      ),
    );
  }

  /// Verbatim reproduction of the family-B recipe.
  Widget _flatChip(GridTokens t, String label, bool selected, Color fill,
      Color border, VoidCallback onTap,
      {Color selectedFg = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: t.md, vertical: t.xs),
        decoration: BoxDecoration(
          color: selected ? fill : const Color(0xFF2A2A2C),
          borderRadius: BorderRadius.circular(5),
          border:
              Border.all(color: selected ? border : Colors.grey[600]!),
        ),
        child: Text(label,
            style: t.textLabel.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? selectedFg : Colors.grey[300])),
      ),
    );
  }

  Widget _blockedChip(GridTokens t, String label) {
    return Opacity(
      opacity: 0.35,
      child: Tooltip(
        message: 'Region $label has text',
        child: MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: _flatChip(t, label, false, const Color(0xFF4A6A8A),
              const Color(0xFF6A9ACA), () {}),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- family C ---

  Widget _familyC(GridTokens t) {
    return LabeledCard(
      title: 'C — Compact flat chips (2 left; mixer page migrated)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(t,
                'Same idea as B at radius 4 with tighter padding, but no two '
                'agree on palette or geometry, so each needs its own call. The '
                'mixer page\'s A/B and AUTO buttons are done — see the Mixer '
                'page itself, not here. These two remain.'),
            SizedBox(height: t.sm),
            _group(t, 'shape_canvas.dart:1208 — _toolBtn, icon + label, amber '
                'active / #212124 idle, radius 4', [
              for (final tool in const [
                ('draw', Icons.edit),
                ('move', Icons.open_with),
                ('erase', Icons.auto_fix_normal),
              ])
                _toolBtn(t, tool.$2, tool.$1, tool.$1),
            ]),
            SizedBox(height: t.md),
            _group(t, 'lut_editor.dart:1095 — Posterize, #F0B830 active / '
                '#212124 idle, radius 5, white12 border', [
              _posterizeBtn(t),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(GridTokens t, IconData ic, String label, String key) {
    const amber = Color(0xFFF0B830);
    final active = _tool == key;
    return GestureDetector(
      onTap: () => setState(() => _tool = key),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: t.sm, vertical: t.xs * 0.8),
        decoration: BoxDecoration(
            color: active ? amber : const Color(0xFF212124),
            borderRadius: BorderRadius.circular(4)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(ic,
              size: t.u * 1.4,
              color: active ? Colors.black : const Color(0xFF8A8A92)),
          SizedBox(width: t.xs),
          Text(label,
              style: t.textCaption.copyWith(
                  color: active ? Colors.black : const Color(0xFF8A8A92),
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _posterizeBtn(GridTokens t) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _poster = !_poster),
      child: Container(
        decoration: BoxDecoration(
          color: _poster ? const Color(0xFFF0B830) : const Color(0xFF212124),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.view_column_outlined,
                size: 15,
                color: _poster ? Colors.black : const Color(0xFF9A9AA2)),
            const SizedBox(width: 5),
            Text('Posterize',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        _poster ? Colors.black : const Color(0xFF9A9AA2))),
          ]),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- families D+E ---

  Widget _familyDE(GridTokens t) {
    return LabeledCard(
      title: 'D & E — Selectable tiles (two unrelated implementations)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(
                t,
                'D is CustomPaint + Phong gradient, radius 12, gold 2px ring '
                'when selected. sync_mode_selection.dart:261 and '
                'din_cable_page.dart:100 each define their own private '
                '_TilePainter — same name, same code, zero sharing. The painter '
                'below is a third copy, kept verbatim so this page shows the '
                'real thing.'),
            SizedBox(height: t.sm),
            _group(t, 'D — neumorphic selectable tile', [
              for (int i = 0; i < 3; i++)
                _neumorphicTile(t, ['Auto', 'Genlock', 'Free run'][i],
                    _tile == i, () => setState(() => _tile = i)),
            ]),
            SizedBox(height: t.md),
            _origin(
                t,
                'E is a different shape entirely: NeumorphicInset on #262628, '
                'radius 4 inside a radius-6 transparent border that reserves '
                'room for the selection overlay. send_source_selector.dart:466.'),
            SizedBox(height: t.sm),
            _group(t, 'E — neumorphic inset tile', [
              for (int i = 0; i < 3; i++)
                _insetTile(t, ['SDI 1', 'SDI 2', 'HDMI'][i], _sourceTile == i,
                    () => setState(() => _sourceTile = i)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _neumorphicTile(
      GridTokens t, String label, bool selected, VoidCallback onTap) {
    final lighting = context.watch<LightingSettings>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: lighting.createNeumorphicShadows(elevation: 4.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter:
                _GalleryTilePainter(lighting: lighting, isSelected: selected),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule,
                      size: 26,
                      color: selected ? Colors.white : Colors.grey[400]),
                  SizedBox(height: t.xs),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: t.textCaption.copyWith(
                          color: selected ? Colors.white : Colors.grey[400])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _insetTile(
      GridTokens t, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: selected ? const Color(0xFFC9B066) : Colors.transparent,
              width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: NeumorphicInset(
            baseColor: const Color(0xFF262628),
            borderRadius: 4.0,
            child: Center(
              child: Text(label,
                  style: t.textLabel.copyWith(
                      color: selected
                          ? const Color(0xFFC9B066)
                          : Colors.grey[400])),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- family F ---

  Widget _familyF(GridTokens t) {
    return LabeledCard(
      title: 'F — Neumorphic form controls',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(
                t,
                'Custom-painted inputs that are also tap targets, each with '
                'its own MouseRegion hover state. These are shared widgets '
                'already — listed for completeness, not as merge candidates. '
                'Note the app also uses Material Switch (×2) and Checkbox (×2) '
                'alongside these.'),
            SizedBox(height: t.sm),
            Wrap(spacing: t.lg, runSpacing: t.md, children: [
              _spec(
                  t,
                  'OscCheckbox (osc_checkbox.dart:89)',
                  OscCheckbox(
                    initialValue: _check,
                    bindOsc: false,
                    label: 'Enabled',
                    onChanged: (v) => setState(() => _check = v),
                  )),
              _spec(
                  t,
                  'NeumorphicRadio (osc_radiolist.dart:380)',
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    for (int i = 0; i < 2; i++)
                      Padding(
                        padding: EdgeInsets.only(right: t.md),
                        child: NeumorphicRadio<int>(
                          value: i,
                          groupValue: _radio,
                          label: ['Internal', 'External'][i],
                          onChanged: (v) => setState(() => _radio = v),
                        ),
                      ),
                  ])),
              _spec(
                  t,
                  'NeumorphicDropdown (osc_dropdown.dart:290)',
                  NeumorphicDropdown<String>(
                    label: 'Format',
                    items: const ['1080p59.94', '1080i50', '720p60'],
                    value: _dropdown,
                    onChanged: (v) => setState(() => _dropdown = v),
                  )),
            ]),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- family G ---

  Widget _familyG(GridTokens t) {
    return LabeledCard(
      title: 'G — Unstyled Material defaults (6 IconButton, 9 TextButton, '
          '3 FilledButton)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(
                t,
                'These inherit stock Material and ignore the app\'s visual '
                'language entirely. Almost all TextButton/FilledButton uses are '
                'dialog actions, so they are only seen inside AlertDialogs — a '
                'separable question from the A/B/C merge.'),
            SizedBox(height: t.sm),
            _group(t, 'IconButton — every site picks its own size and colour', [
              IconButton(
                  icon: const Icon(Icons.ios_share, size: 15),
                  color: Colors.grey[500],
                  visualDensity: VisualDensity.compact,
                  tooltip: 'color_lut_actions.dart:182 — grey[500], 15px',
                  onPressed: () {}),
              IconButton(
                  icon: Icon(Icons.upload_file,
                      size: 18, color: Colors.grey[400]),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'font_controls.dart:144 — grey[400], 18px',
                  onPressed: () {}),
              SizedBox(
                width: 20,
                height: 20,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    icon: Icon(Icons.refresh, color: t.textCaption.color),
                    tooltip: 'grade_wheels.dart:311 — iconSize 14 in a 20px box',
                    onPressed: () {}),
              ),
              IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFE08A8E)),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'shape_canvas.dart:1197 — #E08A8E, 18px',
                  onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'network_selection.dart:204 — untouched defaults',
                  onPressed: () {}),
            ]),
            SizedBox(height: t.md),
            _group(t, 'TextButton / FilledButton — dialog actions', [
              TextButton(onPressed: () {}, child: const Text('Cancel')),
              FilledButton(onPressed: () {}, child: const Text('Save')),
              TextButton(
                  onPressed: () {},
                  child: const Text('Rescan',
                      style: TextStyle(
                          color: Color(0xFF7FB2D9), fontSize: 11))),
              TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.play_circle_outline,
                      size: 16, color: Colors.white.withValues(alpha: 0.6)),
                  label: Text('Explore in demo mode',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11))),
            ]),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- families H-J ---

  Widget _familyHIJ(GridTokens t) {
    return LabeledCard(
      title: 'H, I & J — Bare icons, text targets, and InkWell one-offs',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(
                t,
                'H: an icon with a tap handler and no background, hit area, or '
                'press state. The card-header preset icons are the most-used '
                'of these.'),
            SizedBox(height: t.sm),
            _group(t, 'H — bare icons', [
              // labeled_card.dart:170 — card header save/load/reset
              for (final ic in const [
                (Icons.save_outlined, 'Save preset…'),
                (Icons.history, 'Load preset…'),
                (Icons.restart_alt, 'Reset to defaults'),
              ])
                Tooltip(
                  message: '${ic.$2}  (labeled_card.dart:170)',
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child:
                          Icon(ic.$1, size: 15, color: Colors.grey[500]),
                    ),
                  ),
                ),
              SizedBox(width: t.md),
              GestureDetector(
                  onTap: () {},
                  child: const Tooltip(
                      message: 'osc_log.dart:403 — download',
                      child: Icon(Icons.download, size: 12))),
              SizedBox(width: t.md),
              GestureDetector(
                onTap: () => setState(() => _keyReverse = !_keyReverse),
                child: Tooltip(
                  message: 'send_source_selector.dart:898 — key reverse',
                  child: Icon(Icons.invert_colors,
                      size: 18,
                      color: _keyReverse
                          ? const Color(0xFFF0B830)
                          : const Color(0xFFD2D2D4)),
                ),
              ),
              SizedBox(width: t.md),
              GestureDetector(
                onTap: () => setState(() => _linked = !_linked),
                behavior: HitTestBehavior.opaque,
                child: Tooltip(
                  message: 'shape.dart:140 — link/unlink',
                  child: Icon(_linked ? Icons.link : Icons.link_off,
                      size: 18,
                      color: _linked
                          ? const Color(0xFFFFF176)
                          : Colors.grey[600]),
                ),
              ),
            ]),
            SizedBox(height: t.md),
            _origin(
                t,
                'I: text that copies on tap, with no affordance beyond the '
                'cursor. osc_log.dart:239 uses GestureDetector; '
                'rotary_knob.dart:858 uses a raw Listener.'),
            SizedBox(height: t.sm),
            _group(t, 'I — clipboard targets', [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        const ClipboardData(text: '/send/1/color/brightness'));
                    showAppAlert(context, 'Copied to clipboard');
                  },
                  child: Text('/send/1/color/brightness',
                      style: const TextStyle(
                          fontFamily: 'Courier', fontSize: 11)),
                ),
              ),
              SizedBox(width: t.md),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  Clipboard.setData(
                      const ClipboardData(text: '/send/1/shape/size'));
                  showAppAlert(context, 'Copied to clipboard');
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.content_copy, size: 10, color: Colors.white54),
                  SizedBox(width: 4),
                  Text('/send/1/shape/size',
                      style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          color: Colors.white54)),
                ]),
              ),
            ]),
            SizedBox(height: t.md),
            _origin(
                t,
                'J: four unrelated InkWell looks — device rows, the demo '
                'banner, the log jump-to-bottom pill, and the active-LUT '
                'clear.'),
            SizedBox(height: t.sm),
            Wrap(spacing: t.md, runSpacing: t.sm, children: [
              // disconnected_scrim.dart:119
              SizedBox(
                width: 240,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.developer_board,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 10),
                        Text('192.168.1.44:9000',
                            style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                  ),
                ),
              ),
              // osc_log.dart:510
              SizedBox(
                width: 180,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FB2D9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    alignment: Alignment.center,
                    child: const Text('12 new',
                        style: TextStyle(
                            color: Colors.black, fontSize: 11)),
                  ),
                ),
              ),
              // color_lut_actions.dart:168
              InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.grain, size: 15, color: Color(0xFFC9B066)),
                    SizedBox(width: 3),
                    Text('kodak_2383',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFC9B066))),
                  ]),
                ),
              ),
            ]),
            SizedBox(height: t.md),
            // main.dart:561 — full-width amber strip
            Material(
              color: const Color(0xFFF0B830),
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline,
                              color: Colors.black, size: 15),
                          SizedBox(width: 6),
                          Text('DEMO MODE',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text('tap to exit',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- family K ---

  Widget _familyK(GridTokens t) {
    return LabeledCard(
      title: 'K — NavigationRail (stock Material)',
      networkIndependent: true,
      child: CardBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _origin(
                t,
                'main.dart:419. Selection is Material\'s own pill indicator, '
                'matching nothing else in the app. Wrapped in a custom '
                '_NeumorphicNavRail for the surface only.'),
            SizedBox(height: t.sm),
            SizedBox(
              height: 190,
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: 1,
                onDestinationSelected: (_) {},
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.memory), label: Text('System')),
                  NavigationRailDestination(
                      icon: Icon(Icons.tune), label: Text('Mixer')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings), label: Text('Setup')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- bits ----

  Widget _note(GridTokens t, String text) => Text(text,
      style: t.textCaption.copyWith(color: const Color(0xFFB8B8C0)));

  Widget _origin(GridTokens t, String text) => Text(text,
      style: t.textCaption.copyWith(color: const Color(0xFF8A8A92)));

  /// A captioned specimen.
  Widget _spec(GridTokens t, String caption, Widget child) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          SizedBox(height: t.xs),
          Text(caption, style: t.textCaption),
        ],
      );

  Widget _specRow(GridTokens t, List<Widget> children) => Wrap(
      spacing: t.lg,
      runSpacing: t.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children);

  /// A titled row of specimens sharing one origin.
  Widget _group(GridTokens t, String origin, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _origin(t, origin),
          SizedBox(height: t.xs),
          Wrap(
              spacing: t.xs,
              runSpacing: t.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children),
        ],
      );
}

/// One accent, toggled on its own, captioned with the site it comes from.
/// Its own StatefulWidget so each probe holds its own on/off state without
/// adding a field per accent to the page.
class _AccentProbe extends StatefulWidget {
  final Color accent;
  final String caption;
  const _AccentProbe({required this.accent, required this.caption});

  @override
  State<_AccentProbe> createState() => _AccentProbeState();
}

class _AccentProbeState extends State<_AccentProbe> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    final t = GridProvider.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: _on ? 'ON' : 'OFF',
          sizeToLabels: const ['ON', 'OFF'],
          dense: true,
          selected: _on,
          accentColor: widget.accent,
          onPressed: () => setState(() => _on = !_on),
        ),
        SizedBox(height: t.xs),
        Text(widget.caption, style: t.textCaption),
      ],
    );
  }
}

/// Verbatim copy of the private _TilePainter duplicated in
/// sync_mode_selection.dart:286 and din_cable_page.dart:153. Copied rather than
/// imported because both originals are private — which is precisely the
/// duplication this page is cataloguing.
class _GalleryTilePainter extends CustomPainter {
  final LightingSettings lighting;
  final bool isSelected;

  _GalleryTilePainter({required this.lighting, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final baseColor =
        isSelected ? const Color(0xFF606068) : const Color(0xFF505055);
    final gradient = lighting.createPhongSurfaceGradient(
      baseColor: baseColor,
      intensity: 0.08,
    );
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rect));

    final light = lighting.lightDir2D;
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment(light.dx, light.dy),
        end: Alignment(-light.dx, -light.dy),
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.12),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect.deflate(0.5), highlightPaint);

    if (isSelected) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (lighting.noiseImage != null) {
      final noisePaint = Paint()
        ..shader = ui.ImageShader(
          lighting.noiseImage!,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        )
        ..blendMode = BlendMode.overlay;

      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(rect, noisePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GalleryTilePainter old) =>
      old.lighting.lightPhi != lighting.lightPhi ||
      old.lighting.lightTheta != lighting.lightTheta ||
      old.lighting.noiseImage != lighting.noiseImage ||
      old.isSelected != isSelected;
}
