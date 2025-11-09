// lib/screens/missions_screen.dart (Full Code - FINAL FIX)

import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../models/user_summary.dart'; 
import '../services/user_service.dart'; 

// Define Colors
const Color primaryGreen = Color(0xFF4CAF50);
const Color secondaryTeal = Color(0xFF7CA1A6);

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  final QuestService _questService = QuestService();
  final UserService _userService = UserService();
  Future<List<Quest>>? _allQuestsFuture;
  Future<UserSummary?>? _userSummaryFuture; 
  
  String? _expandedQuestId;
  String _selectedFilter = 'All'; // State untuk filter yang aktif
  // Hanya tampilkan filter yang relevan setelah memfilter di backend
  final List<String> _filters = ['All', 'Daily', 'Weekly', 'Completed', 'Available']; 
  
  // Custom Header Icon Helper
  IconData _getAvatarIconData(String? id) {
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
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _allQuestsFuture = _questService.fetchActiveQuests();
      _userSummaryFuture = _userService.fetchUserSummary();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  // Widget BARU: Header Kustom (Fixed Height + Alignment)
  Widget _buildCustomHeader(UserSummary summary) {
    final double topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      color: primaryGreen,
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 12), 
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: secondaryTeal,
                child: Icon(_getAvatarIconData(summary.avatarId), color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              
              // 2. Nama dan XP Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.username,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    // Level dan GP Balance
                    Text(
                      'Level ${summary.level} | ${summary.gp} GP',
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    // XP Progress Bar
                    Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                                value: summary.progressFraction,
                                backgroundColor: Colors.transparent,
                                color: Colors.amberAccent, 
                            ),
                        ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bar_chart, color: Colors.white, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  // Widget BARU: Card Misi yang Dapat Diperluas
  Widget _buildExpandableQuestCard(Quest quest, bool isExpanded) {
    Color borderColor;
    
    if (quest.type == 'Daily') {
      borderColor = Colors.blue.shade300;
    } else if (quest.type == 'Weekly') {
      borderColor = Colors.orange.shade300;
    } else {
      borderColor = Colors.grey.shade400;
    }
    
    // Tentukan Progress Text berdasarkan tipe misi
    String progressUnit = quest.objectiveType == 'walk_m' ? 'm' : quest.objectiveType == 'collect_kg' ? 'kg' : 'points';

    String progressDisplay = '${(quest.userProgress * quest.threshold).toInt()}/${quest.threshold} $progressUnit';
        
    bool isCompleted = quest.userProgress >= 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: isExpanded ? 5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isExpanded ? primaryGreen : borderColor.withOpacity(0.5), width: isExpanded ? 3.0 : 1.0),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedQuestId = isExpanded ? null : quest.id;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOP SUMMARY SECTION ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Icon (Checkmark/Active)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isCompleted ? primaryGreen : Colors.amber,
                    child: Icon(isCompleted ? Icons.check : Icons.local_fire_department, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  
                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Reward: +${quest.xpReward} XP, +${quest.gpReward} GP',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Active Button (Trailing)
                  SizedBox(
                    width: 70,
                    child: ElevatedButton(
                      onPressed: isCompleted ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Claiming rewards... (Feature not yet active)'))) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.amber : primaryGreen,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isCompleted ? 'CLAIM' : 'ACTIVE',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- EXPANDABLE DETAIL SECTION ---
            if (isExpanded) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objectives (${quest.type}):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryGreen),
                    ),
                    const SizedBox(height: 8),
                    // Display Objectives (Simulated Checkbox List)
                    _buildObjectiveRow('Current Progress: ${progressDisplay}', quest.userProgress > 0.0),
                    _buildObjectiveRow('Reach goal of ${quest.threshold} ${progressUnit}', quest.userProgress >= 1.0),
                    _buildObjectiveRow('Complete action (Recycle/Walk/Report)', quest.userProgress >= 1.0),
                    _buildObjectiveRow('Report completion from the map', quest.userProgress >= 1.0),
                    const SizedBox(height: 15),
                    
                    // Progress Bar
                    Text('Current Progress:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: quest.userProgress,
                      backgroundColor: Colors.grey.shade300,
                      color: primaryGreen,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Widget Bantuan: Objective Row
  Widget _buildObjectiveRow(String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(isChecked ? Icons.check_circle : Icons.radio_button_unchecked, 
              size: 18, 
              color: isChecked ? primaryGreen : Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: isChecked ? Colors.black87 : Colors.grey))),
        ],
      ),
    );
  }

  // Logika Filter (Menggunakan state _selectedFilter)
  List<Quest> _applyFilter(List<Quest> quests) {
    if (_selectedFilter == 'All') {
      return quests;
    }
    if (_selectedFilter == 'Daily') {
      return quests.where((q) => q.type == 'Daily').toList();
    }
    if (_selectedFilter == 'Weekly') {
      return quests.where((q) => q.type == 'Weekly').toList();
    }
    // Tambahkan filter Completed/Available jika diperlukan
    return quests; 
  }

  // Widget untuk FutureBuilder dan list view
  Widget _buildQuestList(Future<List<Quest>> future) {
    return FutureBuilder<List<Quest>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading quests: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text('No active missions right now.')));
        } else {
          final filteredQuests = _applyFilter(snapshot.data!);

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Diatur oleh CustomScrollView
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: filteredQuests.length,
            itemBuilder: (context, index) {
              final quest = filteredQuests[index];
              final isExpanded = quest.id == _expandedQuestId;
              return _buildExpandableQuestCard(quest, isExpanded);
            },
          );
        }
      },
    );
  }

  // Widget BARU: Filter Chips
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter, style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              )),
              selected: isSelected,
              selectedColor: primaryGreen,
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? primaryGreen : Colors.grey.shade300),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Gunakan FutureBuilder untuk Header Kustom
    return FutureBuilder<UserSummary?>(
      future: _userSummaryFuture,
      builder: (context, snapshot) {
        // Tampilkan loading screen jika user data belum siap
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
             backgroundColor: Colors.white,
             body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        
        final summary = snapshot.data!;
        
        return Scaffold(
          body: Column(
            children: [
              // 1. Header Kustom (Fixed Height)
              _buildCustomHeader(summary),
              
              // 2. Filter Chips Container
              Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  child: _buildFilterChips(), // <-- FILTER CHIPS
              ),
              
              // 3. List Quests (Menggunakan Expanded)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildQuestList(_allQuestsFuture!), 
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _loadData,
            backgroundColor: primaryGreen,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        );
      },
    );
  }
}