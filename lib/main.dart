import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/routes.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/services/gemini_service.dart';

import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/home/bloc/home_bloc.dart';
import 'presentation/chat/bloc/chat_bloc.dart';
import 'presentation/pdf_summary/bloc/pdf_summary_bloc.dart';

import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/chat/chat_screen.dart';
import 'presentation/pdf_summary/pdf_summary_screen.dart';
import 'presentation/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  final String? uid = prefs.getString('id');

  runApp(MyApp(startRoute: uid != null ? AppRoutes.home : AppRoutes.login));
}

class MyApp extends StatelessWidget {
  final String startRoute;

  const MyApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ChatRepository()),
        RepositoryProvider(create: (_) => GeminiService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(authRepository: context.read<AuthRepository>())),
          BlocProvider(create: (context) => HomeBloc(chatRepository: context.read<ChatRepository>())),
          BlocProvider(create: (context) => ChatBloc(chatRepository: context.read<ChatRepository>(), geminiService: context.read<GeminiService>())),
          BlocProvider(create: (context) => PdfSummaryBloc(geminiService: context.read<GeminiService>())),
        ],
        child: MaterialApp(
          title: 'AI PDF Navigator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
             primarySwatch: Colors.pink,
          ),
          initialRoute: startRoute,
          routes: {
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.pdfSummary: (context) => const PdfSummaryScreen(),
            AppRoutes.profile: (context) => const ProfileScreen(),
          },
          onGenerateRoute: (settings) {
             if (settings.name == AppRoutes.chat) {
               final args = settings.arguments as Map<String, dynamic>? ?? {};
               return MaterialPageRoute(
                 builder: (context) => ChatScreen(args: args),
               );
             }
             return null;
          },
        ),
      ),
    );
  }
}