import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/users_data.dart';
import 'dart:developer' as developer;

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late List<User> _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    developer.log(
      'Loading users: ${UsersData.getAllUsers().length} total, ${UsersData.getNonAdminUsers().length} non-admin',
      name: 'UserListScreen',
    );
    // Get users from the global list
    final users = UsersData.getNonAdminUsers();

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(user.username),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                  leading: const Icon(Icons.email),
                ),
                ListTile(
                  title: const Text('Role'),
                  subtitle: Text(
                    user.isAdmin ? 'Administrator' : 'Regular User',
                  ),
                  leading: const Icon(Icons.admin_panel_settings),
                ),
                ListTile(
                  title: const Text('Created'),
                  subtitle: Text(
                    '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                  ),
                  leading: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: const Color(0xFF007340),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(
                child: Text('No users found. Add a new user to get started.'),
              )
              : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF007340),
                        child: Text(
                          user.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user.isAdmin)
                            const Chip(
                              label: Text(
                                'Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: Color(0xFF007340),
                            ),
               
                        ],
                      ),
                      onTap: () => _showUserDetails(user),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF007340),
        onPressed: () async {
          // Navigate to add user screen and wait for result
          final User? newUser =
              await Navigator.pushNamed(context, '/admin/add-user') as User?;

          // If a new user was returned, add it to the list
          if (newUser != null && mounted) {
            setState(() {
              _users.add(newUser);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
