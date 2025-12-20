import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSharingPage extends StatefulWidget {
  @override
  State<PaymentSharingPage> createState() => _PaymentSharingPageState();
}

class _PaymentSharingPageState extends State<PaymentSharingPage>
    with SingleTickerProviderStateMixin {

  static const Color primaryColor = Color(0xFF1F0F46);
  static const Color secondaryColor = Color(0xFF8A005D);
  static const Color lightBgColor = Color(0xFFF8F3FF);
  static const Color darkTextColor = Color(0xFF2D1B5A);

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List<Map<String, dynamic>> invoices = [];
  bool newestFirst = true;
  bool showCode = false;
  bool isLoading = true;

  String userId = '';
  String paymentCode = '';
  String invoiceId = '';
  DateTime invoiceDate = DateTime.now();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _init();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _slideAnim = Tween(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(_fadeAnim);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    
    if (prefs.containsKey('permanentUserId')) {
      userId = prefs.getString('permanentUserId')!;
    } else {
      final storedNumber = prefs.getInt('userCounter') ?? 0;
      final newNumber = storedNumber + 1;
      userId = 'PAY${newNumber.toString().padLeft(6, '0')}';
      await prefs.setInt('userCounter', newNumber);
      await prefs.setString('permanentUserId', userId);
    }

 
    final stored = prefs.getStringList('invoices') ?? [];
    invoices =
        stored.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();

    _sortInvoices();
    _generateInvoiceId();

    setState(() => isLoading = false);
  }

  void _generateInvoiceId() {
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    invoiceId = 'INV-${t.substring(t.length - 8)}';
    invoiceDate = DateTime.now();
  }

  void _sortInvoices() {
    invoices.sort((a, b) {
      final da = DateTime.parse(a['date']);
      final db = DateTime.parse(b['date']);
      return newestFirst ? db.compareTo(da) : da.compareTo(db);
    });
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'invoices',
      invoices.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> _generateCode() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    paymentCode =
        '${userId}_${amount.toStringAsFixed(2)}_${DateTime.now().millisecondsSinceEpoch}';

    final invoice = {
      'id': invoiceId,
      'amount': amount.toStringAsFixed(2),
      'description': descriptionController.text.isEmpty
          ? 'Payment Request'
          : descriptionController.text,
      'date': invoiceDate.toIso8601String(),
      'status': 'Pending',
      'payment_code': paymentCode, 
      'user_id': userId, 
    };

    setState(() {
      invoices.add(invoice);
      _sortInvoices();
      showCode = true;
    });

    await _saveInvoices();
    _animController.forward(from: 0);

    amountController.clear();
    descriptionController.clear();
    _generateInvoiceId();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: lightBgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Create Payment Request',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _requestCard(),
            const SizedBox(height: 20),
            if (showCode)
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _codeCard(),
                ),
              ),
            const SizedBox(height: 24),
            if (invoices.isNotEmpty) _invoicesList(),
           
            _userInfoCard(),
          ],
        ),
      ),
    );
  }

  

  Widget _requestCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('New Payment Request'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Invoice: $invoiceId',
              style: const TextStyle(fontSize: 12, color: primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Generate Payment Code'),
          ),
        ],
      ),
    );
  }

  Widget _codeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.payment, color: Color(0xFF4CAF50), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Your Payment Code:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              paymentCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, size: 28),
                color: secondaryColor,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: paymentCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment code copied to clipboard!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.share, size: 28),
                color: secondaryColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing payment code...'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoicesList() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title('Previous Invoices'),
              IconButton(
                icon: Icon(
                  newestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                  color: secondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    newestFirst = !newestFirst;
                    _sortInvoices();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var inv in invoices)
            Dismissible(
              key: Key(inv['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Invoice'),
                    content: const Text('Are you sure you want to delete this invoice?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                setState(() => invoices.remove(inv));
                _saveInvoices();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: InkWell(
                onTap: () => _showInvoiceDetails(inv),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${inv['amount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: secondaryColor,
                            ),
                          ),
                          Text(
                            inv['description'].toString().length > 20
                                ? '${inv['description'].toString().substring(0, 20)}...'
                                : inv['description'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: darkTextColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          inv['status'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: inv['status'] == 'Paid'
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        side: BorderSide.none,
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _userInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your ID:',
                    style: TextStyle(fontSize: 12, color: darkTextColor),
                  ),
                  Text(
                    userId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Invoices:',
                style: TextStyle(fontSize: 12, color: darkTextColor),
              ),
              Text(
                '0', 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showInvoiceDetails(Map<String, dynamic> inv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Invoice Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _detail('Invoice ID', inv['id']),
              _detail('Amount', '\$${inv['amount']}'),
              _detail('Date', _formatDate(inv['date'])),
              _detail('Description', inv['description']),
              _detail('Payment Code', inv['payment_code'] ?? 'N/A'),
              _detail('Status', inv['status']),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          inv['status'] =
                              inv['status'] == 'Pending' ? 'Paid' : 'Pending';
                        });
                        _saveInvoices();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invoice marked as ${inv['status']}'),
                            backgroundColor: inv['status'] == 'Paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                      ),
                      child: Text(
                        inv['status'] == 'Pending'
                            ? 'Mark as Paid'
                            : 'Mark as Pending',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style:  TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _title(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextColor,
        ),
      );

  @override
  void dispose() {
    _animController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
