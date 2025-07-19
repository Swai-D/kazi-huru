import '../models/wallet_model.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // Mock wallet data - in real app this would come from Firebase
  WalletModel _currentWallet = WalletModel.defaultWallet('user123');

  // Get current wallet
  WalletModel get currentWallet => _currentWallet;

  // Get current balance
  double get currentBalance => _currentWallet.balance;

  // Check if user has enough balance for application fee
  bool hasEnoughBalanceForApplication() {
    return _currentWallet.balance >= 500.0; // TZS 500 application fee
  }

  // Deduct application fee
  bool deductApplicationFee(String jobTitle, String jobId) {
    if (!hasEnoughBalanceForApplication()) {
      return false;
    }

    final transaction = TransactionModel.applicationFee(
      userId: _currentWallet.userId,
      jobTitle: jobTitle,
      jobId: jobId,
    );

    _currentWallet = _currentWallet.copyWith(
      balance: _currentWallet.balance + transaction.amount, // amount is negative
      transactions: [..._currentWallet.transactions, transaction],
    );

    return true;
  }

  // Add money to wallet (top up)
  bool topUpWallet(double amount, String paymentMethod, {String? reference}) {
    if (amount <= 0) return false;

    final transaction = TransactionModel.topUp(
      userId: _currentWallet.userId,
      amount: amount,
      paymentMethod: paymentMethod,
      reference: reference,
    );

    _currentWallet = _currentWallet.copyWith(
      balance: _currentWallet.balance + amount,
      transactions: [..._currentWallet.transactions, transaction],
    );

    return true;
  }

  // Add bonus to wallet
  void addBonus(double amount, String reason) {
    final transaction = TransactionModel.bonus(
      userId: _currentWallet.userId,
      amount: amount,
      reason: reason,
    );

    _currentWallet = _currentWallet.copyWith(
      balance: _currentWallet.balance + amount,
      transactions: [..._currentWallet.transactions, transaction],
    );
  }

  // Get recent transactions
  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final sortedTransactions = List<TransactionModel>.from(_currentWallet.transactions);
    sortedTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedTransactions.take(limit).toList();
  }

  // Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _currentWallet.transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }

  // Get available payment methods
  List<PaymentMethodModel> getAvailablePaymentMethods() {
    return _currentWallet.paymentMethods
        .where((method) => method.isActive)
        .toList();
  }

  // Process payment (mock implementation)
  Future<bool> processPayment({
    required double amount,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock payment processing
    // In real app, this would integrate with M-Pesa, Tigo Pesa, etc.
    final success = _mockPaymentProcessing(amount, paymentMethod, phoneNumber);

    if (success) {
      return topUpWallet(amount, paymentMethod);
    }

    return false;
  }

  // Mock payment processing
  bool _mockPaymentProcessing(double amount, String paymentMethod, String phoneNumber) {
    // Simulate 90% success rate
    return DateTime.now().millisecondsSinceEpoch % 10 != 0;
  }

  // Get transaction statistics
  Map<String, dynamic> getTransactionStats() {
    final transactions = _currentWallet.transactions;
    final totalTopUps = transactions
        .where((t) => t.type == TransactionType.topUp && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalApplicationFees = transactions
        .where((t) => t.type == TransactionType.applicationFee)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalBonuses = transactions
        .where((t) => t.type == TransactionType.bonus)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'totalTopUps': totalTopUps,
      'totalApplicationFees': totalApplicationFees,
      'totalBonuses': totalBonuses,
      'totalTransactions': transactions.length,
    };
  }

  // Reset wallet to default (for testing)
  void resetWallet() {
    _currentWallet = WalletModel.defaultWallet('user123');
  }
} 