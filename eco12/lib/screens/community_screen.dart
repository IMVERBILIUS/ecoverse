// lib/screens/community_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/community_event.dart';
import '../models/leaderboard_entry.dart';
import '../services/event_service.dart';
import '../services/leaderboard_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

// FIX: Mix in SingleTickerProviderStateMixin to provide the 'vsync' needed by TabController
class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin { 
  // Tambahkan TabController
  late TabController _tabController;
  final EventService _eventService = EventService();
  final LeaderboardService _leaderboardService = LeaderboardService(); 
  
  late Future<List<CommunityEvent>> _eventsFuture;
  late Future<List<LeaderboardEntry>> _globalLeaderboardFuture; 

  // Fungsi helper untuk icon avatar (harus sama dengan di profile/map screen)
  IconData _getIconData(String? id) {
    switch (id) {
      case 'nature': return Icons.nature_people;
      case 'star': return Icons.star;
      case 'leaf': return Icons.eco;
      case 'tree': return Icons.park;
      case 'sun': return Icons.wb_sunny;
      case 'flower': return Icons.local_florist;
      default: return Icons.person;
    }
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController di sini
    _tabController = TabController(length: 2, vsync: this); 
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _eventsFuture = _eventService.fetchUpcomingEvents();
      _globalLeaderboardFuture = _leaderboardService.fetchLeaderboard(category: 'GP'); 
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Wajib dispose controller
    super.dispose();
  }
  
  // --- LOGIKA EVENT (Join/Cancel/Detail) ---
  void _handleCancelJoin(String eventId) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final String resultMessage = await _eventService.cancelJoinEvent(eventId);
    if (mounted) Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultMessage)));
    if (resultMessage.startsWith('Success')) _loadData(); 
  }

  void _handleJoinEvent(String eventId) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final String resultMessage = await _eventService.joinEvent(eventId);
    if (mounted) Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultMessage)));
    if (resultMessage.startsWith('Success')) _loadData();
  }
  
  void _showEventDetail(CommunityEvent event) {
    String locationText = event.address;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Divider(),
              Text(event.description),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.calendar_today, 'Date & Time', DateFormat('EEE, MMM d, yyyy - HH:mm').format(event.eventDate)),
              _buildDetailRow(Icons.location_on, 'Address', locationText),
              _buildDetailRow(Icons.person_pin, 'Organizer', event.organizer),
              _buildDetailRow(
                Icons.group, 
                'Capacity', 
                '${event.participantsCount} / ${event.maxParticipants}',
                isFull: event.participantsCount >= event.maxParticipants,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(child: const Text('Close'), onPressed: () => Navigator.of(context).pop()),
          if (event.isUserParticipating)
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); _handleCancelJoin(event.id); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('CANCEL JOIN'),
            )
          else if (event.participantsCount < event.maxParticipants)
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); _handleJoinEvent(event.id); },
              child: const Text('JOIN NOW'),
            ),
        ],
      ),
    );
  }

  // Widget Bantuan untuk Detail Dialog
  Widget _buildDetailRow(IconData icon, String label, String value, {bool isFull = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isFull ? Colors.red : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(value, style: TextStyle(color: isFull ? Colors.red : Colors.black, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget BARU: Menampilkan daftar Leaderboard
  Widget _buildLeaderboardList(Future<List<LeaderboardEntry>> future) {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Eco-Warriors found yet. Start cleaning!'));
        }
        
        final users = snapshot.data!;
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final rank = index + 1;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              elevation: 1,
              child: ListTile(
                title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Rank: ${user.rank}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${user.gp} GP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    Text('${user.xp} XP', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                // Icon Avatar dan Rank #
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                    const SizedBox(width: 8),
                    Icon(_getIconData(user.avatarId), size: 28, color: Colors.teal),
                  ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        // TAB BAR untuk memisahkan Events dan Leaderboard
        bottom: TabBar( 
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue.shade200,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Local Events'),
            Tab(text: 'Global Leaderboard'), // <-- Tab Leaderboard
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Events (Existing List)
          FutureBuilder<List<CommunityEvent>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No upcoming events found in your area.'));
              }
              final events = snapshot.data!;
              
              // Widget list event
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isFull = event.participantsCount >= event.maxParticipants;
                  final isRegistered = event.isUserParticipating;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 3,
                    child: ListTile(
                      onTap: () => _showEventDetail(event), 
                      leading: const Icon(Icons.event_note, color: Colors.blue),
                      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Organizer: ${event.organizer}'),
                          Text('Date: ${DateFormat('EEE, MMM d, yyyy - h:mm a').format(event.eventDate)}'),
                          Text('Address: ${event.address}'),
                          Text('Participants: ${event.participantsCount} / ${event.maxParticipants}',
                            style: TextStyle(color: isFull ? Colors.red : Colors.green.shade800, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 90,
                        child: ElevatedButton(
                          onPressed: isFull 
                            ? null 
                            : isRegistered 
                              ? () => _handleCancelJoin(event.id) 
                              : () => _handleJoinEvent(event.id),  
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered ? Colors.red : Colors.blue, 
                            minimumSize: const Size(90, 30),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            isRegistered ? 'CANCEL' : isFull ? 'FULL' : 'JOIN',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Tab 2: Leaderboard (New List Widget)
          _buildLeaderboardList(_globalLeaderboardFuture),
        ],
      ),
    );
  }
}