import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,
}

class WalletTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String note;
  final DateTime date;

  WalletTransaction({
    String? id,
    required this.amount,
    required this.type,
    this.note = '',
    DateTime? date,
  }) : 
    this.id = id ?? '',
    this.date = date ?? DateTime.now();

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type.toString(),
      'note': note,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    // Handle different timestamp formats
    DateTime parseDate() {
      final dateValue = json['date'];
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      return DateTime.now();
    }
    
    return WalletTransaction(
      id: json['id'] as String,
      amount: (json['amount'] is int) 
          ? (json['amount'] as int).toDouble() 
          : json['amount'] as double,
      type: json['type'].toString().contains('income') 
          ? TransactionType.income 
          : TransactionType.expense,
      note: json['note'] as String? ?? '',
      date: parseDate(),
    );
  }
} 