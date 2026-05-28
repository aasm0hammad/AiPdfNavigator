class ConversationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final String category; // 'RECENT', 'PINNED'

  ConversationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      title: map['title'] ?? 'Chat',
      subtitle: map['subtitle'] ?? '',
      time: map['time']?.toDate() ?? DateTime.now(),
      category: map['category'] ?? 'RECENT',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'category': category,
    };
  }
}
