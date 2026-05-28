import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../data/repositories/chat_repository.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_event.dart';
import 'bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const ChatScreen({super.key, required this.args});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _uid;
  String? _conversationId;
  String _title = "Loading...";

  Uint8List? _selectedPdfBytes;
  String? _selectedPdfName;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _initChat();
  }

  void _initChat() async {
    final bool isNew = widget.args['isNew'] ?? false;
    
    if (isNew) {
      _conversationId = await context.read<ChatRepository>().createConversation(_uid);
      if (mounted) {
        setState(() => _title = "New Chat");
        context.read<ChatBloc>().add(LoadChatEvent(_uid, _conversationId!));
      }
    } else {
      _conversationId = widget.args['conversationId'];
      _title = widget.args['title'] ?? 'Chat';
      if (mounted) {
         setState(() {});
         context.read<ChatBloc>().add(LoadChatEvent(_uid, _conversationId!));
      }
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();

    if (_selectedPdfBytes != null) {
      context.read<ChatBloc>().add(SendPdfEvent(_uid, _selectedPdfBytes!, _selectedPdfName!));
      setState(() {
        _selectedPdfBytes = null;
        _selectedPdfName = null;
      });
      _msgController.clear();
      return;
    }

    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessageEvent(_uid, text));
      _msgController.clear();
    }
  }

  void _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedPdfBytes = result.files.single.bytes;
        _selectedPdfName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Text App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Text(_title, style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                         Container(
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.volume_up_outlined, size: 20, color: AppColors.textDark),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                         Container(
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.ios_share, size: 20, color: AppColors.textDark),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Chat Area
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                     if (state is ChatError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                     }
                  },
                  builder: (context, state) {
                    if (state is ChatInitial || state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state is ChatLoaded) {
                      if (state.messages.isEmpty) {
                         return const Center(child: Text('Send a message to start!', style: TextStyle(color: AppColors.textLight)));
                      }
                      
                      return ListView.builder(
                        reverse: true, // Newest at bottom
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                           final msg = state.messages[index];
                           final isUser = msg.role == 'user';
                           return _buildMessageBubble(isUser, msg.text);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded && state.isSending) {
                     return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.iconPink),
                     );
                  }
                  return const SizedBox();
                }
              ),

              // Attachment Preview UI
              if (_selectedPdfName != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                         child: const Icon(Icons.folder, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(_selectedPdfName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPdfBytes = null;
                            _selectedPdfName = null;
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                ),

              // Bottom Input Area (White Pill)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_awesome, color: AppColors.textDark, size: 22),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppColors.textDark, size: 22),
                      onPressed: _pickPdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_none, color: AppColors.textDark, size: 22),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(
                          hintText: "Ask me anything...",
                          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.textDark, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
           color: isUser ? null : AppColors.aiBubble,
           gradient: isUser ? AppColors.userBubbleGradient : null,
           borderRadius: BorderRadius.only(
             topLeft: const Radius.circular(25),
             topRight: const Radius.circular(25),
             bottomLeft: Radius.circular(isUser ? 25 : 5),
             bottomRight: Radius.circular(isUser ? 5 : 25),
           ),
           boxShadow: [
             if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
             if (isUser) BoxShadow(color: AppColors.iconPink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
           ]
        ),
        child: isUser 
          ? Text(message, style: const TextStyle(color: AppColors.white, fontSize: 16))
          : MarkdownBody(
              data: message,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: AppColors.textDark, fontSize: 16, height: 1.5),
                code: TextStyle(color: AppColors.iconPink, backgroundColor: Colors.grey.shade100, fontFamily: 'monospace'),
                codeblockDecoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              ),
            ),
      ),
    );
  }
}
