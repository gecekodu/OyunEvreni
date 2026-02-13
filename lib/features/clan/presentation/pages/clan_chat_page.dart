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
  late final Stream<List<ClanMessage>> _messagesStream;
  static const double _inputBarHeight = 72;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getClanMessagesStream(widget.clan.id);
  }

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
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
                        SizedBox(height: 12),
                        Text(
                          'Sohbet yuklenemedi',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Lutfen tekrar deneyin',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

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
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + _inputBarHeight),
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
              color: const Color(0xFF1E1638),
              border: Border(
                top: BorderSide(
                  color: Colors.white12,
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
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2A214A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _messageController.text.isEmpty
                          ? null
                          : Icon(Icons.check_circle, color: Color(0xFFFFC300)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300),
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
                    color: const Color(0xFF1B1532),
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
          Padding(
            padding: EdgeInsets.only(
              left: isOwn ? 0 : 6,
              right: isOwn ? 6 : 0,
              bottom: 4,
            ),
            child: Row(
              mainAxisAlignment:
                  isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isOwn) ...[
                  _buildAvatar(message),
                  SizedBox(width: 8),
                ],
                Text(
                  message.userName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
                if (isOwn) ...[
                  SizedBox(width: 8),
                  _buildAvatar(message),
                ],
              ],
            ),
          ),

          // Mesaj balloon
          GestureDetector(
            onLongPress: isOwn ? () => _showMessageOptions(message) : null,
            child: Container(
              decoration: BoxDecoration(
                color: isOwn
                    ? const Color(0xFF3B7BFF)
                    : const Color(0xFF2A214A),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment:
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.white,
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
                            color: Colors.white.withOpacity(0.2),
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
                            ? const Color(0xFFFFC300).withOpacity(0.25)
                            : Colors.white12,
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

  Widget _buildAvatar(ClanMessage message) {
    final photoUrl = message.userPhotoUrl;
    final emoji = message.userAvatarEmoji;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: const Color(0xFF2A214A),
      );
    }

    if (emoji != null && emoji.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: const Color(0xFF2A214A),
        child: Text(emoji, style: const TextStyle(fontSize: 14)),
      );
    }

    final initial = message.userName.isNotEmpty
      ? message.userName[0].toUpperCase()
      : '?';
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFF2A214A),
      child: Text(
        initial,
        style: const TextStyle(fontSize: 12, color: Colors.white70),
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
                  await _chatService.deleteMessage(widget.clan.id, message.id);
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
      await _chatService.addReaction(widget.clan.id, messageId, emoji);
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
