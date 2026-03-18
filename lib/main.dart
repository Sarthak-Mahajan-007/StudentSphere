import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/firebase_service.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/admin/create_admin_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/events/admin_events_screen.dart';
import 'screens/resources/resources_list_screen.dart';
import 'screens/resources/admin_resources_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/hostel/hostel_application_screen.dart';
import 'screens/hostel/mess_menu_screen.dart';
import 'screens/hostel/hostel_manager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase → ONLY authentication
  await FirebaseService.initialize();

  // Supabase → database & storage
  await SupabaseService.initialize();

  runApp(const StudentSphereApp());
}

class StudentSphereApp extends StatelessWidget {
  const StudentSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ///  IMPORTANT: Initialize to restore user session
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(),
          update: (context, authProvider, chatProvider) {
            chatProvider!.setAuthProvider(authProvider);
            return chatProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'StudentSphere',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),

          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        /// 🚀 Routes for navigation
        routes: {
          '/create_admin': (context) => const CreateAdminScreen(),
          '/events': (context) => const EventsScreen(),
          '/admin_events': (context) => const AdminEventsScreen(),
          '/resources': (context) => const ResourcesListScreen(),
          '/admin_resources': (context) => const AdminResourcesScreen(),
          '/chat': (context) => const ChatListScreen(),
          '/hostel_application': (context) => const HostelApplicationScreen(),
          '/mess_menu': (context) => const MessMenuScreen(),
        },

        /// 🚀 AuthWrapper controls navigation
        home: const AuthWrapper(),
      ),
    );
  }
}
