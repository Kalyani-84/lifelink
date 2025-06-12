class BloodBank {
  final String userId;
  final String bankName;
  final String location; // You can store this as a string or Geography
  final String licenseNumber;
  final bool isVerified;

  BloodBank({
    required this.userId,
    required this.bankName,
    required this.location,
    required this.licenseNumber,
    required this.isVerified,
  });

  factory BloodBank.fromMap(Map<String, dynamic> data) {
    return BloodBank(
      userId: data['user_id'],
      bankName: data['bank_name'],
      location: data['location'],
      licenseNumber: data['license_number'],
      isVerified: data['is_verified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'bank_name': bankName,
      'location': location,
      'license_number': licenseNumber,
      'is_verified': isVerified,
    };
  }
}