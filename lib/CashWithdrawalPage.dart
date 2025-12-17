import 'package:flutter/material.dart';

class CashWithdrawalPage extends StatefulWidget {
  const CashWithdrawalPage({super.key});

  @override
  State<CashWithdrawalPage> createState() => _CashWithdrawalPageState();
}

class _CashWithdrawalPageState extends State<CashWithdrawalPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  double currentBalance = 1250.75;
  DateTime? selectedBirthDate;
  bool _showErrors = false;

  
  final List<Map<String, dynamic>> quickAmounts = [
    {'amount': '50', 'icon': Icons.attach_money, 'color': Color(0xFF8A005D)},
    {'amount': '100', 'icon': Icons.money, 'color': Color(0xFF9C27B0)},
    {'amount': '200', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF673AB7)},
    {'amount': '500', 'icon': Icons.savings, 'color': Color(0xFF3F51B5)},
    {'amount': '1000', 'icon': Icons.diamond, 'color': Color(0xFF1F0F46)},
  ];
  String? _amountError;
  String? _fullNameError;
  String? _nationalIdError;
  String? _birthDateError;
  String? _phoneError;

  void _updateAmountError() {
    setState(() {
      _amountError = validateAmount(amountController.text);
    });
  }

  void _updateFullNameError() {
    setState(() {
      _fullNameError = validateFullName(fullNameController.text);
    });
  }

  void _updateNationalIdError() {
    setState(() {
      _nationalIdError = validateNationalID(nationalIdController.text);
    });
  }

  void _updateBirthDateError() {
    setState(() {
      _birthDateError = validateBirthDate(birthDateController.text);
    });
  }

  void _updatePhoneError() {
    setState(() {
      _phoneError = validatePhoneNumber(phoneController.text);
    });
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter valid amount';
    }
    
    if (amount < 10) {
      return 'Minimum withdrawal is \$10';
    }
    
    if (amount > currentBalance) {
      return 'Amount exceeds balance';
    }
    
    if (amount > 1000) {
      return 'Daily limit is \$1,000';
    }
    
    final decimalPart = value.split('.');
    if (decimalPart.length > 1 && decimalPart[1].length > 2) {
      return 'Maximum 2 decimal places';
    }
    
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter full name';
    }
    
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Name is too long';
    }
    
    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value)) {
      return 'Name must contain only letters and spaces';
    }
    
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.length < 2) {
      return 'Please enter first and last name';
    }
    
    for (final word in words) {
      if (word.length < 2) {
        return 'Each name part must be at least 2 characters';
      }
    }
    
    return null;
  }

  String? validateNationalID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter national ID';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'National ID must contain only digits';
    }
    
    if (value.length != 10) {
      return 'National ID must be 10 digits';
    }
    
    return null;
  }

  String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter date of birth';
    }
    
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Format: DD/MM/YYYY';
    }
    
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      if (day < 1 || day > 31) {
        return 'Invalid day';
      }
      
      if (month < 1 || month > 12) {
        return 'Invalid month';
      }
      
      if (year < 1900 || year > DateTime.now().year) {
        return 'Invalid year';
      }
      
      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      
      if (age < 18) {
        return 'Must be 18 years or older';
      }
      
      if (age > 120) {
        return 'Please enter valid birth date';
      }
      
    } catch (e) {
      return 'Invalid date format';
    }
    
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanedPhone.length != 10) {
      return 'Phone must be 10 digits';
    }
    
    if (cleanedPhone[0] != '0') {
      return 'Must start with 0';
    }
    
    if (cleanedPhone[1] != '7') {
      return 'Second digit must be 7';
    }
    
    final thirdDigit = cleanedPhone[2];
    if (thirdDigit != '7' && thirdDigit != '8' && thirdDigit != '9') {
      return 'Third digit must be 7, 8 or 9';
    }
    
    return null;
  }

  @override
  void initState() {
    super.initState();
    
    amountController.addListener(_updateAmountError);
    fullNameController.addListener(_updateFullNameError);
    nationalIdController.addListener(_updateNationalIdError);
    birthDateController.addListener(_updateBirthDateError);
    phoneController.addListener(_updatePhoneError);
  }

  @override
  void dispose() {
    amountController.removeListener(_updateAmountError);
    fullNameController.removeListener(_updateFullNameError);
    nationalIdController.removeListener(_updateNationalIdError);
    birthDateController.removeListener(_updateBirthDateError);
    phoneController.removeListener(_updatePhoneError);
    super.dispose();
  }

  Future<void> selectBirthDate() async {
    final initialDate = selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18));
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8A005D),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
        birthDateController.text = '${pickedDate.day.toString().padLeft(2, '0')}/'
                                 '${pickedDate.month.toString().padLeft(2, '0')}/'
                                 '${pickedDate.year}';
        _updateBirthDateError();
      });
    }
  }

  void onQuickAmountSelected(String amount) {
    setState(() {
      amountController.text = amount;
      _updateAmountError();
    });
  }

  void _validateAndShowErrors() {
    setState(() {
      _showErrors = true;
      _updateAmountError();
      _updateFullNameError();
      _updateNationalIdError();
      _updateBirthDateError();
      _updatePhoneError();
    });
    
    final hasErrors = _amountError != null || 
                     _fullNameError != null || 
                     _nationalIdError != null || 
                     _birthDateError != null || 
                     _phoneError != null;
    
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in all required fields correctly',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Withdrawal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A005D).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AVAILABLE BALANCE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBalanceStat('Daily Limit', '\$1,000.00'),
                        _buildBalanceStat('Weekly Limit', '\$5,000.00'),
                        _buildBalanceStat('Monthly Limit', '\$20,000.00'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.money_off, color: Color(0xFF8A005D)),
                        SizedBox(width: 10),
                        Text(
                          'Withdrawal Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F0F46),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1),

                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F0F46),
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 28,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w700,
                            ),
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF8A005D),
                              size: 28,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            suffixText: 'USD',
                            suffixStyle: const TextStyle(
                              color: Color(0xFF8A005D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_showErrors && _amountError != null)
                          _buildErrorText(_amountError!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Quick Amounts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: quickAmounts.map((item) {
                        return GestureDetector(
                          onTap: () => onQuickAmountSelected(item['amount']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (item['color'] as Color).withOpacity(0.9),
                                  (item['color'] as Color).withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: (item['color'] as Color).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${item['amount']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_outline, color: Color(0xFF8A005D)),
                        SizedBox(width: 10),
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F0F46),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1),

                    const SizedBox(height: 20),
                    _buildFormFieldWithError(
                      'Full Name *',
                      fullNameController,
                      Icons.person,
                      _fullNameError,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 15),
                    _buildFormFieldWithError(
                      'National ID Number *',
                      nationalIdController,
                      Icons.credit_card,
                      _nationalIdError,
                      TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: selectBirthDate,
                      child: AbsorbPointer(
                        child: _buildFormFieldWithError(
                          'Date of Birth *',
                          birthDateController,
                          Icons.calendar_today,
                          _birthDateError,
                          TextInputType.text,
                          hint: 'DD/MM/YYYY',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildPhoneNumberFieldWithError(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'How to Withdraw Cash',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F0F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInstructionStep(1, 'Complete the form above'),
                  _buildInstructionStep(2, 'Generate your withdrawal code'),
                  _buildInstructionStep(3, 'Visit any exchange office'),
                  _buildInstructionStep(4, 'Show your ID and withdrawal code'),
                  _buildInstructionStep(5, 'Receive cash instantly'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildImportantInfo('Minimum withdrawal: \$10'),
                  _buildImportantInfo('Maximum withdrawal per day: \$1,000'),
                  _buildImportantInfo('Processing Time: 1-3 business days'),
                  _buildImportantInfo('Valid ID required for collection'),
                  _buildImportantInfo('Withdrawal code expires in 7 days'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            
            if (_showErrors && (
              _amountError != null || 
              _fullNameError != null || 
              _nationalIdError != null || 
              _birthDateError != null || 
              _phoneError != null
            ))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[800], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please fill in all required fields correctly',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A005D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _processWithdrawal,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Generate Withdrawal Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F0F46),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildContactInfo('Customer Support: +962 123 456 789'),
                  _buildContactInfo('Email: support@rently.com'),
                  _buildContactInfo('Working Hours: 9 AM - 5 PM'),
                  _buildContactInfo('Emergency: 24/7 hotline available'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldWithError(
    String label,
    TextEditingController controller,
    IconData icon,
    String? error,
    TextInputType keyboardType, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? label,
            prefixIcon: Icon(icon, color: const Color(0xFF8A005D)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
        if (_showErrors && error != null)
          _buildErrorText(error),
      ],
    );
  }

  Widget _buildPhoneNumberFieldWithError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '77 123 4567',
            prefixIcon: const Icon(
              Icons.phone,
              color: Color(0xFF8A005D),
            ),
            prefixText: '+962 ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_showErrors && _phoneError != null)
          _buildErrorText(_phoneError!),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Format: 077, 078, or 079 followed by 7 digits',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[800],
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBalanceStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildImportantInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildContactInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ],
      )
    );
  }

  void _processWithdrawal() {
    _validateAndShowErrors();
    
    final hasErrors = _amountError != null || 
                     _fullNameError != null || 
                     _nationalIdError != null || 
                     _birthDateError != null || 
                     _phoneError != null;
    
    if (hasErrors) {
      return;
    }
    
    _showWithdrawalCodeDialog();
  }

  void _showWithdrawalCodeDialog() {
    final withdrawalCode = 'RTL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final amount = amountController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Withdrawal Code Generated'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Code: $withdrawalCode',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F0F46),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Amount: \$$amount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Full Name: ${fullNameController.text}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Phone: ${phoneController.text}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: const Text(
                  'Present this code with your ID at any exchange office within 7 days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
