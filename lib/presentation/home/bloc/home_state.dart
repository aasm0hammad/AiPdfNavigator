import 'package:flutter/foundation.dart';
import '../../../../data/models/conversation_model.dart';

@immutable
abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ConversationModel> conversations;
  HomeLoaded(this.conversations);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
