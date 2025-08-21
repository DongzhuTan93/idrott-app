import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'backend_config.dart';

class LoadcellApiService with ChangeNotifier {
  bool _isConnected = false;
  bool _isTesting = false;
  Map<String, dynamic> _latestReading = {};
  Map<String, dynamic> _systemStatus = {};

  // Getters
  bool get isConnected => _isConnected;
  bool get isTesting => _isTesting;
  Map<String, dynamic> get latestReading => _latestReading;
  Map<String, dynamic> get systemStatus => _systemStatus;

  /// Check if the backend server is available
  Future<bool> checkConnection() async {
    try {
      // Auto-detect backend URL if not already detected
      if (!BackendConfig.isDetected) {
        debugPrint('Auto-detecting backend...');
        await BackendConfig.autoDetectBackend();
      }

      final response = await http
          .get(
            Uri.parse('${BackendConfig.baseUrl}/api/status'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _systemStatus = data;
        _isConnected = data['esp_connected'] ?? false;
        _isTesting = data['is_testing'] ?? false;

        debugPrint('Connected to backend: ${BackendConfig.baseUrl}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      debugPrint('Backend config: ${BackendConfig.getConnectionInfo()}');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Start a new test session
  Future<Map<String, dynamic>> startTest() async {
    try {
      final response = await http
          .post(
            Uri.parse('${BackendConfig.baseUrl}/api/start_test'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _isTesting = true;
        notifyListeners();
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      debugPrint('Start test failed: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Stop the current test session
  Future<Map<String, dynamic>> stopTest() async {
    try {
      final response = await http
          .post(
            Uri.parse('${BackendConfig.baseUrl}/api/stop_test'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _isTesting = false;
        notifyListeners();
        return {
          'success': true,
          'message': data['message'],
          'sample_count': data['sample_count'],
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      debugPrint('Stop test failed: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get the latest sensor reading
  Future<void> updateLatestReading() async {
    try {
      final response = await http
          .get(
            Uri.parse('${BackendConfig.baseUrl}/api/latest_reading'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _latestReading = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update latest reading failed: $e');
    }
  }

  /// Get current session data
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final response = await http
          .get(
            Uri.parse('${BackendConfig.baseUrl}/api/session_data'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get session data failed: $e');
      return null;
    }
  }

  /// Get system status
  Future<void> updateSystemStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('${BackendConfig.baseUrl}/api/status'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _systemStatus = data;
        _isConnected = data['esp_connected'] ?? false;
        _isTesting = data['is_testing'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update system status failed: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Start periodic status updates
  void startPeriodicUpdates() {
    // Update status every 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      await updateSystemStatus();
      await updateLatestReading();
      startPeriodicUpdates(); // Schedule next update
    });
  }

  /// Stop periodic updates (call when disposing)
  void stopPeriodicUpdates() {
    // This would require a more sophisticated implementation with Timer
    // For now, we rely on the widget lifecycle
  }
}
