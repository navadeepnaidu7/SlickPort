import '../domain/mrz_result.dart';

/// Deterministic ICAO 9303 TD3 (passport) MRZ parser.
///
/// TD3 format:
///   Line 1: 44 chars — document type, issuing state, name
///   Line 2: 44 chars — passport number, check, nationality, DOB, check,
///                       sex, expiry, check, optional data, check, composite check
class MrzParser {
  MrzParser._();

  // Check digit weights cycle: 7, 3, 1
  static const _weights = <int>[7, 3, 1];

  // Values for check digit computation
  static int _charValue(String ch) {
    if (ch == '<') return 0;
    if (ch.codeUnitAt(0) >= 'A'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10;
    }
    return int.parse(ch);
  }

  static int _checkDigit(String field) {
    var sum = 0;
    for (var i = 0; i < field.length; i++) {
      sum += _charValue(field[i]) * _weights[i % 3];
    }
    return sum % 10;
  }

  /// Attempts to parse two MRZ lines. Returns null if the lines don't look
  /// like a valid TD3 MRZ.
  static MrzResult? parse(String line1Raw, String line2Raw) {
    final l1 = _clean(line1Raw);
    final l2 = _clean(line2Raw);

    if (l1.length != 44 || l2.length != 44) return null;
    if (l1[0] != 'P') return null; // TD3 passports start with P

    // ── Line 1 ──────────────────────────────────────────────────
    // [0]    document type (P)
    // [1]    document sub-type (or <)
    // [2-4]  issuing state (3 chars)
    // [5-43] name (39 chars, surname<<givennames)
    final nameField = l1.substring(5, 44);
    final nameParts = nameField.split('<<');
    final surname = _decodeNamePart(nameParts.isNotEmpty ? nameParts[0] : '');
    final givenNames = _decodeNamePart(nameParts.length > 1 ? nameParts[1] : '');

    // ── Line 2 ──────────────────────────────────────────────────
    // [0-8]   passport number (9 chars)
    // [9]     check digit (passport number)
    // [10-12] nationality (3 chars)
    // [13-18] DOB YYMMDD
    // [19]    check digit (DOB)
    // [20]    sex (M/F/<)
    // [21-26] expiry YYMMDD
    // [27]    check digit (expiry)
    // [28-41] optional data (14 chars)
    // [42]    check digit (optional)
    // [43]    composite check digit
    final passportNumber = l2.substring(0, 9).replaceAll('<', '');
    final passportCheck = int.tryParse(l2[9]) ?? -1;
    final nationality = l2.substring(10, 13).replaceAll('<', '');
    final dobRaw = l2.substring(13, 19);
    final dobCheck = int.tryParse(l2[19]) ?? -1;
    final sex = l2[20];
    final expiryRaw = l2.substring(21, 27);
    final expiryCheck = int.tryParse(l2[27]) ?? -1;
    final compositeCheck = int.tryParse(l2[43]) ?? -1;

    // ── Validate check digits ────────────────────────────────────
    final passportOk = _checkDigit(l2.substring(0, 9)) == passportCheck;
    final dobOk = _checkDigit(dobRaw) == dobCheck;
    final expiryOk = _checkDigit(expiryRaw) == expiryCheck;
    final compositeField = l2.substring(0, 10) + l2.substring(13, 20) +
        l2.substring(21, 43);
    final compositeOk = _checkDigit(compositeField) == compositeCheck;
    final checksumValid = passportOk && dobOk && expiryOk && compositeOk;

    return MrzResult(
      passportNumber: passportNumber,
      dateOfBirth: _parseDate(dobRaw, isBirth: true),
      expiryDate: _parseDate(expiryRaw, isBirth: false),
      surname: surname,
      givenNames: givenNames,
      nationality: nationality,
      gender: sex == 'M' ? 'M' : sex == 'F' ? 'F' : '',
      checksumValid: checksumValid,
      rawLine1: l1,
      rawLine2: l2,
    );
  }

  /// Tries to find two MRZ lines anywhere in [text] (e.g. full-page OCR output).
  static MrzResult? findInText(String text) {
    final lines = text
        .toUpperCase()
        .split(RegExp(r'[\n\r]+'))
        .map(_clean)
        .where((l) => l.length >= 40)
        .toList();

    // Look for consecutive lines that look like MRZ
    for (var i = 0; i < lines.length - 1; i++) {
      final candidate1 = _padTo44(lines[i]);
      final candidate2 = _padTo44(lines[i + 1]);
      if (candidate1[0] == 'P') {
        final result = parse(candidate1, candidate2);
        if (result != null) return result;
      }
    }
    return null;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _clean(String s) {
    return s
        .toUpperCase()
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll(RegExp(r'[^A-Z0-9<]'), '<');
  }

  static String _padTo44(String s) {
    if (s.length >= 44) return s.substring(0, 44);
    return s.padRight(44, '<');
  }

  static String _decodeNamePart(String raw) =>
      raw.replaceAll('<', ' ').trim();

  /// Converts YYMMDD → YYYY-MM-DD.
  /// Birth dates: YY > 30 → 19YY (person born before 2030 is most likely 1900s).
  /// Expiry dates: always 20YY (passports expire within 10 years).
  static String _parseDate(String yymmdd, {required bool isBirth}) {
    if (yymmdd.length != 6) return '';
    final yy = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    final mm = yymmdd.substring(2, 4);
    final dd = yymmdd.substring(4, 6);
    final currentYearShort = DateTime.now().year % 100;
    int century;
    if (isBirth) {
      century = yy > currentYearShort ? 1900 : 2000;
    } else {
      century = 2000; // expiry dates are always in the future
    }
    return '${century + yy}-$mm-$dd';
  }
}
