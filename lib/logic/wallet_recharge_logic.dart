
class WalletRechargeLogic {
 
  static const double minRechargeAmount = 10.0;
  static const double maxRechargeAmount = 1000000.0;
  static const double defaultBalance = 1250.75;

 
  static List<Map<String, dynamic>> quickAmounts = [
    {'amount': '50', 'icon': 'attach_money', 'color': 'primary'},
    {'amount': '100', 'icon': 'money', 'color': 'purple'},
    {'amount': '200', 'icon': 'account_balance_wallet', 'color': 'deep_purple'},
    {'amount': '500', 'icon': 'savings', 'color': 'indigo'},
    {'amount': '1000', 'icon': 'diamond', 'color': 'dark_purple'},
  ];

 
  static List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'credit_card',
      'name': 'Credit/Debit Card',
      'description': 'Visa, MasterCard, American Express',
      'icon': 'credit_card',
    },
    {
      'id': 'efawateercom',
      'name': 'eFawateercom',
      'description': 'Digital wallet payment',
      'icon': 'account_balance_wallet',
    },
  ];

  
  static List<String> importantInfo = [
    'Minimum recharge amount: \$10',
    'No transaction fees',
    'Funds available instantly',
    '24/7 customer support',
  ];

  
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount < minRechargeAmount) {
      return 'Minimum amount is \$$minRechargeAmount';
    }

    if (amount > maxRechargeAmount) {
      return 'Maximum amount is \$$maxRechargeAmount';
    }

    return null;
  }

  static String? validatePaymentMethod(String? method) {
    if (method == null || method.isEmpty) {
      return 'Please select a payment method';
    }

    final validMethods = paymentMethods.map((m) => m['id']).toList();
    if (!validMethods.contains(method)) {
      return 'Please select a valid payment method';
    }

    return null;
  }

  static bool canProceedToPayment(String? amount, String? method) {
    if (amount == null || amount.isEmpty) return false;
    if (method == null || method.isEmpty) return false;

    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) return false;

    return parsedAmount >= minRechargeAmount && parsedAmount <= maxRechargeAmount;
  }

  static double parseAmount(String amountStr) {
    return double.tryParse(amountStr) ?? 0.0;
  }

  static double calculateNewBalance(double currentBalance, double rechargeAmount) {
    return currentBalance + rechargeAmount;
  }

  static String formatBalance(double balance) {
    return balance.toStringAsFixed(2);
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  static double calculateTax(double amount, double taxRate) {
    return amount * taxRate;
  }

  static double calculateTotalAmount(double amount, double taxRate) {
    final tax = calculateTax(amount, taxRate);
    return amount + tax;
  }

  static Map<String, dynamic> getPaymentMethodInfo(String methodId) {
    return paymentMethods.firstWhere(
      (method) => method['id'] == methodId,
      orElse: () => paymentMethods[0],
    );
  }

  static bool isCreditCardPayment(String methodId) {
    return methodId == 'credit_card';
  }

  static bool isEfawateercomPayment(String methodId) {
    return methodId == 'efawateercom';
  }

  static Map<String, String> getBalanceStats(double currentBalance) {
    return {
      'today': '+ \$25.50',
      'thisWeek': '+ \$350.25',
      'lastMonth': '+ \$1,200.00',
    };
  }

  static String getQuickAmountIcon(String iconName) {
    switch (iconName) {
      case 'attach_money':
        return 'attach_money';
      case 'money':
        return 'money';
      case 'account_balance_wallet':
        return 'account_balance_wallet';
      case 'savings':
        return 'savings';
      case 'diamond':
        return 'diamond';
      default:
        return 'attach_money';
    }
  }

  static String getQuickAmountColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return '#8A005D';
      case 'purple':
        return '#9C27B0';
      case 'deep_purple':
        return '#673AB7';
      case 'indigo':
        return '#3F51B5';
      case 'dark_purple':
        return '#1F0F46';
      default:
        return '#8A005D';
    }
  }

  static bool isValidDouble(String value) {
    return double.tryParse(value) != null;
  }

  static String generateTransactionId() {
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}'.substring(5);
    return 'RECH${id.substring(0, 6)}';
  }

  static Map<String, dynamic> createRechargeRecord({
    required double amount,
    required String method,
    required String transactionId,
  }) {
    final now = DateTime.now();
    return {
      'id': transactionId,
      'type': 'deposit',
      'amount': amount,
      'method': method,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'status': 'Pending',
    };
  }

  static bool isAmountSecure(double amount) {
   
    return amount >= minRechargeAmount && amount <= maxRechargeAmount;
  }

  static bool isPaymentMethodSecure(String methodId) {
    final secureMethods = ['credit_card', 'efawateercom'];
    return secureMethods.contains(methodId);
  }

  static Map<String, String> getErrorMessages() {
    return {
      'empty_amount': 'Please enter amount',
      'invalid_amount': 'Please enter a valid number',
      'zero_amount': 'Amount must be greater than 0',
      'min_amount': 'Minimum amount is \$$minRechargeAmount',
      'max_amount': 'Maximum amount is \$$maxRechargeAmount',
      'empty_method': 'Please select a payment method',
      'invalid_method': 'Please select a valid payment method',
    };
  }

  static String getErrorMessage(String errorCode) {
    final errors = getErrorMessages();
    return errors[errorCode] ?? 'An error occurred';
  }
}
