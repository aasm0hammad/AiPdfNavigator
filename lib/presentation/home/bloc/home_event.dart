import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {}

class FetchConversations extends HomeEvent {
  final String uid;

  FetchConversations(this.uid);
}
