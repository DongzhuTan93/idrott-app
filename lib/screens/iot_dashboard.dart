import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mqtt_service.dart';
import '../theme/colors.dart';


class IoTDashboard extends StatefulWidget {
  const IoTDashboard({super.key});

  @override
  State<IoTDashboard> createState() => _IoTDashboardState();
}

class _IoTDashboardState extends State<IoTDashboard> {
  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  void _connectToMqtt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqttService = Provider.of<MqttService>(context, listen: false);
      mqttService.initializeMqtt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'IoT Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Consumer<MqttService>(
            builder: (context, mqttService, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            mqttService.isConnected
                                ? Colors.green.withAlpha(51)
                                : Colors.red.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mqttService.isConnected ? "Live Data" : "Disconnected",
                        style: TextStyle(
                          color:
                              mqttService.isConnected
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      mqttService.isConnected ? Icons.wifi : Icons.wifi_off,
                      color:
                          mqttService.isConnected ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sensor Readings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Current Readings
              Consumer<MqttService>(
                builder: (context, mqttService, child) {
                  final temperature = mqttService.getLatestTemperature();
                  final humidity = mqttService.getLatestHumidity();

                  return Row(
                    children: [
                      Expanded(
                        child: _buildSensorCard(
                          'Temperature',
                          temperature != null
                              ? '${temperature.toStringAsFixed(1)}°C'
                              : 'N/A',
                          Icons.thermostat,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSensorCard(
                          'Humidity',
                          humidity != null
                              ? '${humidity.toStringAsFixed(1)}%'
                              : 'N/A',
                          Icons.water_drop,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Temperature History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Temperature Chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<MqttService>(
                  builder: (context, mqttService, child) {
                    final temperatureData =
                        mqttService.getTemperatureReadings();
                    if (temperatureData.isEmpty) {
                      return const Center(
                        child: Text(
                          'No temperature data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return LineChart(
                      _buildTemperatureLineChart(temperatureData),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Humidity History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Humidity Chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<MqttService>(
                  builder: (context, mqttService, child) {
                    final humidityData = mqttService.getHumidityReadings();
                    if (humidityData.isEmpty) {
                      return const Center(
                        child: Text(
                          'No humidity data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return LineChart(_buildHumidityLineChart(humidityData));
                  },
                ),
              ),

              // Debug Section
              const SizedBox(height: 24),
              ExpansionTile(
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                title: const Text(
                  'Connection Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Consumer<MqttService>(
                      builder: (context, mqttService, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Broker: cscloud7-148.lnu.se:1883',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Topic: data/sht30',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Connection Status: ${mqttService.connectionStatus}',
                              style: TextStyle(
                                color:
                                    mqttService.isConnected
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            Text(
                              'Data Source: Direct MQTT Connection',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Data Points: ${mqttService.sensorData.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: _connectToMqtt,
                              child: const Text(
                                'Refresh Connection',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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
          ),
        ],
      ),
    );
  }

  LineChartData _buildTemperatureLineChart(List<Map<String, dynamic>> data) {
    final List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withAlpha(51),
          ),
        ),
      ],
      minY: _getMinValue(data) - 2,
      maxY: _getMaxValue(data) + 2,
    );
  }

  LineChartData _buildHumidityLineChart(List<Map<String, dynamic>> data) {
    final List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withAlpha(51),
          ),
        ),
      ],
      minY: _getMinValue(data) - 5,
      maxY: _getMaxValue(data) + 5,
    );
  }

  double _getMinValue(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    double min = data.first['value']?.toDouble() ?? 0;
    for (var item in data) {
      final value = item['value']?.toDouble() ?? 0;
      if (value < min) min = value;
    }
    return min;
  }

  double _getMaxValue(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    double max = data.first['value']?.toDouble() ?? 0;
    for (var item in data) {
      final value = item['value']?.toDouble() ?? 0;
      if (value > max) max = value;
    }
    return max;
  }
}
