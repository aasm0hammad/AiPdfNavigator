import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<HomeBloc>().add(FetchConversations(uid));
  }

  void _startNewChat() {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: {'isNew': true});
  }

  void _startPdfSummary() {
    Navigator.pushNamed(context, AppRoutes.pdfSummary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Text App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textDark),
                        onPressed: () {
                          // FirebaseAuth.instance.signOut(); Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                      ),
                    ),
                    const Text('Conversations', style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                         Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      child: StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.userChanges(),
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          return CircleAvatar(
                            backgroundColor: Colors.purple.shade200,
                            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                            child: user?.photoURL == null 
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),

              // Search Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _startPdfSummary,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(color: AppColors.iconPink, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.iconPink, blurRadius: 10, offset: Offset(0, 4))]),
                        child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: AppColors.textLight),
                            SizedBox(width: 8),
                            Text("Search", style: TextStyle(color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // List Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text("RECENT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 16),

              // Conversations List
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HomeError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is HomeLoaded) {
                      if (state.conversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 60, color: Colors.black.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              const Text("No conversations yet.\nTap + to start a chat!", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight)),
                            ]
                          )
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          final convo = state.conversations[index];
                          // Select a random mock icon color for aesthetic
                          final iconColors = [AppColors.iconPink, AppColors.iconBlue, AppColors.iconYellow, Colors.greenAccent];
                          final iconColor = iconColors[index % iconColors.length];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.white,
                                child: Icon(Icons.chat_bubble, color: iconColor),
                              ),
                              title: Text(convo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                              subtitle: Text(convo.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                              trailing: const Text("Now", style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.chat, arguments: {'conversationId': convo.id, 'title': convo.title});
                              },
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              
              // Bottom Action Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 32, right: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _startNewChat,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: AppColors.iconPink, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.iconPink, blurRadius: 10, offset: Offset(0, 2))]),
                        child: const Icon(Icons.add, color: AppColors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: AppColors.iconBlue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.iconBlue, blurRadius: 10, offset: Offset(0, 2))]),
                      child: const Icon(Icons.push_pin_outlined, color: AppColors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: AppColors.iconYellow, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.iconYellow, blurRadius: 10, offset: Offset(0, 2))]),
                      child: const Icon(Icons.delete_outline, color: AppColors.textDark),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
