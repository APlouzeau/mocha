import 'package:flutter/material.dart';
import '../services/openrouter_service.dart';

class AIAssistantPanel extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onClose;

  const AIAssistantPanel({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.onClose,
  });

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userMessage = _promptController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: userMessage));
      _isLoading = true;
    });
    _promptController.clear();
    _scrollToBottom();

    try {
      final response = await OpenRouterService.sendMessage(
        userMessage: userMessage,
        currentTitle: widget.titleController.text,
        currentContent: widget.contentController.text,
        conversationHistory: _messages.sublist(0, _messages.length - 1),
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: response));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            content: '❌ Erreur: ${e.toString().replaceAll('Exception: ', '')}',
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Fond semi-transparent cliquable pour fermer
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Panneau de chat
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0DD),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6D4C41),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD2B48C),
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFD2B48C)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Assistant MOCA',
                            style: TextStyle(
                              color: Color(0xFFD2B48C),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFD2B48C)),
                          onPressed: widget.onClose,
                          tooltip: 'Fermer',
                        ),
                      ],
                    ),
                  ),
                  // Messages
                  Expanded(
                    child: _messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: _messages.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length && _isLoading) {
                                return _buildLoadingBubble();
                              }
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                  ),
                  // Input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promptController,
                              decoration: InputDecoration(
                                hintText: 'Demandez de l\'aide...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFFD2B48C)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFFD2B48C)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F0DD),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D4C41),
                                foregroundColor: const Color(0xFFD2B48C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFD2B48C),
                                      ),
                                    )
                                  : const Icon(Icons.send, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Assistant MOCA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Posez vos questions ou demandez de l\'aide pour rédiger votre post.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('💡 Propose un titre'),
                _buildSuggestionChip('✨ Améliore mon texte'),
                _buildSuggestionChip('📝 Corrige les fautes'),
                _buildSuggestionChip('🎯 Structure mon post'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFFD2B48C).withAlpha(77),
      labelStyle: const TextStyle(
        color: Color(0xFF6D4C41),
        fontSize: 12,
      ),
      onPressed: () {
        _promptController.text = text.replaceAll(RegExp(r'^[^\w]+'), '');
        _sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF6D4C41),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Color(0xFFD2B48C),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF6D4C41) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF333333),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD2B48C),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Color(0xFF6D4C41),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6D4C41),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Color(0xFFD2B48C),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.grey[300],
              const Color(0xFF6D4C41),
              (1 + (value * 2 * 3.14159).abs() % 1) / 2,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

