import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/transaction.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:kisan_saathi/services/wallet_service.dart';
import 'package:kisan_saathi/widgets/transaction_item.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.income;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Start listening to transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletService = Provider.of<WalletService>(context, listen: false);
      walletService.listenToTransactions();
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    final walletService = Provider.of<WalletService>(context);
    
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isHindi ? 'किसान वॉलेट' : 'Farmer Wallet'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Balance Summary Card
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  isHindi ? 'वर्तमान बैलेंस' : 'Current Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTextColor.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(walletService.balance),
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        isHindi ? 'कुल आय' : 'Total Income',
                        walletService.totalIncome,
                        AppTheme.accentColor,
                        Icons.arrow_upward,
                        AppTheme.lightTextColor,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: AppTheme.lightTextColor.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        isHindi ? 'कुल व्यय' : 'Total Expense',
                        walletService.totalExpense,
                        AppTheme.secondaryGreen,
                        Icons.arrow_downward,
                        AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Transactions title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isHindi ? 'हाल के लेनदेन' : 'Recent Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to full transaction history
                    // Will be implemented later
                  },
                  icon: const Icon(Icons.history),
                  label: Text(
                    isHindi ? 'सभी देखें' : 'View All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions list
          Expanded(
            child: walletService.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  )
                : walletService.transactions.isEmpty
                    ? _buildEmptyState(isHindi)
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: walletService.transactions.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final transaction = walletService.transactions[index];
                            return TransactionItem(
                              transaction: transaction,
                              onDelete: (id) {
                                walletService.deleteTransaction(id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isHindi 
                                          ? 'लेनदेन हटा दिया गया' 
                                          : 'Transaction deleted',
                                      style: GoogleFonts.roboto(
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppTheme.surfaceColor,
                                    action: SnackBarAction(
                                      label: isHindi ? 'ठीक है' : 'OK',
                                      onPressed: () {},
                                      textColor: AppTheme.accentColor,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionModal(context),
        icon: const Icon(Icons.add),
        label: Text(isHindi ? 'लेनदेन जोड़ें' : 'Add Transaction'),
        tooltip: isHindi ? 'लेनदेन जोड़ें' : 'Add Transaction',
      ),
    );
  }
  
  Widget _buildEmptyState(bool isHindi) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 24),
            Text(
              isHindi ? 'कोई लेनदेन नहीं' : 'No Transactions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isHindi 
                    ? 'नया लेनदेन जोड़ने के लिए नीचे बटन दबाएं।' 
                    : 'Press the button below to add a new transaction.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppTheme.lightTextColor.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddTransactionModal(context),
              icon: const Icon(Icons.add),
              label: Text(isHindi ? 'पहला लेनदेन जोड़ें' : 'Add First Transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon, Color textColor) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          currencyFormat.format(amount),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  void _showAddTransactionModal(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    // Reset form fields
    _amountController.clear();
    _noteController.clear();
    _selectedType = TransactionType.income;
    _selectedDate = DateTime.now();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'नया लेनदेन जोड़ें' : 'Add New Transaction',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.lightTextColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: AppTheme.lightTextColor.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  
                  // Transaction Type Toggle
                  Text(
                    isHindi ? 'लेनदेन का प्रकार' : 'Transaction Type',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.income;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? AppTheme.accentColor
                                  : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedType == TransactionType.income 
                                    ? AppTheme.accentColor 
                                    : AppTheme.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: _selectedType == TransactionType.income
                                        ? AppTheme.textColor
                                        : AppTheme.lightTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isHindi ? 'आय' : 'Income',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedType == TransactionType.income
                                          ? AppTheme.textColor
                                          : AppTheme.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.expense;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? AppTheme.secondaryGreen
                                  : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedType == TransactionType.expense 
                                    ? AppTheme.secondaryGreen 
                                    : AppTheme.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    color: _selectedType == TransactionType.expense
                                        ? AppTheme.textColor
                                        : AppTheme.lightTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isHindi ? 'व्यय' : 'Expense',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedType == TransactionType.expense
                                          ? AppTheme.textColor
                                          : AppTheme.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Amount Field
                  Text(
                    isHindi ? 'राशि' : 'Amount',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTheme.getInputTextStyle(),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: GoogleFonts.roboto(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: isHindi ? 'राशि दर्ज करें' : 'Enter amount',
                      hintStyle: AppTheme.getInputHintStyle(),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.accentColor, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Note Field
                  Text(
                    isHindi ? 'नोट (वैकल्पिक)' : 'Note (Optional)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    style: AppTheme.getInputTextStyle(),
                    decoration: InputDecoration(
                      hintText: isHindi ? 'विवरण दर्ज करें' : 'Enter details',
                      hintStyle: AppTheme.getInputHintStyle(),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.accentColor, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Picker
                  Text(
                    isHindi ? 'दिनांक' : 'Date',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: AppTheme.accentColor,
                                onPrimary: Colors.black,
                                surface: AppTheme.surfaceColor,
                                onSurface: AppTheme.lightTextColor,
                              ),
                              dialogBackgroundColor: AppTheme.backgroundColor,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMMM, yyyy').format(_selectedDate),
                            style: GoogleFonts.roboto(
                              color: AppTheme.lightTextColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveTransaction(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isHindi ? 'लेनदेन सहेजें' : 'Save Transaction',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _saveTransaction(BuildContext context) {
    final walletService = Provider.of<WalletService>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    // Validate amount
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'कृपया राशि दर्ज करें' : 'Please enter an amount',
            style: GoogleFonts.roboto(color: AppTheme.lightTextColor),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'कृपया मान्य राशि दर्ज करें' : 'Please enter a valid amount',
            style: GoogleFonts.roboto(color: AppTheme.lightTextColor),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Create and save the transaction
    final transaction = WalletTransaction(
      amount: amount,
      type: _selectedType,
      note: _noteController.text.trim(),
      date: _selectedDate,
    );
    
    walletService.addTransaction(transaction);
    
    // Close the modal and show confirmation
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi ? 'लेनदेन सफलतापूर्वक जोड़ा गया' : 'Transaction added successfully',
          style: GoogleFonts.roboto(color: AppTheme.lightTextColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        action: SnackBarAction(
          label: isHindi ? 'ठीक है' : 'OK',
          onPressed: () {},
          textColor: AppTheme.accentColor,
        ),
      ),
    );
  }
} 