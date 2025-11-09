// lib/screens/community_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/community_event.dart';
import '../models/leaderboard_entry.dart';
import '../services/event_service.dart';
import '../services/leaderboard_service.dart';
import '../services/social_service.dart';

// --- THEME CONSTANTS & GAME ELEMENT HELPERS ---

// Helper to map rank names to colors and complexity (Game Element: Tiers)
Map<String, dynamic> _getRankTheme(String rank) {
  final lowerRank = rank.toLowerCase();
  if (lowerRank.contains('hero') || lowerRank.contains('forest keeper')) {
    return {'color': Colors.teal.shade800, 'icon': Icons.forest, 'name': 'Eco-Hero'};
  }
  if (lowerRank.contains('tree')) {
    return {'color': Colors.green.shade700, 'icon': Icons.park, 'name': 'Mighty Tree'};
  }
  if (lowerRank.contains('sapling')) {
    return {'color': Colors.lightGreen.shade600, 'icon': Icons.scatter_plot, 'name': 'Sapling Scout'};
  }
  if (lowerRank.contains('sprout')) {
    return {'color': Colors.lime.shade600, 'icon': Icons.grain, 'name': 'Energetic Sprout'};
  }
  if (lowerRank.contains('seedling') || lowerRank.contains('seeder')) {
    return {'color': Colors.brown.shade400, 'icon': Icons.spa, 'name': 'New Seedling'};
  }
  return {'color': Colors.grey.shade500, 'icon': Icons.person, 'name': 'Citizen'};
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EventService _eventService = EventService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final SocialService _socialService = SocialService();
  
  late Future<List<CommunityEvent>> _eventsFuture;
  late Future<List<LeaderboardEntry>> _globalLeaderboardFuture;
  late Future<Map<String, dynamic>> _friendsDataFuture;

  String _searchQuery = '';
  Future<List<Map<String, dynamic>>>? _searchResultsFuture;


  // Game Element: Avatar Icons representing the Plant Pet system
  IconData _getIconData(String? id) {
    switch (id) {
      case 'nature': return Icons.local_florist; // Plant Pet
      case 'star': return Icons.star_border; // Rare Item
      case 'leaf': return Icons.eco_sharp; // GP Icon
      case 'tree': return Icons.park;
      case 'sun': return Icons.wb_sunny;
      case 'flower': return Icons.grass;
      default: return Icons.person;
    }
  }
  
  // Game Element: Event Icons representing Mission Type
  IconData _getEventIcon(String title) {
    String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('cleanup') || lowerTitle.contains('bersih')) {
      return Icons.recycling; // Cleanup Mission
    }
    if (lowerTitle.contains('tanam') || lowerTitle.contains('pohon') || lowerTitle.contains('hijau')) {
      return Icons.yard; // Tree Planting Mission
    }
    if (lowerTitle.contains('webinar') || lowerTitle.contains('seminar')) {
      return Icons.laptop_windows; // Educational Mission
    }
    if (lowerTitle.contains('challenge') || lowerTitle.contains('aksi')) {
      return Icons.local_fire_department; // High-Intensity Challenge
    }
    return Icons.event_note; // General Quest
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _eventsFuture = _eventService.fetchUpcomingEvents();
      _globalLeaderboardFuture = _leaderboardService.fetchLeaderboard(category: 'GP');
      _friendsDataFuture = _socialService.getFriendsData();
      _searchResultsFuture = null;
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // --- LOGIKA SOSIAL & EVENT (MINOR CHANGES) ---
  
  void _showAddFriendDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect with an Eco-Warrior'), // Thematic title
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter username or Eco-ID',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final query = searchController.text.trim();
                Navigator.of(context).pop();
                if (query.isNotEmpty) {
                  _tabController.animateTo(2);
                  _handleSearch(query);
                }
              },
              child: const Text('Search & Send Request'),
            ),
          ],
        );
      },
    );
  }

  void _handleSendRequest(String targetId) async {
    final msg = await _socialService.sendRequest(targetId);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _loadData();
  }
  
  void _handleAcceptRequest(String senderId) async {
    final msg = await _socialService.acceptRequest(senderId);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _loadData();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchResultsFuture = _socialService.searchUsers(query);
    });
  }
  
  void _handleCancelJoin(String eventId) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    if(mounted) showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(color: primaryColor)));
    final String resultMessage = await _eventService.cancelJoinEvent(eventId);
    if (mounted) Navigator.of(context).pop();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultMessage)));
    if (resultMessage.startsWith('Success')) _loadData();
  }

  void _handleJoinEvent(String eventId) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    if(mounted) showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(color: primaryColor)));
    final String resultMessage = await _eventService.joinEvent(eventId);
    if (mounted) Navigator.of(context).pop();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultMessage)));
    if (resultMessage.startsWith('Success')) _loadData();
  }
  
  // Game Element: Showing GP Reward in Event Detail
  void _showEventDetail(CommunityEvent event) {
    String locationText = event.address;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final gpReward = event.participantsCount * 50; // Example dynamic reward calculation

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              // Game Element: Displaying GP Reward prominently
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text('Quest Reward: $gpReward GP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Text(event.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.calendar_today, 'Mission Date', DateFormat('EEE, MMM d, yyyy - HH:mm').format(event.eventDate), iconColor: secondaryColor),
              _buildDetailRow(Icons.location_on, 'Location', locationText, iconColor: secondaryColor),
              _buildDetailRow(Icons.person_pin, 'Quest Giver', event.organizer, iconColor: secondaryColor),
              _buildDetailRow(
                Icons.group, 
                'Capacity', 
                '${event.participantsCount} / ${event.maxParticipants} Warriors',
                isFull: event.participantsCount >= event.maxParticipants,
                iconColor: secondaryColor
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(child: const Text('Close'), onPressed: () => Navigator.of(context).pop()),
          if (event.isUserParticipating)
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); _handleCancelJoin(event.id); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              child: const Text('ABANDON QUEST', style: TextStyle(fontWeight: FontWeight.bold)), // Thematic action
            )
          else if (event.participantsCount < event.maxParticipants)
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); _handleJoinEvent(event.id); },
              style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.white),
              child: const Text('ACCEPT QUEST', style: TextStyle(fontWeight: FontWeight.bold)), // Thematic action
            ),
        ],
      ),
    );
  }

  // Widget Bantuan untuk Detail Dialog
  Widget _buildDetailRow(IconData icon, String label, String value, {bool isFull = false, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isFull ? Colors.red : iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(color: isFull ? Colors.red.shade700 : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET LISTS ---

  // Enhanced _buildFriendRow (Game Element: Rank & Avatar Styling)
  Widget _buildFriendRow(Map<String, dynamic> user, Color color, {bool canAccept = false}) {
    final rank = user['currentRank'] ?? 'Seedling';
    final rankTheme = _getRankTheme(rank);
    final rankColor = rankTheme['color'] as Color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Icon(_getIconData(user['avatarId']), size: 28, color: rankColor),
        ),
        title: Text(user['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(rankTheme['name'] as String, style: TextStyle(color: rankColor, fontWeight: FontWeight.w500)),
        trailing: canAccept 
            ? ElevatedButton(
                onPressed: () => _handleAcceptRequest(user['_id']),
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                child: const Text('Accept', style: TextStyle(fontSize: 12)),
              )
            : null,
      ),
    );
  }

  // Widget Friends/Social Tab (Game Element: Eco-Circle)
  Widget _buildFriendListTab(Future<Map<String, dynamic>> future) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Failed to load social data.'));
        }

        final friends = snapshot.data!['friends'] ?? [];
        final requests = snapshot.data!['requests'] ?? [];

        return Column(
          children: [
            Expanded(
              child: _searchResultsFuture != null && _searchQuery.isNotEmpty
                  ? _buildSearchResults(secondaryColor)
                  : ListView(
                      children: [
                        if (requests.isNotEmpty) _buildRequestList(requests, secondaryColor),
                        
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                          child: Text('My Eco-Circle (${friends.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColor)),
                        ),
                        if (friends.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No Eco-Warriors in your circle. Find partners to share the quest!'))),
                        ...friends.map((friend) => _buildFriendRow(Map<String, dynamic>.from(friend), secondaryColor, canAccept: false)).toList(),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
  
  // Widget Search Results
  Widget _buildSearchResults(Color color) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found for "$_searchQuery". Send a broadcast for help!'));
        }
        
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Text('Eco-Warrior Search Results for "$_searchQuery"', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ),
            ...snapshot.data!.map((user) => ListTile(
              leading: Icon(_getIconData(user['avatarId']), size: 40, color: color),
              title: Text(user['username'], style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(user['currentRank'] ?? 'Seedling'),
              trailing: ElevatedButton(
                onPressed: () => _handleSendRequest(user['_id']),
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                child: const Text('Add Ally', style: TextStyle(fontSize: 12)), // Thematic button
              ),
            )).toList(),
          ],
        );
      },
    );
  }
  
  // Widget Requests List
  Widget _buildRequestList(List<dynamic> requests, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.markunread_mailbox, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Incoming Ally Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
        ),
        ...requests.map((request) => _buildFriendRow(Map<String, dynamic>.from(request), secondaryColor, canAccept: true)).toList(),
      ],
    );
  }


  // Enhanced _buildLeaderboardList (Game Element: Rank Styling & GP Emphasis)
  Widget _buildLeaderboardList(Future<List<LeaderboardEntry>> future) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return FutureBuilder<List<LeaderboardEntry>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Eco-Warriors found yet. Be the first to claim a rank!'));
        }
        
        final users = snapshot.data!;
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final rank = index + 1;
            final isTopThree = rank <= 3;
            
            Color rankBadgeColor;
            if (rank == 1) {
              rankBadgeColor = Colors.amber.shade700;
            } else if (rank == 2) {
              rankBadgeColor = Colors.grey.shade500;
            } else if (rank == 3) {
              rankBadgeColor = Colors.brown.shade400;
            } else {
              rankBadgeColor = primaryColor.withOpacity(0.7);
            }
            
            final rankTheme = _getRankTheme(user.rank);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isTopThree ? BorderSide(color: rankBadgeColor, width: 3) : BorderSide.none,
              ),
              child: ListTile(
                title: Text(user.username, style: TextStyle(fontWeight: FontWeight.w800, color: primaryColor)),
                subtitle: Text(rankTheme['name'] as String, style: TextStyle(color: rankTheme['color'] as Color, fontWeight: FontWeight.w600)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Game Element: GP emphasized as primary score
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text('${user.gp}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700, fontSize: 16)),
                      ],
                    ),
                    Text('${user.xp} XP', style: TextStyle(fontSize: 12, color: secondaryColor)),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: rankBadgeColor)),
                    ),
                    const SizedBox(width: 8),
                    // Game Element: Avatar reflects the rank theme
                    Icon(rankTheme['icon'] as IconData, size: 30, color: rankBadgeColor), 
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  // Enhanced _buildEventsList (Game Element: Quest Terminology)
  Widget _buildEventsList() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return FutureBuilder<List<CommunityEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming missions found. Check back for new Quests!'));
          }
          final events = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isFull = event.participantsCount >= event.maxParticipants;
              final isRegistered = event.isUserParticipating;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isRegistered ? BorderSide(color: secondaryColor, width: 2) : BorderSide.none,
                ),
                child: ListTile(
                  onTap: () => _showEventDetail(event), 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getEventIcon(event.title), color: secondaryColor, size: 30),
                  ), 
                  title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${event.address}', 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)
                      ),
                      Text('Mission Start: ${DateFormat('EEE, MMM d, yyyy - h:mm a').format(event.eventDate)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: isFull 
                        ? null 
                        : isRegistered 
                          ? () => _handleCancelJoin(event.id) 
                          : () => _handleJoinEvent(event.id), 
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered ? Colors.red.shade700 : secondaryColor, 
                        minimumSize: const Size(110, 35),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isRegistered ? 'REGISTERED' : isFull ? 'FULL' : 'ACCEPT QUEST',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoVerse Community Hub', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: _showAddFriendDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        // TAB BAR: Clear, Thematic Separation
        bottom: TabBar( 
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          tabs: const [
            // Game Element: Mission Terminology
            Tab(icon: Icon(Icons.location_on), text: 'Missions'), 
            Tab(icon: Icon(Icons.leaderboard), text: 'Ranks'),
            // Game Element: Ally Terminology
            Tab(icon: Icon(Icons.people), text: 'Allies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(),
          _buildLeaderboardList(_globalLeaderboardFuture),
          _buildFriendListTab(_friendsDataFuture),
        ],
      ),
      floatingActionButton: _tabController.index == 2 ? FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: primaryColor,
        tooltip: 'Add Eco-Ally',
        child: const Icon(Icons.person_add, color: Colors.white, size: 28),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}