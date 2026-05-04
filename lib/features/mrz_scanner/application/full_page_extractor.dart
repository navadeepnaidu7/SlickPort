/// Heuristic extractor for the visual zone of a passport data page.
///
/// Uses regex patterns on raw OCR text to find name, dates, nationality, etc.
/// Results are intentionally partial — only fields that can be confidently
/// matched are returned. The MRZ parser is the authoritative source for
/// passport number, DOB, and expiry.
class FullPageExtractor {
  FullPageExtractor._();

  /// Extracts what it can from the full OCR text of a passport data page.
  static FullPageData extract(String ocrText) {
    final text = ocrText;
    final lines = text.split(RegExp(r'[\n\r]+')).map((l) => l.trim()).toList();

    return FullPageData(
      fullName: _extractName(lines),
      issuingCountry: _extractIssuingCountry(text),
      dateOfIssue: _extractDateByLabel(text, RegExp(r'(date of issue|issued|délivré)', caseSensitive: false)),
      placeOfBirth: _extractByLabel(text, RegExp(r'(place of birth|lieu de naissance)', caseSensitive: false)),
    );
  }

  // ── Name extraction ────────────────────────────────────────────────────────
  // Passports have "Surname" / "Last Name" then a value, then "Given Names" / "First Name"
  static String _extractName(List<String> lines) {
    String? surname;
    String? givenNames;

    final surnameLabel = RegExp(r'^(surname|last\s*name|nom)', caseSensitive: false);
    final givenLabel = RegExp(r'^(given\s*names?|first\s*names?|prénom)', caseSensitive: false);

    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (surnameLabel.hasMatch(l)) {
        // Value is usually on the next line, or after a colon/slash on the same line
        final inlineValue = _afterColon(l);
        surname = inlineValue.isNotEmpty ? inlineValue : _nextNonLabelLine(lines, i + 1);
      } else if (givenLabel.hasMatch(l)) {
        final inlineValue = _afterColon(l);
        givenNames = inlineValue.isNotEmpty ? inlineValue : _nextNonLabelLine(lines, i + 1);
      }
    }

    if (surname != null && givenNames != null) {
      return '${_titleCase(givenNames)} ${_titleCase(surname)}'.trim();
    }
    if (surname != null) return _titleCase(surname);
    return '';
  }

  static String _afterColon(String line) {
    final idx = line.indexOf(RegExp(r'[:/]'));
    if (idx < 0) return '';
    return line.substring(idx + 1).trim();
  }

  static String _nextNonLabelLine(List<String> lines, int start) {
    final labelPattern = RegExp(
      r'^(surname|last\s*name|given|first\s*name|nationality|date|sex|place|country|issued|valid)',
      caseSensitive: false,
    );
    for (var i = start; i < lines.length && i < start + 3; i++) {
      final l = lines[i].trim();
      if (l.isNotEmpty && !labelPattern.hasMatch(l) && l.length > 1) return l;
    }
    return '';
  }

  // ── Issuing country ────────────────────────────────────────────────────────
  static String _extractIssuingCountry(String text) {
    final pattern = RegExp(
      r'(country\s*of\s*issue|issuing\s*(country|state|authority)|état\s*délivrant)[^\w]*([A-Z]{2,40})',
      caseSensitive: false,
    );
    final m = pattern.firstMatch(text);
    if (m != null) return _titleCase(m.group(3) ?? '');
    return '';
  }

  // ── Generic date by label ─────────────────────────────────────────────────
  static String _extractDateByLabel(String text, RegExp labelPattern) {
    final labelIdx = labelPattern.firstMatch(text)?.end;
    if (labelIdx == null) return '';
    final snippet = text.substring(labelIdx, (labelIdx + 80).clamp(0, text.length));
    return _findDate(snippet);
  }

  static String _findDate(String snippet) {
    // DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
    final numeric = RegExp(r'(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{4})');
    var m = numeric.firstMatch(snippet);
    if (m != null) {
      final dd = m.group(1)!.padLeft(2, '0');
      final mm = m.group(2)!.padLeft(2, '0');
      final yyyy = m.group(3)!;
      return '$yyyy-$mm-$dd';
    }
    // Month name: DD Month YYYY or Month DD, YYYY
    final monthNames = 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|'
        'January|February|March|April|May|June|July|August|September|October|November|December';
    final textual = RegExp(
      r'(\d{1,2})\s+(' + monthNames + r')\s+(\d{4})',
      caseSensitive: false,
    );
    m = textual.firstMatch(snippet);
    if (m != null) {
      final dd = m.group(1)!.padLeft(2, '0');
      final mon = _monthNum(m.group(2)!);
      final yyyy = m.group(3)!;
      return '$yyyy-$mon-$dd';
    }
    return '';
  }

  static String _monthNum(String name) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    final idx = months.indexWhere((m) => name.toLowerCase().startsWith(m));
    return (idx + 1).toString().padLeft(2, '0');
  }

  // ── Place of birth ────────────────────────────────────────────────────────
  static String _extractByLabel(String text, RegExp labelPattern) {
    final m = labelPattern.firstMatch(text);
    if (m == null) return '';
    final snippet = text.substring(m.end, (m.end + 80).clamp(0, text.length));
    final valuePattern = RegExp(r'[:\s]+([A-Za-z\s,]+)');
    final vm = valuePattern.firstMatch(snippet);
    return vm != null ? vm.group(1)!.trim() : '';
  }

  // ── Utilities ─────────────────────────────────────────────────────────────
  static String _titleCase(String s) => s
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class FullPageData {
  const FullPageData({
    this.fullName = '',
    this.issuingCountry = '',
    this.dateOfIssue = '',
    this.placeOfBirth = '',
  });

  final String fullName;
  final String issuingCountry;
  final String dateOfIssue;
  final String placeOfBirth;

  bool get hasAnyData =>
      fullName.isNotEmpty ||
      issuingCountry.isNotEmpty;
}
