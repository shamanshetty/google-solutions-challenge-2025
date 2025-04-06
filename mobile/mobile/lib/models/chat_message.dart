import 'package:flutter/material.dart';

enum MessageType {
  user,
  bot,
  option,
}

class ChatMessage {
  final String text;
  final MessageType type;
  final List<String>? options;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    this.options,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => type == MessageType.user;
  bool get isBot => type == MessageType.bot;
  bool get isOption => type == MessageType.option;
  bool get hasOptions => options != null && options!.isNotEmpty;
} 