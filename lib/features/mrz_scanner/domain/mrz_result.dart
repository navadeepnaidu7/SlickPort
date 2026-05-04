// Domain model for MRZ + full-page OCR scan results.
class MrzResult {
  const MrzResult({
    required this.passportNumber,
    required this.dateOfBirth,
    required this.expiryDate,
    required this.surname,
    required this.givenNames,
    required this.nationality,
    required this.gender,
    required this.checksumValid,
    required this.rawLine1,
    required this.rawLine2,
    this.fullName = '',
    this.issuingCountry = '',
    this.capturedImagePath = '',
  });

  /// Passport / travel document number (from MRZ field 1)
  final String passportNumber;

  /// Date of birth in YYYY-MM-DD format
  final String dateOfBirth;

  /// Expiry date in YYYY-MM-DD format
  final String expiryDate;

  /// Surname extracted from MRZ (upper-case)
  final String surname;

  /// Given name(s) extracted from MRZ (upper-case)
  final String givenNames;

  /// 3-letter ISO nationality code from MRZ
  final String nationality;

  /// 'M', 'F', or '<'
  final String gender;

  /// Whether all MRZ check digits passed
  final bool checksumValid;

  final String rawLine1;
  final String rawLine2;

  /// Better-formatted full name from the visual zone (may be empty)
  final String fullName;

  /// Issuing country from visual zone (may differ from nationality)
  final String issuingCountry;

  /// Absolute path to the captured passport image on disk
  final String capturedImagePath;

  /// Best display name: prefer visual zone, fall back to MRZ
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    final parts = <String>[
      givenNames.toLowerCase().split(' ').map(_capitalise).join(' '),
      surname.toLowerCase().split(' ').map(_capitalise).join(' '),
    ].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  MrzResult copyWith({
    String? passportNumber,
    String? dateOfBirth,
    String? expiryDate,
    String? surname,
    String? givenNames,
    String? nationality,
    String? gender,
    bool? checksumValid,
    String? rawLine1,
    String? rawLine2,
    String? fullName,
    String? issuingCountry,
    String? capturedImagePath,
  }) {
    return MrzResult(
      passportNumber: passportNumber ?? this.passportNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      expiryDate: expiryDate ?? this.expiryDate,
      surname: surname ?? this.surname,
      givenNames: givenNames ?? this.givenNames,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      checksumValid: checksumValid ?? this.checksumValid,
      rawLine1: rawLine1 ?? this.rawLine1,
      rawLine2: rawLine2 ?? this.rawLine2,
      fullName: fullName ?? this.fullName,
      issuingCountry: issuingCountry ?? this.issuingCountry,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    );
  }

  @override
  String toString() =>
      'MrzResult(passport: $passportNumber, dob: $dateOfBirth, exp: $expiryDate, '
      'name: $displayName, nat: $nationality, valid: $checksumValid)';
}
