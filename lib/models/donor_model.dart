class Donor {
  final String userId;
  final String bloodType;
  final DateTime lastDonation;
  final String location; // You may store it as a String or Geography type as needed
  final double availabilityScore;
  final bool isVerified;

  Donor({
    required this.userId,
    required this.bloodType,
    required this.lastDonation,
    required this.location,
    required this.availabilityScore,
    required this.isVerified,
  });

  factory Donor.fromMap(Map<String, dynamic> data) {
    return Donor(
      userId: data['user_id'],
      bloodType: data['blood_type'],
      lastDonation: DateTime.parse(data['last_donation']),
      location: data['location'],
      availabilityScore: data['availability_score'].toDouble(),
      isVerified: data['is_verified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'blood_type': bloodType,
      'last_donation': lastDonation.toIso8601String(),
      'location': location,
      'availability_score': availabilityScore,
      'is_verified': isVerified,
    };
  }
}