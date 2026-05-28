import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getConversations(String uid) {
    return _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MessageModel>> getMessages(String uid, String conversationId) {
    return _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Helper method to get the last ~N messages synchronously for API Context
  Future<List<Map<String, String>>> getHistoryContext(String uid, String conversationId, {int limit = 10}) async {
    var snapshot = await _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(limit)
        .get();
        
    List<Map<String, String>> history = [];
    var reversedDocs = snapshot.docs.reversed.toList();
    for (int i = 0; i < reversedDocs.length; i++) {
        var data = reversedDocs[i].data();
        history.add({
          "role": data["role"],
          "text": data["text"],
        });
    }
    return history;
  }

  Future<String> createConversation(String uid, {String title = "New Chat", String subtitle = "Ask me anything...", String category = "RECENT"}) async {
    DocumentReference doc = await _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .add({
      'title': title,
      'subtitle': subtitle,
      'time': DateTime.now(),
      'category': category,
    });
    return doc.id;
  }

  Future<void> addMessage(String uid, String conversationId, MessageModel message) async {
    await _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
        
    // Update conversation subtitle and sort time
    await _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'subtitle': message.text,
      'time': DateTime.now(),
    });
  }

  Future<void> deleteConversation(String uid, String conversationId) async {
    await _firestore
        .collection('UserChat')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }
}
