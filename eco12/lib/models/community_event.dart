// lib/models/community_event.dart (Full Code - Address Field)

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final DateTime eventDate;
  final int participantsCount;
  final int maxParticipants;
  final bool isUserParticipating;
  final String address; // <-- Ganti Map/GeoJSON dengan String

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.eventDate,
    required this.participantsCount,
    required this.maxParticipants,
    required this.isUserParticipating,
    required this.address, // <-- Update constructor
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json, String currentUserId) {
    final List<dynamic> participants = json['participants'] as List<dynamic>? ?? [];
    final bool isParticipating = participants.contains(currentUserId);
    
    final DateTime date = DateTime.parse(json['eventDate']);

    return CommunityEvent(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      organizer: json['organizer'] ?? 'Local Eco-Champion',
      eventDate: date,
      participantsCount: participants.length,
      maxParticipants: json['maxParticipants'] ?? 50,
      isUserParticipating: isParticipating,
      address: json['address'] ?? 'Online / To be Announced', // <-- Ambil alamat
    );
  }
}