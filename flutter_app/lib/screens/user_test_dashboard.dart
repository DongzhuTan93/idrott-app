import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/mqtt_service.dart';
import '../services/loadcell_api_service.dart';

class UserTestDashboard extends StatefulWidget {
  final User user;
  final String testType;

  const UserTestDashboard({
    super.key,
    required this.user,
    this.testType = 'Standard Test',
  });

  @override
  State<UserTestDashboard> createState() => _UserTestDashboardState();
}

class _UserTestDashboardState extends State<UserTestDashboard> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqttService = Provider.of<MqttService>(context, listen: false);
      mqttService.initializeMqtt();

      final loadcellApiService = Provider.of<LoadcellApiService>(
        context,
        listen: false,
      );
      loadcellApiService.checkConnection();
      loadcellApiService.startPeriodicUpdates();
    });
  }

  Future<void> _startTest() async {
    final loadcellApiService = Provider.of<LoadcellApiService>(
      context,
      listen: false,
    );
    final result = await loadcellApiService.startTest();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] ? result['message'] : result['error'],
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _stopTest() async {
    final loadcellApiService = Provider.of<LoadcellApiService>(
      context,
      listen: false,
    );
    final result = await loadcellApiService.stopTest();

    if (mounted) {
      String message =
          result['success']
              ? '${result['message']}\nSamples collected: ${result['sample_count']}'
              : result['error'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button section
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: const Color(0xFF75F94C),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'BACK',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF75F94C),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Consumer2<MqttService, LoadcellApiService>(
                    builder: (context, mqttService, loadcellApiService, child) {
                      final isLoadcellConnected =
                          loadcellApiService.isConnected;
                      final isTesting = loadcellApiService.isTesting;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Loadcell connection status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isLoadcellConnected
                                      ? Colors.green.withAlpha(51)
                                      : Colors.red.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLoadcellConnected
                                      ? "Loadcell Connected"
                                      : "Loadcell Offline",
                                  style: TextStyle(
                                    color:
                                        isLoadcellConnected
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLoadcellConnected
                                      ? Icons.sensors
                                      : Icons.sensors_off,
                                  color:
                                      isLoadcellConnected
                                          ? Colors.green
                                          : Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Test status
                          if (isLoadcellConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isTesting
                                        ? Colors.orange.withAlpha(51)
                                        : Colors.blue.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isTesting ? "Testing..." : "Ready",
                                    style: TextStyle(
                                      color:
                                          isTesting
                                              ? Colors.orange
                                              : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isTesting
                                        ? Icons.play_circle_filled
                                        : Icons.pause_circle_filled,
                                    color:
                                        isTesting ? Colors.orange : Colors.blue,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    // User name header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1919),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF007340),
                            radius: 20,
                            child: Text(
                              (widget.user.username.isNotEmpty
                                      ? widget.user.username[0]
                                      : '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${widget.testType} Session',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            DateTime.now().toString().substring(0, 16),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Test Control Buttons
                    Consumer<LoadcellApiService>(
                      builder: (context, loadcellApiService, child) {
                        final isConnected = loadcellApiService.isConnected;
                        final isTesting = loadcellApiService.isTesting;

                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    isConnected && !isTesting
                                        ? _startTest
                                        : null,
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'START TEST',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isConnected && !isTesting
                                          ? const Color(0xFF75F94C)
                                          : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    isConnected && isTesting ? _stopTest : null,
                                icon: const Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'STOP TEST',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isConnected && isTesting
                                          ? const Color(0xFF75F94C)
                                          : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Loadcell Readings Section
                    const Text(
                      'Loadcell Readings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Consumer<LoadcellApiService>(
                      builder: (context, loadcellApiService, child) {
                        final latestReading = loadcellApiService.latestReading;
                        final isConnected = loadcellApiService.isConnected;

                        if (!isConnected || latestReading.isEmpty) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildLoadingSensorCard(
                                  'Left Sensor',
                                  Icons.scale,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildLoadingSensorCard(
                                  'Right Sensor',
                                  Icons.scale,
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildSensorCard(
                                'Left Sensor',
                                '${latestReading['left'] ?? 0}',
                                Icons.scale,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSensorCard(
                                'Right Sensor',
                                '${latestReading['right'] ?? 0}',
                                Icons.scale,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.home, color: Colors.yellow, size: 30),
                  Icon(Icons.fitness_center, color: Colors.yellow, size: 30),
                  Icon(
                    Icons.insert_chart_outlined_rounded,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  Icon(Icons.person, color: Colors.yellow, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1919),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSensorCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1919),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
