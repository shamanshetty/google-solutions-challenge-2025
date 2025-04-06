import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_saathi/models/transaction.dart';

class WalletService extends ChangeNotifier {
  List<WalletTransaction> _transactions = [];
  double _balance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoading = false;
  
  // Getters
  List<WalletTransaction> get transactions => _transactions;
  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  bool get isLoading => _isLoading;
  
  // Key for SharedPreferences
  static const String _transactionsKey = 'wallet_transactions';
  
  WalletService() {
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson != null) {
        final List<dynamic> decodedList = jsonDecode(transactionsJson);
        _transactions = decodedList
            .map((data) => WalletTransaction.fromJson(data))
            .toList();
      }
      
      _calculateSummary();
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = 
          _transactions.map((t) => t.toJson()..['id'] = t.id).toList();
      await prefs.setString(_transactionsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }
  
  void _calculateSummary() {
    _totalIncome = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
        
    _totalExpense = _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
        
    _balance = _totalIncome - _totalExpense;
  }
  
  Future<void> addTransaction(WalletTransaction transaction) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Generate a unique ID (simple timestamp-based approach)
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create a new transaction with the generated ID
      final newTransaction = WalletTransaction(
        id: id,
        amount: transaction.amount,
        type: transaction.type,
        note: transaction.note,
        date: transaction.date,
      );
      
      _transactions.add(newTransaction);
      _calculateSummary();
      await _saveTransactions();
    } catch (e) {
      print('Error adding transaction: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _transactions.removeWhere((t) => t.id == id);
      _calculateSummary();
      await _saveTransactions();
    } catch (e) {
      print('Error deleting transaction: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  List<WalletTransaction> getRecentTransactions({int limit = 5}) {
    final sortedTransactions = List<WalletTransaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sortedTransactions.take(limit).toList();
  }
  
  // For mock real-time updates
  void listenToTransactions() {
    // In a real implementation, this would set up a listener.
    // For now, we'll just load the transactions once.
    _loadTransactions();
  }
} 