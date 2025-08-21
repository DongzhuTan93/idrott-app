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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
                final isLoading = mqttService.isLoading;
                final isConnected = mqttService.isConnected;
                final hasData = mqttService.sensorData.isNotEmpty;

                // Show loading indicators when connecting or waiting for first data
                if (isLoading || (isConnected && !hasData)) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildLoadingSensorCard(
                          'Temperature',
                          Icons.thermostat,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLoadingSensorCard(
                          'Humidity',
                          Icons.water_drop,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildSensorCard(
                        'Temperature',
                        temperature != null ? '$temperature°C' : 'N/A',
                        Icons.thermostat,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSensorCard(
                        'Humidity',
                        humidity != null ? '$humidity%' : 'N/A',
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
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<MqttService>(
                  builder: (context, mqttService, child) {
                    final temperatureData =
                        mqttService.getTemperatureReadings();
                    final isLoading = mqttService.isLoading;
                    final hasEnoughData = _shouldShowCharts(mqttService);

                    // Show loading indicator until we have enough data points
                    if (isLoading || !hasEnoughData) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentGreen,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Loading temperature chart...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }

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
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<MqttService>(
                  builder: (context, mqttService, child) {
                    final humidityData = mqttService.getHumidityReadings();
                    final isLoading = mqttService.isLoading;
                    final hasEnoughData = _shouldShowCharts(mqttService);

                    // Show loading indicator until we have enough data points
                    if (isLoading || !hasEnoughData) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentGreen,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Loading humidity chart...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }

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
            ),

            // Debug Section
            const SizedBox(height: 24),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
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
                              'Topic: data/1dv027',
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
        color: AppColors.cardBackground,
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
        color: AppColors.cardBackground,
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

  LineChartData _buildTemperatureLineChart(List<Map<String, dynamic>> data) {
    final List<FlSpot> spots = [];

    // If we have too few data points, create a small "wave" pattern instead of a straight line
    if (data.length <= 2) {
      // Generate a simulated wave using the available temperature value
      double baseValue =
          data.isNotEmpty
              ? (data.first['value']?.toDouble() ?? 20.0)
              : 20.0; // Default value if no data

      // Create a small wave pattern instead of a straight line
      spots.add(FlSpot(0, baseValue));
      spots.add(FlSpot(1, baseValue + 0.2));
      spots.add(FlSpot(2, baseValue - 0.1));
      spots.add(FlSpot(3, baseValue + 0.3));
      spots.add(FlSpot(4, baseValue));
    } else {
      // Normal case - we have enough real data points
      for (int i = 0; i < data.length; i++) {
        final value = data[i]['value']?.toDouble() ?? 0.0;
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    // Calculate min and max Y values for the scale
    double minY =
        data.isEmpty
            ? 15.0 // Default minimum if no data
            : (_getMinValue(data) - 2);

    double maxY =
        data.isEmpty
            ? 25.0 // Default maximum if no data
            : (_getMaxValue(data) + 2);

    // Ensure minY starts at 0 if the minimum is close to 0
    if (minY > 0 && minY < 5) {
      minY = 0;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5, // Display horizontal grid lines every 5 units
        verticalInterval: 1, // Display vertical grid lines every 1 unit
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // Only show integers
              if (value.toInt() == value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Temperature (°C)',
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.accentGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.accentGreen.withAlpha(51),
          ),
        ),
      ],
      minY: minY,
      maxY: maxY,
    );
  }

  LineChartData _buildHumidityLineChart(List<Map<String, dynamic>> data) {
    final List<FlSpot> spots = [];

    // If we have too few data points, create a small "wave" pattern instead of a straight line
    if (data.length <= 2) {
      // Generate a simulated wave using the available humidity value
      double baseValue =
          data.isNotEmpty
              ? (data.first['value']?.toDouble() ?? 50.0)
              : 50.0; // Default value if no data

      // Create a small wave pattern instead of a straight line
      spots.add(FlSpot(0, baseValue));
      spots.add(FlSpot(1, baseValue - 2));
      spots.add(FlSpot(2, baseValue + 1));
      spots.add(FlSpot(3, baseValue - 1));
      spots.add(FlSpot(4, baseValue));
    } else {
      // Normal case - we have enough real data points
      for (int i = 0; i < data.length; i++) {
        final value = data[i]['value']?.toDouble() ?? 0.0;
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    // Calculate min and max Y values for the scale
    double minY =
        data.isEmpty
            ? 40.0 // Default minimum if no data
            : (_getMinValue(data) - 5);

    double maxY =
        data.isEmpty
            ? 60.0 // Default maximum if no data
            : (_getMaxValue(data) + 5);

    // Ensure minY starts at 0 if the minimum is close to 0
    if (minY > 0 && minY < 10) {
      minY = 0;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10, // Display horizontal grid lines every 10 units
        verticalInterval: 1, // Display vertical grid lines every 1 unit
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // Only show integers
              if (value.toInt() == value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Humidity (%)',
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),
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
      minY: minY,
      maxY: maxY,
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

  bool _shouldShowCharts(MqttService mqttService) {
    // Return true even with minimal data, since our chart builders now handle this case
    return mqttService.isConnected;
  }
}
