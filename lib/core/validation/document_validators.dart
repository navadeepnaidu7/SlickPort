import 'package:flutter/foundation.dart';

/// Shared validation helpers ("exceptions") for document data entry.
/// Used by ID entry, passport entry, and post-scan preview confirm flows.
class DocumentValidators {
  DocumentValidators._();

  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _aadhaarDigits = RegExp(r'^\d{12}$');

  /// Safely parse "YYYY-MM-DD" or "YYYYMMDD" style. Returns null on failure.
  static DateTime? tryParseYmd(String raw) {
    if (raw.trim().isEmpty) return null;
    var s = raw.trim().replaceAll(RegExp(r'[-/]'), '');
    if (s.length == 8) {
      final y = int.tryParse(s.substring(0, 4));
      final m = int.tryParse(s.substring(4, 6));
      final d = int.tryParse(s.substring(6, 8));
      if (y != null && m != null && d != null) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }
    // Try direct ISO
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Returns an error message if the DOB is invalid, or null if acceptable.
  /// - Future or today → error
  /// - requireAdult (PAN) → must be at least 18 years old
  /// - Unrealistic (before 1900 or age > 120) → error
  static String? validateDateOfBirth(String raw, {bool requireAdult = false}) {
    if (raw.trim().isEmpty) return null; // optional in many flows

    final date = tryParseYmd(raw);
    if (date == null) {
      return 'Please enter a valid date of birth.';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!date.isBefore(today)) {
      return 'Date of birth cannot be today or in the future.';
    }

    // Unrealistic old
    if (date.isBefore(DateTime(1900, 1, 1))) {
      return 'Date of birth is unrealistically old.';
    }

    // Age calculation (rough)
    int age = today.year - date.year;
    if (today.month < date.month ||
        (today.month == date.month && today.day < date.day)) {
      age--;
    }

    if (age > 120) {
      return 'Date of birth implies an unrealistic age.';
    }

    if (requireAdult && age < 18) {
      return 'PAN requires the holder to be at least 18 years old.';
    }

    return null;
  }

  /// Returns error if expiry is invalid.
  /// - Must be in the future (if provided)
  /// - If dob provided, expiry must be after DOB
  static String? validateExpiryDate(String raw, {String? dob}) {
    if (raw.trim().isEmpty) return null;

    final exp = tryParseYmd(raw);
    if (exp == null) {
      return 'Please enter a valid expiry date.';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!exp.isAfter(today)) {
      return 'Expiry date must be in the future.';
    }

    if (dob != null && dob.trim().isNotEmpty) {
      final birth = tryParseYmd(dob);
      if (birth != null && !exp.isAfter(birth)) {
        return 'Expiry date must be after date of birth.';
      }
    }

    // Cap at ~30 years in future (generous for passports)
    if (exp.year > today.year + 30) {
      return 'Expiry date is too far in the future.';
    }

    return null;
  }

  /// PAN number format validation (when non-empty).
  static String? validatePanNumber(String raw) {
    final v = raw.trim().toUpperCase().replaceAll(RegExp(r'\s'), '');
    if (v.isEmpty) return null;
    if (!_panRegex.hasMatch(v)) {
      return 'PAN must be 10 characters: 5 letters, 4 digits, 1 letter (e.g. ABCDE1234F).';
    }
    return null;
  }

  /// Basic Aadhaar check (12 digits, optional spaces).
  static String? validateAadhaarNumber(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'\s'), '');
    if (digitsOnly.isEmpty) return null;
    if (digitsOnly.length != 12 || !_aadhaarDigits.hasMatch(digitsOnly)) {
      return 'Aadhaar must be 12 digits.';
    }
    return null;
  }

  /// Convenience: run relevant checks for an ID document type.
  /// Returns first error found, or null if OK.
  static String? validateIdForSave({
    required String dateOfBirth,
    required String documentNumber,
    required IdDocumentTypeForValidation type,
  }) {
    // DOB (require adult only for PAN)
    final dobErr = validateDateOfBirth(
      dateOfBirth,
      requireAdult: type == IdDocumentTypeForValidation.pan,
    );
    if (dobErr != null) return dobErr;

    // Number format
    if (type == IdDocumentTypeForValidation.pan) {
      final panErr = validatePanNumber(documentNumber);
      if (panErr != null) return panErr;
    } else if (type == IdDocumentTypeForValidation.aadhaar) {
      final aadErr = validateAadhaarNumber(documentNumber);
      if (aadErr != null) return aadErr;
    }

    return null;
  }

  /// For passport context (DOB + expiry both matter).
  static String? validatePassportDates({
    required String dateOfBirth,
    required String expiryDate,
  }) {
    final dobErr = validateDateOfBirth(dateOfBirth);
    if (dobErr != null) return dobErr;

    final expErr = validateExpiryDate(expiryDate, dob: dateOfBirth);
    if (expErr != null) return expErr;

    return null;
  }
}

/// Lightweight enum to avoid importing full IdDocumentType in core.
enum IdDocumentTypeForValidation { pan, aadhaar, passport }

@visibleForTesting
DateTime? debugTryParseYmd(String raw) => DocumentValidators.tryParseYmd(raw);