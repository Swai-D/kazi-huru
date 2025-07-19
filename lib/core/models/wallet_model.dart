class WalletModel {
  final String userId;
  final double balance;
  final List<TransactionModel> transactions;
  final List<PaymentMethodModel> paymentMethods;

  WalletModel({
    required this.userId,
    required this.balance,
    required this.transactions,
    required this.paymentMethods,
  });

  factory WalletModel.defaultWallet(String userId) {
    return WalletModel(
      userId: userId,
      balance: 5000.0, // Default TZS 5,000
      transactions: [],
      paymentMethods: [
        PaymentMethodModel(
          id: 'mpesa',
          name: 'M-Pesa',
          type: PaymentType.mobileMoney,
          isActive: true,
        ),
        PaymentMethodModel(
          id: 'tigopesa',
          name: 'Tigo Pesa',
          type: PaymentType.mobileMoney,
          isActive: true,
        ),
        PaymentMethodModel(
          id: 'airtel',
          name: 'Airtel Money',
          type: PaymentType.mobileMoney,
          isActive: true,
        ),
        PaymentMethodModel(
          id: 'bank',
          name: 'Bank Transfer',
          type: PaymentType.bank,
          isActive: true,
        ),
      ],
    );
  }

  WalletModel copyWith({
    String? userId,
    double? balance,
    List<TransactionModel>? transactions,
    List<PaymentMethodModel>? paymentMethods,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toJson()).toList(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'],
      balance: json['balance']?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List?)
          ?.map((t) => TransactionModel.fromJson(t))
          .toList() ?? [],
      paymentMethods: (json['paymentMethods'] as List?)
          ?.map((p) => PaymentMethodModel.fromJson(p))
          .toList() ?? [],
    );
  }
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? reference;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
    this.reference,
  });

  factory TransactionModel.applicationFee({
    required String userId,
    required String jobTitle,
    required String jobId,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: -500.0, // TZS 500 application fee
      type: TransactionType.applicationFee,
      description: 'Application fee for: $jobTitle',
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      reference: jobId,
    );
  }

  factory TransactionModel.topUp({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? reference,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      type: TransactionType.topUp,
      description: 'Top up via $paymentMethod',
      timestamp: DateTime.now(),
      status: TransactionStatus.pending,
      reference: reference,
    );
  }

  factory TransactionModel.bonus({
    required String userId,
    required double amount,
    required String reason,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      type: TransactionType.bonus,
      description: 'Bonus: $reason',
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'reference': reference,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.other,
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      reference: json['reference'],
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String name;
  final PaymentType type;
  final bool isActive;
  final String? accountNumber;
  final String? accountName;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    this.accountNumber,
    this.accountName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'isActive': isActive,
      'accountNumber': accountNumber,
      'accountName': accountName,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      name: json['name'],
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentType.mobileMoney,
      ),
      isActive: json['isActive'] ?? true,
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
    );
  }
}

enum TransactionType {
  topUp,
  applicationFee,
  bonus,
  refund,
  other,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentType {
  mobileMoney,
  bank,
  card,
} 