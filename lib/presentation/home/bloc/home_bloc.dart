import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/models/conversation_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class _ConversationsUpdated extends HomeEvent {
  final List<ConversationModel> conversations;
  _ConversationsUpdated(this.conversations);
}

class _ConversationsError extends HomeEvent {
  final String error;
  _ConversationsError(this.error);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _conversationSubscription;

  HomeBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(HomeLoading()) {
    on<FetchConversations>(_onFetchConversations);
    on<_ConversationsUpdated>((event, emit) => emit(HomeLoaded(event.conversations)));
    on<_ConversationsError>((event, emit) => emit(HomeError(event.error)));
  }

  void _onFetchConversations(FetchConversations event, Emitter<HomeState> emit) {
    emit(HomeLoading());
    _conversationSubscription?.cancel();
    
    _conversationSubscription = _chatRepository.getConversations(event.uid).listen(
      (conversations) {
        if (!isClosed) {
          add(_ConversationsUpdated(conversations));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_ConversationsError(error.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _conversationSubscription?.cancel();
    return super.close();
  }
}
