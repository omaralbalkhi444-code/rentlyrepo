class CashWithdrawalLogic {
  double currentBalance;

  CashWithdrawalLogic({required this.currentBalance});

  //  AMOUNT
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter valid amount';
    }

    if (amount < 10) {
      return 'Minimum withdrawal is 10 JD';
    }

    if (amount > currentBalance) {
      return 'Amount exceeds available balance';
    }

    if (amount > 1000) {
      return 'Daily limit is 1,000 JD';
    }

    final decimalPart = value.split('.');
    if (decimalPart.length > 1 && decimalPart[1].length > 2) {
      return 'Maximum 2 decimal places';
    }

    return null;
  }

  //  BANK WITHDRAWAL
  String? validateIBAN(String? value) {
    if (value == null || value.isEmpty) return 'Please enter IBAN';

    value = value.replaceAll(' ', '');

    if (value.length < 22 || value.length > 34) {
      return 'Invalid IBAN length';
    }

    return null;
  }

  String? validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter bank name';
    }

    if (value.length < 3) return 'Bank name too short';

    return null;
  }

  String? validateAccountHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account holder name';
    }

    if (value.trim().split(' ').length < 2) {
      return 'Please enter full name';
    }

    return null;
  }

  //  EXCHANGE WITHDRAWAL
  String? validatePickupName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter receiver name';
    }

    if (value.trim().split(' ').length < 2) {
      return 'Please enter full name';
    }

    return null;
  }

  String? validatePickupPhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';

    final phone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!phone.startsWith('07') || phone.length != 10) {
      return 'Invalid phone number';
    }

    return null;
  }

  String? validatePickupId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ID number';
    }

    if (value.length < 6) return 'Invalid ID number';

    return null;
  }

}
