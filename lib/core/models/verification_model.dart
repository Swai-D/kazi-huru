enum VerificationStatus {
  pending,
  verified,
  rejected,
  notSubmitted,
}

class VerificationModel {
  final String userId;
  final String? idImageUrl;
  final String? idNumber;
  final String? fullName;
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  VerificationModel({
    required this.userId,
    this.idImageUrl,
    this.idNumber,
    this.fullName,
    this.status = VerificationStatus.notSubmitted,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      userId: json['userId'] ?? '',
      idImageUrl: json['idImageUrl'],
      idNumber: json['idNumber'],
      fullName: json['fullName'],
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${json['status']}',
        orElse: () => VerificationStatus.notSubmitted,
      ),
      rejectionReason: json['rejectionReason'],
      submittedAt: json['submittedAt'] != null 
          ? DateTime.parse(json['submittedAt']) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      verifiedBy: json['verifiedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'idImageUrl': idImageUrl,
      'idNumber': idNumber,
      'fullName': fullName,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
    };
  }

  VerificationModel copyWith({
    String? userId,
    String? idImageUrl,
    String? idNumber,
    String? fullName,
    VerificationStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return VerificationModel(
      userId: userId ?? this.userId,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      idNumber: idNumber ?? this.idNumber,
      fullName: fullName ?? this.fullName,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }
} 