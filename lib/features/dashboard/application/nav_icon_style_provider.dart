import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/assets/app_assets.dart';

const _kNavIconStyleKey = 'nav_icon_style';
const _kNavIdsIconStyleKey = 'nav_ids_icon_style';
const _kNavPassesIconStyleKey = 'nav_passes_icon_style';

enum NavIconStyle {
  classic,
  vertical,
}

extension NavIconStyleStorage on NavIconStyle {
  String get storageValue => name;

  static NavIconStyle fromStorage(String? value) {
    return NavIconStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => NavIconStyle.classic,
    );
  }
}

class NavIconStyleConfig {
  const NavIconStyleConfig({
    this.ids = NavIconStyle.classic,
    this.passes = NavIconStyle.classic,
  });

  final NavIconStyle ids;
  final NavIconStyle passes;

  NavIconStyleConfig copyWith({
    NavIconStyle? ids,
    NavIconStyle? passes,
  }) {
    return NavIconStyleConfig(
      ids: ids ?? this.ids,
      passes: passes ?? this.passes,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NavIconStyleConfig &&
        other.ids == ids &&
        other.passes == passes;
  }

  @override
  int get hashCode => Object.hash(ids, passes);
}

typedef NavTabIconAssets = ({String filled, String unfilled});

NavTabIconAssets navIdsAssetsFor(NavIconStyle style) {
  switch (style) {
    case NavIconStyle.vertical:
      return (
        filled: AppAssets.navAltIdsFilled,
        unfilled: AppAssets.navAltIdsUnfilled,
      );
    case NavIconStyle.classic:
      return (
        filled: AppAssets.navIdsFilled,
        unfilled: AppAssets.navIdsUnfilled,
      );
  }
}

NavTabIconAssets navPassesAssetsFor(NavIconStyle style) {
  switch (style) {
    case NavIconStyle.vertical:
      return (
        filled: AppAssets.navAltPassesFilled,
        unfilled: AppAssets.navAltPassesUnfilled,
      );
    case NavIconStyle.classic:
      return (
        filled: AppAssets.navPassesFilled,
        unfilled: AppAssets.navPassesUnfilled,
      );
  }
}

final navIconStylesProvider =
    StateNotifierProvider<NavIconStylesNotifier, NavIconStyleConfig>(
  (ref) => NavIconStylesNotifier(),
);

class NavIconStylesNotifier extends StateNotifier<NavIconStyleConfig> {
  NavIconStylesNotifier() : super(const NavIconStyleConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? legacy = prefs.getString(_kNavIconStyleKey);

    state = NavIconStyleConfig(
      ids: NavIconStyleStorage.fromStorage(
        prefs.getString(_kNavIdsIconStyleKey) ?? legacy,
      ),
      passes: NavIconStyleStorage.fromStorage(
        prefs.getString(_kNavPassesIconStyleKey) ?? legacy,
      ),
    );
  }

  Future<void> setIdsStyle(NavIconStyle style) async {
    if (state.ids == style) return;
    state = state.copyWith(ids: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNavIdsIconStyleKey, style.storageValue);
  }

  Future<void> setPassesStyle(NavIconStyle style) async {
    if (state.passes == style) return;
    state = state.copyWith(passes: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNavPassesIconStyleKey, style.storageValue);
  }
}