import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService with ChangeNotifier {
  // Client instance - dynamically selected based on platform
  MqttServerClient? _client;

  // Connection settings
  final String _clientId =
      'flutter_app_${DateTime.now().millisecondsSinceEpoch}';
  final String _topic = 'data/1dv027';

  // State variables
  bool _isConnected = false;
  final List<Map<String, dynamic>> _sensorData = [];
  String _connectionStatus = "Not connected";
  bool _isLoading = false;

  // Getters
  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get sensorData => _sensorData;
  String get connectionStatus => _connectionStatus;
  bool get isLoading => _isLoading;

  Future<void> initializeMqtt() async {
    _isLoading = true;
    _connectionStatus = "Connecting...";
    notifyListeners();

    debugPrint('Initializing MQTT connection...');

    try {
      // Create the MQTT client
      _client = MqttServerClient('cscloud7-148.lnu.se', _clientId);
      _client!.port = 1883;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;

      // Set callbacks
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      // Set connection message
      final connMess = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .authenticateAs('iotlab', 'iotlab')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMess;

      await _client!.connect();

      // Check connection status
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('MQTT client connected');
        _isConnected = true;
        _isLoading = false;
        _connectionStatus = "Connected";
        _subscribeToTopic();
        notifyListeners();
      } else {
        debugPrint(
          'MQTT client connection failed - status is ${_client!.connectionStatus}',
        );
        _connectionStatus =
            "Connection failed: ${_client!.connectionStatus!.state.toString()}";
        _client!.disconnect();
        _isConnected = false;
      }
    } catch (e) {
      _connectionStatus = "Error: ${e.toString()}";
      debugPrint('MQTT setup error: $e');
      _isConnected = false;

      // Special handling for common errors
      if (e.toString().contains('SecurityContext')) {
        debugPrint('Security context error - this is common on web platforms');
        _connectionStatus =
            "Web connection security error - try using non-secure connection";
      } else if (e.toString().contains('Connection refused')) {
        _connectionStatus =
            "Connection refused - check broker address and port";
      }

      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _onConnected() {
    debugPrint('Connected to MQTT broker');
    _isConnected = true;
    _isLoading = false;
    _connectionStatus = "Connected";
    _subscribeToTopic();
    notifyListeners();
  }

  void _onDisconnected() {
    debugPrint('Disconnected from MQTT broker');
    _isConnected = false;
    _connectionStatus = "Disconnected";
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to topic: $topic');
    _connectionStatus = "Subscribed to $topic";
    notifyListeners();
  }

  void _subscribeToTopic() {
    debugPrint('Subscribing to $_topic');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      debugPrint('RECEIVED: Topic=${c[0].topic}, Message=$payload');

      try {
        final Map<String, dynamic> data = json.decode(payload);
        // Add timestamp if not present
        if (!data.containsKey('timestamp')) {
          data['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        }

        // Map fields from the MQTT format
        _sensorData.add({
          'temperature': data['temperature_celsius'] ?? data['temperature'],
          'humidity': data['humidity_percent'] ?? data['humidity'],
          'timestamp': data['timestamp'],
        });

        if (_sensorData.length > 100) {
          // Keep only the last 100 readings to prevent memory issues
          _sensorData.removeAt(0);
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
      }
    });
  }

  void disconnect() {
    if (_client != null &&
        _client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
  }

  // Get all temperature readings
  List<Map<String, dynamic>> getTemperatureReadings() {
    return _sensorData.map((data) {
      try {
        final temp = data['temperature'];
        final value =
            temp != null ? double.tryParse(temp.toString()) ?? 0.0 : 0.0;
        return {'timestamp': data['timestamp'], 'value': value};
      } catch (e) {
        debugPrint('Error parsing temperature: $e');
        return {'timestamp': data['timestamp'], 'value': 0.0};
      }
    }).toList();
  }

  // Get all humidity readings
  List<Map<String, dynamic>> getHumidityReadings() {
    return _sensorData.map((data) {
      try {
        final humidity = data['humidity'];
        final value =
            humidity != null
                ? double.tryParse(humidity.toString()) ?? 0.0
                : 0.0;
        return {'timestamp': data['timestamp'], 'value': value};
      } catch (e) {
        debugPrint('Error parsing humidity: $e');
        return {'timestamp': data['timestamp'], 'value': 0.0};
      }
    }).toList();
  }

  // Get latest temperature reading
  double? getLatestTemperature() {
    if (_sensorData.isEmpty) return null;
    try {
      final temp = _sensorData.last['temperature'];
      return temp != null ? double.tryParse(temp.toString()) : null;
    } catch (e) {
      debugPrint('Error getting latest temperature: $e');
      return null;
    }
  }

  // Get latest humidity reading
  double? getLatestHumidity() {
    if (_sensorData.isEmpty) return null;
    try {
      final humidity = _sensorData.last['humidity'];
      return humidity != null ? double.tryParse(humidity.toString()) : null;
    } catch (e) {
      debugPrint('Error getting latest humidity: $e');
      return null;
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
