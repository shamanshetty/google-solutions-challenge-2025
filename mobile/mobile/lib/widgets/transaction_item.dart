import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/transaction.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionItem extends StatelessWidget {
  final WalletTransaction transaction;
  final Function(String) onDelete;
  
  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(transaction.id),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: transaction.isIncome 
                  ? AppTheme.accentColor.withOpacity(0.2) 
                  : AppTheme.secondaryGreen.withOpacity(0.2),
              child: Icon(
                transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: transaction.isIncome ? AppTheme.accentColor : AppTheme.secondaryGreen,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.note.isEmpty 
                        ? (transaction.isIncome 
                            ? (isHindi ? 'आय' : 'Income') 
                            : (isHindi ? 'व्यय' : 'Expense'))
                        : transaction.note,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTextColor,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(transaction.amount),
                  style: GoogleFonts.poppins(
                    color: transaction.isIncome ? AppTheme.accentColor : AppTheme.secondaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppTheme.lightTextColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(transaction.date),
                  style: GoogleFonts.roboto(
                    color: AppTheme.lightTextColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction.isIncome 
                        ? AppTheme.accentColor.withOpacity(0.2)
                        : AppTheme.secondaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.isIncome 
                        ? (isHindi ? 'आय' : 'Income')
                        : (isHindi ? 'व्यय' : 'Expense'),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: transaction.isIncome ? AppTheme.accentColor : AppTheme.secondaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
} 