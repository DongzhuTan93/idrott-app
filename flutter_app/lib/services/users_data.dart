import '../models/user.dart';

// A global class to store users in memory
class UsersData {
  static final List<User> _users = [];

  static void addUser(User user) {
    _users.add(user);
  }

  static List<User> getAllUsers() {
    return List.from(_users);
  }

  static List<User> getNonAdminUsers() {
    return _users.where((user) => !user.isAdmin).toList();
  }

  static void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
  }
}
