import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clan.dart';
import '../../data/services/clan_service.dart';
import '../../data/services/clan_chat_service.dart';
import 'clan_chat_page.dart';

class ClanPage extends StatefulWidget {
  const ClanPage({super.key});

  @override
  State<ClanPage> createState() => _ClanPageState();
}

class _ClanPageState extends State<ClanPage> with SingleTickerProviderStateMixin {
  final _clanService = ClanService();
  final _chatService = ClanChatService();
  late TabController _tabController;
  bool _isLoading = true;
  Clan? _userClan;
  List<Map<String, dynamic>> _clanMembers = [];
  int _initialClanTab = 0;
  bool _showWelcomeToast = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: _initialClanTab, vsync: this);
    _loadUserClan();
    // 🏰 Tüm klan puanlarını eş zamanlı olarak senkronize et
    _syncAllClanScores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserClan() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final clan = await _clanService.getUserClan(user.uid);
        if (clan != null) {
          final members = await _clanService.getClanMembers(clan.id);
          if (mounted) {
            setState(() {
              _userClan = clan;
              _clanMembers = members;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _userClan = null;
              _isLoading = false;
              _initialClanTab = 0;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  /// 🏰 Tüm klan puanlarını senkronize et (Her klanın üyelerinin toplam puanını hesapla)
  Future<void> _syncAllClanScores() async {
    try {
      print('🔄 Tüm klan puanları senkronize ediliyor...');
      await _clanService.recalculateAllClanScores();
      print('✅ Tüm klan puanları senkronize edildi!');
    } catch (e) {
      print('⚠️ Klan puanları senkronize edilirken hata: $e');
      // Sessiz fail - kullanıcı tarafında hata gösterilmez
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
      );
    }

    // Kullanıcının klanı varsa klan detayını göster
    if (_userClan != null) {
      if (_showWelcomeToast) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _tabController.animateTo(1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sohbete hos geldin!')),
          );
          setState(() => _showWelcomeToast = false);
        });
      }
      return DefaultTabController(
        length: 3,
        initialIndex: _initialClanTab,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_userClan!.emoji, style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(_userClan!.name),
              ],
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Üyeler'),
                Tab(text: 'Sohbet'),
                Tab(text: 'Sıralama'),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'leave') {
                    _showLeaveDialog();
                  } else if (value == 'delete') {
                    _showDeleteDialog();
                  } else if (value == 'edit') {
                    _showEditDialog();
                  }
                },
                itemBuilder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  final isLeader = user?.uid == _userClan!.leaderId;
                  
                  return [
                    if (isLeader)
                      PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                    if (!isLeader)
                      PopupMenuItem(value: 'leave', child: Text('Ayrıl')),
                    if (isLeader)
                      PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                  ];
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _buildMembersTab(),
              ClanChatPage(clan: _userClan!),
              _buildLeaderboardTab(),
            ],
          ),
        ),
      );
    }

    // Kullanıcının klanı yoksa klan listesi ve oluşturma seçenekleri
    return _buildClanExplorerView();
  }

  Widget _buildMembersTab() {
    return RefreshIndicator(
      onRefresh: _loadUserClan,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Klan Kartı
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _userClan!.emoji,
                    style: TextStyle(fontSize: 64),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _userClan!.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _userClan!.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Üye', '${_userClan!.memberCount}/${_userClan!.maxMembers}'),
                      _buildStatCard('Klan Puanı', _userClan!.totalScore.toString()),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _handleLeaveClan,
                          icon: Icon(Icons.exit_to_app, size: 18),
                          label: Text('Klandan Ayrıl'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.6)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleChangeClan,
                          icon: Icon(Icons.swap_horiz, size: 18),
                          label: Text('Klan Değiştir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Üye Sıralaması Başlığı
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.leaderboard, color: Colors.deepOrange, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Üye Sıralaması',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),

            // Üye Listesi
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._clanMembers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return _buildMemberCard(member, index + 1);
                  }).toList(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member, int rank) {
    final isLeader = member['isLeader'] as bool;
    
    Color getRankColor() {
      if (rank == 1) return Color(0xFFFFD700); // Gold
      if (rank == 2) return Color(0xFFC0C0C0); // Silver
      if (rank == 3) return Color(0xFFCD7F32); // Bronze
      return Color(0xFF00D4FF); // Cyan
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? getRankColor().withOpacity(0.5) : Color(0xFF00D4FF).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: getRankColor().withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                getRankColor(),
                getRankColor().withOpacity(0.6),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: getRankColor().withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              member['userName'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (isLeader) ...[
              SizedBox(width: 8),
              Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
            ],
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8BFF6B),
                Color(0xFF00D4FF),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${member['score']} puan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClanExplorerView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏰 Klanlar'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Klan Listesi'),
            Tab(text: 'Sıralama'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClanListTab(),
          _buildLeaderboardTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClanDialog,
        icon: Icon(Icons.add),
        label: Text('Klan Oluştur'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Widget _buildClanListTab() {
    return StreamBuilder<List<Clan>>(
      stream: _clanService.getAllClansStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz klan yok', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('İlk klanı sen oluştur!', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final clans = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: clans.length,
          itemBuilder: (context, index) {
            final clan = clans[index];
            return _buildClanListCard(clan);
          },
        );
      },
    );
  }

  Widget _buildClanListCard(Clan clan) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showJoinDialog(clan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    clan.emoji,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clan.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      clan.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${clan.memberCount}/${clan.maxMembers}',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '${clan.totalScore}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!clan.isFull)
                Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return StreamBuilder<List<Clan>>(
      stream: _clanService.getAllClansStream(orderBy: 'totalScore'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Henüz klan yok'));
        }

        final clans = snapshot.data!;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1638),
                Color(0xFF221A40),
                Color(0xFF2A1F4D),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFC300), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Klan Sıralaması',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC300),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Column(
                    children: [
                      ...clans.asMap().entries.map((entry) {
                        final index = entry.key;
                        final clan = entry.value;
                        return _buildLeaderboardCard(clan, index + 1);
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardCard(Clan clan, int rank) {
    Color rankColor = const Color(0xFF6C5CE7);
    if (rank == 1) {
      rankColor = const Color(0xFFFFC300);
    } else if (rank == 2) {
      rankColor = const Color(0xFFB0B3FF);
    } else if (rank == 3) {
      rankColor = const Color(0xFFFF8A00);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: rank <= 3 ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: rank <= 3
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rankColor.withOpacity(0.25),
                    Color(0xFF1E1638),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: rankColor,
            radius: 24,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(clan.emoji, style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  clan.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${clan.memberCount} üye',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${clan.totalScore}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC300),
                ),
              ),
              Text(
                'puan',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialogs

  void _showCreateClanDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedEmoji = '🏰';

    final emojis = ['🏰', '⚔️', '🛡️', '🔥', '⚡', '🌟', '🎮', '🏆', '👑', '🦁', '🐉', '🦅'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Yeni Klan Oluştur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Klan Adı',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                Text('Emoji Seç:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((emoji) {
                    final isSelected = emoji == selectedEmoji;
                    return InkWell(
                      onTap: () {
                        setDialogState(() => selectedEmoji = emoji);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange.withOpacity(0.2) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.deepOrange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji, style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Klan adı gerekli')),
                  );
                  return;
                }

                try {
                  Navigator.pop(context);
                  await _clanService.createClan(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    emoji: selectedEmoji,
                  );
                  await _loadUserClan();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Klan oluşturuldu!')),
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
              child: Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendJoinWelcomeMessage(Clan clan) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? user?.email ?? 'Kullanici';
      await _chatService.sendMessage(
        clanId: clan.id,
        message: '🎉 $userName klana katildi! Hos geldin!',
      );
    } catch (e) {
      debugPrint('Hos geldin mesaji gonderilemedi: $e');
    }
  }

  void _showJoinDialog(Clan clan) {
    if (clan.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu klan dolu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${clan.emoji} ${clan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clan.description),
            SizedBox(height: 16),
            Text('Üye: ${clan.memberCount}/${clan.maxMembers}'),
            Text('Toplam Puan: ${clan.totalScore}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _clanService.joinClan(clan.id);
                await _sendJoinWelcomeMessage(clan);
                setState(() {
                  _initialClanTab = 1;
                  _showWelcomeToast = true;
                });
                await _loadUserClan();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Klana katıldın!')),
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
            child: Text('Katıl'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog({bool openExplorer = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Klan Ayrıl'),
        content: Text('Klanından ayrılmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _clanService.leaveClan(_userClan!.id);
                await _loadUserClan();
                if (openExplorer && mounted) {
                  setState(() {
                    _userClan = null;
                    _clanMembers = [];
                    _initialClanTab = 0;
                  });
                  _tabController.index = 0;
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Klandan ayrıldın')),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  void _handleLeaveClan() {
    final user = FirebaseAuth.instance.currentUser;
    if (_userClan != null && user != null && _userClan!.leaderId == user.uid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Lider Klanı'),
          content: Text('Lider olduğun için klanı terk edemezsin. Klanı silmek ister misin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Klanı Sil'),
            ),
          ],
        ),
      );
      return;
    }
    _showLeaveDialog();
  }

  void _handleChangeClan() {
    final user = FirebaseAuth.instance.currentUser;
    if (_userClan != null && user != null && _userClan!.leaderId == user.uid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Lider Klanı'),
          content: Text('Lider olduğun için klanı terk edemezsin. Klanı silmek ister misin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Klanı Sil'),
            ),
          ],
        ),
      );
      return;
    }
    _showLeaveDialog(openExplorer: true);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Klanı Sil'),
        content: Text('Klanı silmek istediğine emin misin? Bu işlem geri alınamaz!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _clanService.deleteClan(_userClan!.id);
                await _loadUserClan();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Klan silindi')),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _userClan!.name);
    final descController = TextEditingController(text: _userClan!.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Klanı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Klan Adı'),
              maxLength: 20,
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Açıklama'),
              maxLength: 100,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _clanService.updateClan(
                  clanId: _userClan!.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                );
                await _loadUserClan();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Klan güncellendi')),
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
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
