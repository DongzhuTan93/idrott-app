import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/add_user_screen.dart';
import 'screens/admin/user_list_screen.dart';

void main() {
  runApp(const IdrrottApp());
}

class IdrrottApp extends StatelessWidget {
  const IdrrottApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idrott App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007340)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/add-user': (context) => const AddUserScreen(),
        '/admin/users': (context) => const UserListScreen(),
        // Setting route can be added when implemented
        // '/admin/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
