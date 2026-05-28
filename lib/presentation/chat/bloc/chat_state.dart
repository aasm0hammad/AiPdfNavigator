import 'package:flutter/foundation.dart';
import '../../../../data/models/message_model.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isSending;
  ChatLoaded({required this.messages, this.isSending = false});
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
