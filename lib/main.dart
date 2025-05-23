import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/add_user_screen.dart';
import 'screens/admin/user_list_screen.dart';
import 'screens/iot_dashboard.dart';
import 'screens/add_user_success_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/user_test_dashboard.dart';
import 'services/mqtt_service.dart';

// Custom HTTP overrides to handle certificate issues - only for native platforms
class MyHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (io.X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // Set HTTP overrides for all mobile platforms
  io.HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MqttService())],
      child: const IdrrottApp(),
    ),
  );
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
        '/iot-dashboard': (context) => const IoTDashboard(),
        '/user-profile':
            (context) => UserProfileScreen(
              user: ModalRoute.of(context)!.settings.arguments as dynamic,
            ),
        // Setting route can be added when implemented
        // '/admin/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
