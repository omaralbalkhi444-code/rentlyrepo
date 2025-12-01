import 'package:flutter/material.dart';
import 'package:p2/Payment2.dart';

class WithdrawalService {
  List<Map<String, String>> withdrawals = [];

  
  String? validateAndSave({
    required String balanceText,
    required String amountText,
    required String name,
    required String bank,
    required String iban,
  }) {
    if (balanceText.isEmpty ||
        amountText.isEmpty ||
        name.isEmpty ||
        bank.isEmpty ||
        iban.isEmpty) {
      return "Please fill all fields";
    }

    double? balance = double.tryParse(balanceText);
    double? amount = double.tryParse(amountText);

    if (balance == null || balance < 0) return "Enter a valid balance";
    if (amount == null || amount <= 0) return "Enter a valid withdrawal amount";
    if (amount > balance) return "Withdrawal amount exceeds available balance";

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) return "Name must contain letters only";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(bank)) return "Bank name must contain letters only";
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(iban) || iban.length < 15) return "Enter a valid IBAN (min 15 characters)";

    withdrawals.add({
      'balance': balance.toString(),
      'amount': amount.toString(),
      'name': name,
      'bank': bank,
      'iban': iban,
      'timestamp': DateTime.now().toString(),
    });

    return null;
  }
}

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();

  bool isWithdrawPressed = false;

  final WithdrawalService withdrawalService = WithdrawalService();

  void saveWithdrawal() {
    String? error = withdrawalService.validateAndSave(
      balanceText: balanceController.text,
      amountText: amountController.text,
      name: nameController.text,
      bank: bankController.text,
      iban: ibanController.text,
    );

    if (error != null) {
      showError(error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Withdrawal successful (fake backend)"),
        duration: Duration(seconds: 2),
      ),
    );

    print("Fake Withdrawals: ${withdrawalService.withdrawals}");

    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CardPaymentPage()),
    );
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text("Withdraw", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildBalanceInput(),
            const SizedBox(height: 30),
            _buildWithdrawalForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Total Balance",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          TextField(
            controller: balanceController,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Balance",
              hintStyle: TextStyle(color: Colors.white70),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Withdraw Amount", amountController,
                  keyboard: TextInputType.number),
              const SizedBox(height: 20),
              const Text(
                "Bank account information for Withdraw",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField("Account Holder Name", nameController),
              const SizedBox(height: 20),
              _buildTextField("Select The Bank", bankController),
              const SizedBox(height: 20),
              _buildTextField("IBAN", ibanController),
              const SizedBox(height: 30),
              _buildWithdrawButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => isWithdrawPressed = true),
      onTapUp: (_) {
        setState(() => isWithdrawPressed = false);
        saveWithdrawal();
      },
      onTapCancel: () => setState(() => isWithdrawPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: isWithdrawPressed
            ? Matrix4.translationValues(0, 3, 0)
            : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "Withdraw",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

