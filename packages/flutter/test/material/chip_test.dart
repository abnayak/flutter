// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'feedback_tester.dart';

void main() {
  /// Tests that a [Chip] that has its size constrained by its parent is
  /// further constraining the size of its child, the label widget.
  /// Optionally, adding an avatar or delete icon to the chip should not
  /// cause the chip or label to exceed its constrained size.
  Future<Null> _testConstrainedLabel(WidgetTester tester, {
    CircleAvatar avatar, VoidCallback onDeleted,
  }) async {
    const double labelWidth = 100.0;
    const double labelHeight = 50.0;
    const double chipParentWidth = 75.0;
    const double chipParentHeight = 25.0;
    final Key labelKey = new UniqueKey();

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new Container(
              width: chipParentWidth,
              height: chipParentHeight,
              child: new Chip(
                avatar: avatar,
                label: new Container(
                  key: labelKey,
                  width: labelWidth,
                  height: labelHeight,
                ),
                onDeleted: onDeleted,
              ),
            ),
          ),
        ),
      ),
    );

    final Size labelSize = tester.getSize(find.byKey(labelKey));
    expect(labelSize.width, lessThan(chipParentWidth));
    expect(labelSize.height, lessThanOrEqualTo(chipParentHeight));

    final Size chipSize = tester.getSize(find.byType(Chip));
    expect(chipSize.width, chipParentWidth);
    expect(chipSize.height, chipParentHeight);
  }

  testWidgets('Chip control test', (WidgetTester tester) async {
    final FeedbackTester feedback = new FeedbackTester();
    final List<String> deletedChipLabels = <String>[];
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Column(
            children: <Widget>[
              new Chip(
                avatar: const CircleAvatar(
                  child: const Text('A')
                ),
                label: const Text('Chip A'),
                onDeleted: () {
                  deletedChipLabels.add('A');
                },
                deleteButtonTooltipMessage: 'Delete chip A',
              ),
              new Chip(
                avatar: const CircleAvatar(
                  child: const Text('B')
                ),
                label: const Text('Chip B'),
                onDeleted: () {
                  deletedChipLabels.add('B');
                },
                deleteButtonTooltipMessage: 'Delete chip B',
              ),
            ]
          )
        )
      )
    );

    expect(tester.widget(find.byTooltip('Delete chip A')), isNotNull);
    expect(tester.widget(find.byTooltip('Delete chip B')), isNotNull);

    expect(feedback.clickSoundCount, 0);

    expect(deletedChipLabels, isEmpty);
    await tester.tap(find.byTooltip('Delete chip A'));
    expect(deletedChipLabels, equals(<String>['A']));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(feedback.clickSoundCount, 1);

    await tester.tap(find.byTooltip('Delete chip B'));
    expect(deletedChipLabels, equals(<String>['A', 'B']));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(feedback.clickSoundCount, 2);

    feedback.dispose();
  });

  testWidgets('Chip does not constrain size of label widget if it does not exceed '
              'the available space', (WidgetTester tester) async {
    const double labelWidth = 50.0;
    const double labelHeight = 30.0;
    final Key labelKey = new UniqueKey();

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Material(
          child: new Center(
            child: new Container(
              width: 500.0,
              height: 500.0,
              child: new Column(
                children: <Widget>[
                  new Chip(
                    label: new Container(
                      key: labelKey,
                      width: labelWidth,
                      height: labelHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Size labelSize = tester.getSize(find.byKey(labelKey));
    expect(labelSize.width, labelWidth);
    expect(labelSize.height, labelHeight);
  });

  testWidgets('Chip constrains the size of the label widget when it exceeds the '
              'available space', (WidgetTester tester) async {
    await _testConstrainedLabel(tester);
  });

  testWidgets('Chip constrains the size of the label widget when it exceeds the '
              'available space and the avatar is present', (WidgetTester tester) async {
    await _testConstrainedLabel(
      tester,
      avatar: const CircleAvatar(
        child: const Text('A')
      ),
    );
  });

  testWidgets('Chip constrains the size of the label widget when it exceeds the '
              'available space and the delete icon is present', (WidgetTester tester) async {
    await _testConstrainedLabel(
      tester,
      onDeleted: () {},
    );
  });

  testWidgets('Chip constrains the size of the label widget when it exceeds the '
              'available space and both avatar and delete icons are present', (WidgetTester tester) async {
    await _testConstrainedLabel(
      tester,
      avatar: const CircleAvatar(
        child: const Text('A')
      ),
      onDeleted: () {},
    );
  });

  testWidgets('Chip in row works ok', (WidgetTester tester) async {
    final TextStyle style = new TextStyle(fontFamily: 'Ahem', fontSize: 10.0);
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Row(
            children: <Widget>[
              new Chip(label: new Text('Test'), labelStyle: style),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Text)), const Size(40.0, 10.0));
    expect(tester.getSize(find.byType(Chip)), const Size(64.0, 32.0));
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Row(
            children: <Widget>[
              new Flexible(child: new Chip(label: new Text('Test'), labelStyle: style)),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Text)), const Size(40.0, 10.0));
    expect(tester.getSize(find.byType(Chip)), const Size(64.0, 32.0));
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Row(
            children: <Widget>[
              new Expanded(child: new Chip(label: new Text('Test'), labelStyle: style)),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Text)), const Size(40.0, 10.0));
    expect(tester.getSize(find.byType(Chip)), const Size(800.0, 32.0));
  });
  testWidgets('Chip supports RTL', (WidgetTester tester) async {
    final Widget test = new Overlay(
      initialEntries: <OverlayEntry>[
        new OverlayEntry(
          builder: (BuildContext context) {
            return new Material(
              child: new Center(
                child: new Chip(
                  onDeleted: () { },
                  label: new Text('ABC'),
                ),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.rtl,
        child: test,
      ),
    );
    expect(tester.getCenter(find.text('ABC')).dx, greaterThan(tester.getCenter(find.byType(Icon)).dx));

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: test,
      ),
    );
    expect(tester.getCenter(find.text('ABC')).dx, lessThan(tester.getCenter(find.byType(Icon)).dx));
  });

  testWidgets('Chip padding - LTR', (WidgetTester tester) async {
    final GlobalKey keyA = new GlobalKey();
    final GlobalKey keyB = new GlobalKey();
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Overlay(
          initialEntries: <OverlayEntry>[
            new OverlayEntry(
              builder: (BuildContext context) {
                return new Material(
                  child: new Center(
                    child: new Chip(
                      avatar: new Placeholder(key: keyA),
                      label: new Placeholder(key: keyB),
                      onDeleted: () { },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(keyA)), const Offset(0.0, 284.0));
    expect(tester.getBottomRight(find.byKey(keyA)), const Offset(32.0, 316.0));
    expect(tester.getTopLeft(find.byKey(keyB)), const Offset(40.0, 284.0));
    expect(tester.getBottomRight(find.byKey(keyB)), const Offset(774.0, 316.0));
    expect(tester.getTopLeft(find.byType(Icon)), const Offset(778.0, 291.0));
    expect(tester.getBottomRight(find.byType(Icon)), const Offset(796.0, 309.0));
  });

  testWidgets('Chip padding - RTL', (WidgetTester tester) async {
    final GlobalKey keyA = new GlobalKey();
    final GlobalKey keyB = new GlobalKey();
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.rtl,
        child: new Overlay(
          initialEntries: <OverlayEntry>[
            new OverlayEntry(
              builder: (BuildContext context) {
                return new Material(
                  child: new Center(
                    child: new Chip(
                      avatar: new Placeholder(key: keyA),
                      label: new Placeholder(key: keyB),
                      onDeleted: () { },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    expect(tester.getTopRight(find.byKey(keyA)), const Offset(800.0 - 0.0, 284.0));
    expect(tester.getBottomLeft(find.byKey(keyA)), const Offset(800.0 - 32.0, 316.0));
    expect(tester.getTopRight(find.byKey(keyB)), const Offset(800.0 - 40.0, 284.0));
    expect(tester.getBottomLeft(find.byKey(keyB)), const Offset(800.0 - 774.0, 316.0));
    expect(tester.getTopRight(find.byType(Icon)), const Offset(800.0 - 778.0, 291.0));
    expect(tester.getBottomLeft(find.byType(Icon)), const Offset(800.0 - 796.0, 309.0));
  });
}
