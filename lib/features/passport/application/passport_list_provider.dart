import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/passport_profile.dart';

final passportListProvider =
    StateNotifierProvider<PassportListController, List<PassportProfile>>((Ref ref) {
  final controller = PassportListController();
  controller.loadPassports(); // async load
  return controller;
});

class PassportListController extends StateNotifier<List<PassportProfile>> {
  PassportListController() : super([]);

  static const _storageKey = 'saved_passports';

  Future<void> loadPassports() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedData = prefs.getStringList(_storageKey);

    if (savedData != null && savedData.isNotEmpty) {
      state = savedData.map((str) => PassportProfile.fromJson(str)).toList();
    } else {
      // Load default demo profile if completely empty
      state = [
        PassportProfile(
          id: 'demo_maya_001',
          name: 'Maya Johnson',
          passportNumber: 'E12345678',
          nationality: 'American',
          dateOfBirth: '1991-04-12',
          expiryDate: '2031-08-15',
          imagePath: '',
          mrzRaw:
              'P<USAMAYA<<JOHNSON<<<<<<<<<<<<<<<<<<<<<<<<\nE12345678USA9104129F3108157<<<<<<<<<<<<<<04',
          isEPassport: true,
          gender: 'F',
          placeOfBirth: 'New York, USA',
          issueDate: '2021-08-15',
          issuingAuthority: 'US Department of State',
        )
      ];
    }
  }

  Future<void> _savePassports(List<PassportProfile> passports) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList = passports.map((p) => p.toJson()).toList();
    await prefs.setStringList(_storageKey, encodedList);
  }

  void addPassport(PassportProfile profile) {
    // Add to the front so it appears immediately on the dashboard fluidly
    final newState = [profile, ...state];
    state = newState;
    _savePassports(newState);
  }

  /// Removes a passport by its unique [id] — NOT by passport number,
  /// so multiple cards with the same number are never accidentally bulk-deleted.
  void removePassport(String id) {
    final newState = state.where((p) => p.id != id).toList();
    state = newState;
    _savePassports(newState);
  }

  void updatePassport(int index, PassportProfile profile) {
    final newState = [...state];
    newState[index] = profile;
    state = newState;
    _savePassports(newState);
  }
}
