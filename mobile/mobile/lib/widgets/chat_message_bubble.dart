import 'package:flutter/material.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onOptionSelected;
  
  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.black : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                if (message.hasOptions) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.options!.map((option) {
                      return _buildOptionButton(option);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.agriculture,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildOptionButton(String option) {
    return OutlinedButton(
      onPressed: () => onOptionSelected(option),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: AppTheme.primaryColor),
      ),
      child: Text(option),
    );
  }
} 