// 💬 KLAN SOHBET SAYFASI

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clan.dart';
import '../../domain/entities/clan_message.dart';
import '../../data/services/clan_chat_service.dart';

class ClanChatPage extends StatefulWidget {
  final Clan clan;

  const ClanChatPage({
    super.key,
    required this.clan,
  });

  @override
  State<ClanChatPage> createState() => _ClanChatPageState();
}

class _ClanChatPageState extends State<ClanChatPage> {
  final _chatService = ClanChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _chatService.sendMessage(
        clanId: widget.clan.id,
        message: _messageController.text.trim(),
      );
      _messageController.clear();

      // Sayfayı aşağıya kaydır
      await Future.delayed(Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.clan.emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clan.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${widget.clan.memberCount} üye',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mesajlar
          Expanded(
            child: StreamBuilder<List<ClanMessage>>(
              stream: _chatService.getClanMessagesStream(widget.clan.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz mesaj yok',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'İlk mesajı sen gönder!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                final currentUser = FirebaseAuth.instance.currentUser;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwn = message.userId == currentUser?.uid;

                    return _buildMessageBubble(message, isOwn, currentUser);
                  },
                );
              },
            ),
          ),

          // Mesaj giriş alanı
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _messageController.text.isEmpty
                          ? null
                          : Icon(Icons.check_circle, color: Colors.deepOrange),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ClanMessage message,
    bool isOwn,
    User? currentUser,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isOwn ? 40 : 0,
        right: isOwn ? 0 : 40,
      ),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Kullanıcı adı ve saat
          if (!isOwn)
            Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                children: [
                  Text(
                    message.userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

          // Mesaj balloon
          GestureDetector(
            onLongPress: isOwn ? () => _showMessageOptions(message) : null,
            child: Container(
              decoration: BoxDecoration(
                color: isOwn
                    ? Colors.deepOrange
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment:
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isOwn ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (message.reactions.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: message.reactions.map((reaction) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            reaction,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tepki butonları
          if (!isOwn)
            Padding(
              padding: EdgeInsets.only(top: 4, left: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['👍', '❤️', '😂', '🔥'].map((emoji) {
                  final hasReaction = message.reactions.contains(emoji);
                  return InkWell(
                    onTap: () => _addReaction(message.id, emoji),
                    child: Container(
                      margin: EdgeInsets.only(right: 4),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: hasReaction
                            ? Colors.deepOrange.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageOptions(ClanMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Kopyala'),
              onTap: () {
                // Clipboard'a kopyala
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _chatService.deleteMessage(message.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mesaj silindi')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    try {
      await _chatService.addReaction(messageId, emoji);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}d';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}s';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
