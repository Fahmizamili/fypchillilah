import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

import 'iotgraph.dart';

class RealtimeDataPage extends StatefulWidget {
  const RealtimeDataPage({Key? key}) : super(key: key);

  @override
  _RealtimeDataPageState createState() => _RealtimeDataPageState();
}

class _RealtimeDataPageState extends State<RealtimeDataPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("sensor");
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _timer;

  double _soilMoisture = 0;
  double _humidity = 0;
  double _temperature = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startPeriodicUpdate();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final dataSnapshot = await _databaseRef.get();
    final data = dataSnapshot.value as Map?;
    setState(() {
      _soilMoisture = _toDouble(data?["soil_moisture"]);
      _humidity = _toDouble(data?["humidity"]);
      _temperature = _toDouble(data?["temperature"]);
    });
    _checkAndShowAlerts();
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  void _checkAndShowAlerts() {
    String? alertMessage;

    if (_soilMoisture < 60) {
      alertMessage = "The soil is too dry! Please water your chili plants.";
    } else if (_humidity < 50) {
      alertMessage = "Low humidity! Make sure the tree is not too dry.";
    } else if (_temperature > 30) {
      alertMessage =
          "The temperature is too high! Make sure the tree gets shade.";
    } else if (_temperature < 18) {
      alertMessage =
          "The temperature is too low! Place the tree in a warmer area.";
    }

    if (alertMessage != null) {
      _showAlertDialog(alertMessage);
      _sendNotification("Chili Tree Warning", alertMessage);
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Crop Alert"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Monitoring'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Real-Time Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Refresh Data'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  SensorCard(
                      label: 'Soil Moisture',
                      value: _soilMoisture,
                      icon: Icons.water_drop,
                      color: Colors.blue),
                  SensorCard(
                      label: 'Humidity',
                      value: _humidity,
                      icon: Icons.cloud,
                      color: Colors.teal),
                  SensorCard(
                      label: 'Temperature',
                      value: _temperature,
                      icon: Icons.thermostat,
                      color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const SensorCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text("${value.toStringAsFixed(1)}",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
