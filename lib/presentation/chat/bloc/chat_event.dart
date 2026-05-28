import 'dart:typed_data';
import 'package:flutter/foundation.dart';

@immutable
abstract class ChatEvent {}

class LoadChatEvent extends ChatEvent {
  final String uid;
  final String conversationId;
  LoadChatEvent(this.uid, this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final String uid;
  final String text;
  SendMessageEvent(this.uid, this.text);
}

class SendPdfEvent extends ChatEvent {
  final String uid;
  final Uint8List bytes;
  final String fileName;
  SendPdfEvent(this.uid, this.bytes, this.fileName);
}
