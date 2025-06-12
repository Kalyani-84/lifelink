class Hospital {
  final String userId;
  final String hospitalName;
  final String location; // You can store this as a string or Geography
  final String licenseNumber;
  final bool isVerified;

  Hospital({
    required this.userId,
    required this.hospitalName,
    required this.location,
    required this.licenseNumber,
    required this.isVerified,
  });

  factory Hospital.fromMap(Map<String, dynamic> data) {
    return Hospital(
      userId: data['user_id'],
      hospitalName: data['hospital_name'],
      location: data['location'],
      licenseNumber: data['license_number'],
      isVerified: data['is_verified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'hospital_name': hospitalName,
      'location': location,
      'license_number': licenseNumber,
      'is_verified': isVerified,
    };
  }
}