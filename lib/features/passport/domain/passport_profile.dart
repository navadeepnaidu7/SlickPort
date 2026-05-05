import 'dart:convert';
import 'dart:math';

String _generateId() {
  final rand = Random();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final suffix = rand.nextInt(99999).toString().padLeft(5, '0');
  return '$ts$suffix';
}

class PassportProfile {
  PassportProfile({
    String? id,
    required this.name,
    required this.passportNumber,
    required this.nationality,
    required this.dateOfBirth,
    required this.expiryDate,
    required this.imagePath,
    required this.mrzRaw,
    this.placeOfBirth = '',
    this.issueDate = '',
    this.issuingAuthority = '',
    this.gender = '',
    this.isEPassport = false,
  }) : id = id ?? _generateId();

  PassportProfile.empty()
      : id = _generateId(),
        name = '',
        passportNumber = '',
        nationality = '',
        dateOfBirth = '',
        expiryDate = '',
        imagePath = '',
        mrzRaw = '',
        placeOfBirth = '',
        issueDate = '',
        issuingAuthority = '',
        gender = '',
        isEPassport = false;

  final String id;
  final String name;
  final String passportNumber;
  final String nationality;
  final String dateOfBirth;
  final String expiryDate;
  final String imagePath;
  final String mrzRaw;
  final String placeOfBirth;
  final String issueDate;
  final String issuingAuthority;
  final String gender;
  final bool isEPassport;

  PassportProfile copyWith({
    String? id,
    String? name,
    String? passportNumber,
    String? nationality,
    String? dateOfBirth,
    String? expiryDate,
    String? imagePath,
    String? mrzRaw,
    String? placeOfBirth,
    String? issueDate,
    String? issuingAuthority,
    String? gender,
    bool? isEPassport,
  }) {
    return PassportProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      mrzRaw: mrzRaw ?? this.mrzRaw,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      issueDate: issueDate ?? this.issueDate,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      gender: gender ?? this.gender,
      isEPassport: isEPassport ?? this.isEPassport,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'passportNumber': passportNumber,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth,
      'expiryDate': expiryDate,
      'imagePath': imagePath,
      'mrzRaw': mrzRaw,
      'placeOfBirth': placeOfBirth,
      'issueDate': issueDate,
      'issuingAuthority': issuingAuthority,
      'gender': gender,
      'isEPassport': isEPassport,
    };
  }

  factory PassportProfile.fromMap(Map<String, dynamic> map) {
    return PassportProfile(
      id: map['id'] as String?,
      name: map['name'] ?? '',
      passportNumber: map['passportNumber'] ?? '',
      nationality: map['nationality'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      imagePath: map['imagePath'] ?? '',
      mrzRaw: map['mrzRaw'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      issueDate: map['issueDate'] ?? '',
      issuingAuthority: map['issuingAuthority'] ?? '',
      gender: map['gender'] ?? '',
      isEPassport: map['isEPassport'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PassportProfile.fromJson(String source) => PassportProfile.fromMap(json.decode(source));
}