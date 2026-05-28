class MessageModel {
  final String id;
  final String text;
  final String role; // 'user' or 'ai'
  final DateTime time;

  MessageModel({
    required this.id,
    required this.text,
    required this.role,
    required this.time,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      role: map['role'] ?? 'user',
      time: map['time']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'role': role,
      'time': time,
    };
  }
}
