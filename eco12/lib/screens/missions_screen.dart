// lib/screens/missions_screen.dart

import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QuestService _questService = QuestService();
  Future<List<Quest>>? _dailyQuestsFuture;
  Future<List<Quest>>? _weeklyQuestsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuests();
  }

  void _loadQuests() {
    setState(() {
      // Panggil service untuk mendapatkan data misi
      _dailyQuestsFuture = _questService.fetchActiveQuests().then(
        (quests) => quests.where((q) => q.type == 'Daily').toList(),
      );
      _weeklyQuestsFuture = _questService.fetchActiveQuests().then(
        (quests) => quests.where((q) => q.type == 'Weekly').toList(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Widget untuk menampilkan progress card misi
  Widget _buildQuestCard(Quest quest) {
    String progressText;
    if (quest.objectiveType == 'walkDistance') {
      progressText = '${(quest.userProgress * quest.targetValue).toInt()} / ${quest.targetValue}m';
    } else {
      progressText = '${(quest.userProgress * quest.targetValue).toInt()} / ${quest.targetValue} Items';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Margin sedikit dikurangi
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        leading: Icon(
          quest.type == 'Daily' ? Icons.calendar_today : Icons.calendar_view_week,
          color: Colors.green,
        ),
        title: Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
              child: LinearProgressIndicator(
                value: quest.userProgress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.lightGreen,
                minHeight: 8,
              ),
            ),
            // Menggunakan Wrap untuk menghindari overflow pada teks reward
            Wrap(
              spacing: 10.0, 
              runSpacing: 4.0,
              children: [
                Text(progressText, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Reward: ${quest.xpReward} XP, ${quest.gpReward} GP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        // Batasi lebar tombol Trailing untuk mengatasi overflow
        trailing: SizedBox( 
          width: 70, 
          child: ElevatedButton(
            onPressed: quest.userProgress >= 1.0 ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Klaim Hadiah: ${quest.title}!'))
              );
              // TODO: Panggil API klaim hadiah
            } : null, 
            child: const Text('Klaim', style: TextStyle(fontSize: 12)), 
          ),
        ),
      ),
    );
  }

  // Widget untuk FutureBuilder dan list view
  Widget _buildQuestList(Future<List<Quest>> future) {
    return FutureBuilder<List<Quest>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading quests: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No active missions right now.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildQuestCard(snapshot.data![index]);
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Tasks & Quests'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.green.shade200,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Daily Tasks'),
            Tab(text: 'Weekly Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestList(_dailyQuestsFuture!),
          _buildQuestList(_weeklyQuestsFuture!),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadQuests,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}