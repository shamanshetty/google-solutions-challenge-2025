import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/chat_message.dart';
import 'package:kisan_saathi/services/chatbot_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:kisan_saathi/widgets/chat_message_bubble.dart';
import 'package:kisan_saathi/widgets/crop_recommendation_card.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatbotService _chatbotService;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatbotService = Provider.of<ChatbotService>(context, listen: false);
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      
      _chatbotService.initConversation(localizationService.isHindi);
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    
    return Consumer<ChatbotService>(
      builder: (context, chatbotService, _) {
        _chatbotService = chatbotService;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isHindi ? 'फसल सलाहकार' : 'Crop Advisor'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'restart') {
                    _restartConversation();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'restart',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 18),
                        const SizedBox(width: 8),
                        Text(isHindi ? 'बातचीत पुनः प्रारंभ करें' : 'Restart Conversation'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Recommendations section (only shown when recommendations are available)
              if (chatbotService.hasRecommendations) _buildRecommendationsSection(chatbotService),
              
              // Chat messages
              Expanded(
                child: _buildChatMessages(chatbotService),
              ),
              
              // Input section
              _buildInputSection(chatbotService),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildRecommendationsSection(ChatbotService chatbotService) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'अनुशंसित फसलें:' : 'Recommended Crops:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chatbotService.recommendations?.length ?? 0,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(right: 12),
                  child: CropRecommendationCard(
                    recommendation: chatbotService.recommendations![index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessages(ChatbotService chatbotService) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: chatbotService.messages.length,
      itemBuilder: (context, index) {
        return ChatMessageBubble(
          message: chatbotService.messages[index],
          onOptionSelected: (option) {
            chatbotService.selectOption(option);
          },
        );
      },
    );
  }
  
  Widget _buildInputSection(ChatbotService chatbotService) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: AppTheme.getInputTextStyle(),
              decoration: InputDecoration(
                hintText: isHindi ? 'अपना संदेश लिखें...' : 'Type your message...',
                hintStyle: AppTheme.getInputHintStyle(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_messageController.text),
              icon: chatbotService.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _chatbotService.sendMessage(text);
    _messageController.clear();
  }
  
  void _restartConversation() {
    _chatbotService.restart();
  }
} 