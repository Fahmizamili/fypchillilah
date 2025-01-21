import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RealtimeDataPage extends StatefulWidget {
  const RealtimeDataPage({Key? key}) : super(key: key);

  @override
  _RealtimeDataPageState createState() => _RealtimeDataPageState();
}

class _RealtimeDataPageState extends State<RealtimeDataPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("sensor");

  double _soilMoisture = 0;
  double _humidity = 0;
  double _temperature = 0;

  @override
  void initState() {
    super.initState();
    _listenToRealtimeDatabase();
  }

  // Method to listen for changes in the database
  void _listenToRealtimeDatabase() {
    _databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      setState(() {
        _soilMoisture = _toDouble(data?["soil_moisture"]);
        _humidity = _toDouble(data?["humidity"]);
        _temperature = _toDouble(data?["temperature"]);
      });
    });
  }

  // Method to fetch the latest data when the refresh button is pressed
  Future<void> _refreshData() async {
    final dataSnapshot = await _databaseRef.get();
    final data = dataSnapshot.value as Map?;
    setState(() {
      _soilMoisture = _toDouble(data?["soil_moisture"]);
      _humidity = _toDouble(data?["humidity"]);
      _temperature = _toDouble(data?["temperature"]);
    });
  }

  // Helper method to safely convert data to double
  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Monitoring'),
        centerTitle: true,
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
                  CircularSensor(
                    label: 'Soil Moisture',
                    icon: Icons.water_drop,
                    percentage: _soilMoisture.toInt(),
                    color: Colors.blue,
                  ),
                  CircularSensor(
                    label: 'Humidity',
                    icon: Icons.cloud,
                    percentage: _humidity.toInt(),
                    color: Colors.teal,
                  ),
                  CircularSensor(
                    label: 'Temperature',
                    icon: Icons.thermostat,
                    percentage: _temperature.toInt(),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularSensor extends StatelessWidget {
  final String label;
  final IconData icon;
  final int percentage;
  final Color color;

  const CircularSensor({
    Key? key,
    required this.label,
    required this.icon,
    required this.percentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 10,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 5),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
