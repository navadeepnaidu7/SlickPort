import 'package:flutter/material.dart';

import 'id_document.dart';

/// Display metadata for each supported ID document type.
/// Add new document types here to integrate them across the app.
class IdDocumentDescriptor {
  const IdDocumentDescriptor({
    required this.title,
    required this.shortLabel,
    required this.accentColor,
    required this.sheetIconColor,
  });

  final String title;
  final String shortLabel;
  final Color accentColor;
  final Color sheetIconColor;
}

class IdDocumentCatalog {
  const IdDocumentCatalog._();

  static const Map<IdDocumentType, IdDocumentDescriptor> descriptors = {
    IdDocumentType.pan: IdDocumentDescriptor(
      title: 'PAN Card',
      shortLabel: 'PAN',
      accentColor: Color(0xFFE8A020),
      sheetIconColor: Color(0xFFC6973F),
    ),
    IdDocumentType.aadhaar: IdDocumentDescriptor(
      title: 'Aadhaar Card',
      shortLabel: 'Aadhaar',
      accentColor: Color(0xFF34C759),
      sheetIconColor: Color(0xFF005EA6),
    ),
  };

  static IdDocumentDescriptor descriptorFor(IdDocumentType type) {
    return descriptors[type] ?? descriptors[IdDocumentType.pan]!;
  }

  static String titleFor(IdDocumentType type) => descriptorFor(type).title;

  static String shortLabelFor(IdDocumentType type) =>
      descriptorFor(type).shortLabel;
}