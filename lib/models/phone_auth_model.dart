class PhoneAuthModel {
  final String phoneNumber;
  final String? verificationId;
  final bool isVerified;
  final DateTime? verifiedAt;

  PhoneAuthModel({
    required this.phoneNumber,
    this.verificationId,
    this.isVerified = false,
    this.verifiedAt,
  });

  // تحويل من Map إلى Object
  factory PhoneAuthModel.fromMap(Map<String, dynamic> map) {
    return PhoneAuthModel(
      phoneNumber: map['phoneNumber'] ?? '',
      verificationId: map['verificationId'],
      isVerified: map['isVerified'] ?? false,
      verifiedAt: map['verifiedAt']?.toDate(),
    );
  }

  // تحويل من Object إلى Map
  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'verificationId': verificationId,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt,
    };
  }

  // نسخ مع تعديل
  PhoneAuthModel copyWith({
    String? phoneNumber,
    String? verificationId,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return PhoneAuthModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}