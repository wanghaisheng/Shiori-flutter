import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/main.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:window_size/window_size.dart';

import '../extensions/widget_tester_extensions.dart';
import 'common_bottom_sheet.dart';

const Key toastKey = Key('toast-body');

typedef ConfigureSettingsCallBack = Future<void> Function(SettingsService);

abstract class BasePage {
  static bool initialized = false;

  static const verticalDragOffset = Offset(0, -50);
  static const horizontalDragOffset = Offset(-800, 0);
  static const threeHundredMsDuration = Duration(milliseconds: 300);

  final WidgetTester tester;

  const BasePage(this.tester);

  Future<BasePage> initialize({
    bool resetResources = false,
    bool deleteData = false,
    ConfigureSettingsCallBack? configureSettingsCallBack,
  }) async {
    await _init(resetResources, deleteData);
    if (configureSettingsCallBack != null) {
      await configureSettingsCallBack(getIt<SettingsService>());
    }

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    return this;
  }

  Future<BasePage> waitForToastToHide() async {
    await tester.pumpUntilNotFound(find.byKey(toastKey));
    return this;
  }

  BasePage checkForToast(ToastType type) {
    final color = switch (type) {
      ToastType.info => Colors.blue,
      ToastType.succeed => Colors.green,
      ToastType.warning => Colors.orange,
      ToastType.error => Colors.red,
    };
    final container = tester.firstWidget<Container>(find.byKey(toastKey));
    expect(container.decoration, isNotNull);
    expect((container.decoration! as BoxDecoration).color, color);
    return this;
  }

  Future<BasePage> closeConfirmDialog({bool tapOnOk = true}) async {
    if (tester.any(find.byType(AlertDialog))) {
      final button = find.byType(tapOnOk ? ElevatedButton : OutlinedButton);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    return this;
  }

  Future<BasePage> enterSearchText(String text) async {
    final Finder finder = find.byType(TextField);
    expect(finder, findsOneWidget);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
    return this;
  }

  Future<CommonBottomSheet> tapFilterIcon() async {
    final Finder finder = find.byIcon(Shiori.filter);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    return CommonBottomSheet(tester);
  }

  Future<void> _init(bool resetResources, bool deleteData) async {
    if (!initialized) {
      //This is required by app center
      WidgetsFlutterBinding.ensureInitialized();
      await Injection.init(isLoggingEnabled: false);

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setWindowMinSize(SizeUtils.minSizeOnDesktop);
        setWindowMaxSize(Size.infinite);
      }
    }

    if (resetResources) {
      _resetResourcesVersion();
    }

    if (deleteData) {
      final dataService = getIt<DataService>();
      await dataService.deleteThemAll();
    }

    initialized = true;
  }

  void _resetResourcesVersion() {
    final settingsService = getIt<SettingsService>();
    if (settingsService.noResourcesHasBeenDownloaded) {
      return;
    }
    settingsService.resourceVersion = -1;
    settingsService.lastResourcesCheckedDate = null;
  }

  Future<void> tapOnAssetImageIcon(String path, {int expectedCount = 1}) async {
    final Finder finder = find.widgetWithImage(IconButton, AssetImage(path));
    expect(finder, findsAtLeastNWidgets(expectedCount));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapOnPopupMenuButtonIcon(IconData icon, int index) async {
    final Finder finder = find.byIcon(icon);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    await tapOnPopupMenuEntry(index);
  }

  Future<void> tapOnPopupMenuEntry(int index) async {
    final Finder menuItems = find.byWidgetPredicate((widget) => widget is PopupMenuEntry);
    expect(menuItems, findsAtLeastNWidgets(index + 1));

    await tester.tap(menuItems.at(index));
    await tester.pumpAndSettle();
  }

  Future<void> selectValueInNumberPickerDialog(dynamic value, {bool scrollsFromBottomToTop = true, int maxIteration = 1000}) async {
    //First scroll until value is visible
    final double dy = scrollsFromBottomToTop ? -30 : 30;
    final offset = Offset(0, dy);
    final Finder scrollView = find.byType(InfiniteListView);
    await tester.dragUntilVisible(
      find.descendant(
        of: scrollView,
        matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == '$value' && widget.style?.color == Colors.red),
      ),
      scrollView,
      offset,
      maxIteration: maxIteration,
      duration: const Duration(milliseconds: 20),
    );
    await tester.pumpAndSettle();

    if (value is int) {
      //Get the current selected value to see how much do we have to keep scrolling
      final Finder selectedTextFinder = find.descendant(
        of: scrollView,
        matching: find.byWidgetPredicate((widget) => widget is Text && widget.style?.color == Colors.red),
      );
      final Text selectedText = tester.firstWidget<Text>(selectedTextFinder);
      final int selectedValue = int.parse(selectedText.data!);
      final int diff = value - selectedValue;
      expect(diff, isZero);
    }

    await tester.tap(find.descendant(of: find.byType(NumberPickerDialog), matching: find.byType(ElevatedButton)));
    await tester.pumpAndSettle();
  }

  Future<void> swipeHorizontallyOnItem(Finder itemFinder, {bool rightToLeft = false}) async {
    double dx = BasePage.horizontalDragOffset.dx;
    if (!rightToLeft) {
      dx = dx.abs();
    }
    final offset = Offset(dx, 0);
    await tester.drag(itemFinder, offset);
    await tester.pumpAndSettle();
  }

  Future<void> tapOnCommonDropdownButton<TEnum>() async {
    await tester.tap(find.byType(CommonDropdownButton<TEnum>));
    await tester.pumpAndSettle(threeHundredMsDuration);
  }

  Future<void> selectOptionFromDropdownButtonWithTitle<TEnum>({int? index, String? name}) async {
    assert(index != null || name.isNotNullEmptyOrWhitespace);

    if (name.isNotNullEmptyOrWhitespace) {
      final Finder menuItemFinder = find.widgetWithText(DropdownMenuItem<TEnum>, name!);
      await tester.tap(menuItemFinder);
      await tester.pumpAndSettle();
      return;
    }

    final Finder menuItemFinder = find.byType(DropdownMenuItem<TEnum>).at(index!);
    await tester.tap(menuItemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> selectEnumDialogOption<TEnum>(int index) async {
    final key = Key('$index');
    await tester.dragUntilVisible(
      find.byKey(key),
      find.descendant(of: find.byType(SelectEnumDialog<TEnum>), matching: find.byType(ListView)),
      verticalDragOffset,
    );

    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  Future<void> tapOnBackButton() async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }
}
