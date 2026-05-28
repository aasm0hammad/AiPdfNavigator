import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/services/gemini_service.dart';
import '../../../../data/models/message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class _MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;
  _MessagesUpdated(this.messages);
}

class _ChatError extends ChatEvent {
  final String error;
  _ChatError(this.error);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final GeminiService _geminiService;
  StreamSubscription? _messagesSubscription;
  String? _conversationId;

  ChatBloc({required ChatRepository chatRepository, required GeminiService geminiService})
      : _chatRepository = chatRepository,
        _geminiService = geminiService,
        super(ChatInitial()) {
    on<LoadChatEvent>(_onLoadChat);
    on<SendMessageEvent>(_onSendMessage);
    on<SendPdfEvent>(_onSendPdf);
    on<_MessagesUpdated>((event, emit) => emit(ChatLoaded(messages: event.messages)));
    on<_ChatError>((event, emit) => emit(ChatError(event.error)));
  }

  void _onLoadChat(LoadChatEvent event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    _conversationId = event.conversationId;
    _messagesSubscription?.cancel();
    
    _messagesSubscription = _chatRepository.getMessages(event.uid, event.conversationId).listen(
      (messages) {
        if (!isClosed) {
          add(_MessagesUpdated(messages));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_ChatError(error.toString()));
        }
      },
    );
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (_conversationId == null) return;
    
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(ChatLoaded(messages: currentState.messages, isSending: true));
    }

    try {
      // 1. Save user msg
      final userMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text,
        role: 'user',
        time: DateTime.now(),
      );
      await _chatRepository.addMessage(event.uid, _conversationId!, userMsg);

      // 2. Fetch context
      final history = await _chatRepository.getHistoryContext(event.uid, _conversationId!);

      // 3. Ask AI
      final aiResponse = await _geminiService.getChatResponse(event.text, history);

      // 4. Save AI msg
      final aiMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        role: 'ai',
        time: DateTime.now(),
      );
      await _chatRepository.addMessage(event.uid, _conversationId!, aiMsg);
      
    } catch (e) {
      if (!isClosed) add(_ChatError('Failed to send message: $e'));
    }
  }

  Future<void> _onSendPdf(SendPdfEvent event, Emitter<ChatState> emit) async {
    if (_conversationId == null) return;
    
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(ChatLoaded(messages: currentState.messages, isSending: true));
    }

    try {
      // 1. Save user msg indicating a PDF was uploaded
      final userMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '📄 Uploaded PDF: ${event.fileName}\n\nPlease summarize this document.',
        role: 'user',
        time: DateTime.now(),
      );
      await _chatRepository.addMessage(event.uid, _conversationId!, userMsg);

      // 2. Ask AI to summarize
      final aiResponse = await _geminiService.getPdfSummary(event.bytes);

      // 3. Save AI msg
      final aiMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        role: 'ai',
        time: DateTime.now(),
      );
      await _chatRepository.addMessage(event.uid, _conversationId!, aiMsg);
      
    } catch (e) {
      if (!isClosed) add(_ChatError('Failed to summarize PDF: $e'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
