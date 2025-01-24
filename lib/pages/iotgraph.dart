import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("historical_data");

  List<FlSpot> soilMoistureData = [];
  List<FlSpot> humidityData = [];
  List<FlSpot> temperatureData = [];

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  void _fetchStoredData() {
    _databaseRef.orderByKey().once().then((snapshot) {
      final data = snapshot.snapshot.value as Map?;
      if (data != null) {
        List<FlSpot> soilData = [];
        List<FlSpot> humidityDataList = [];
        List<FlSpot> temperatureDataList = [];

        data.forEach((key, value) {
          double time =
              _toDouble(key) / 60000; // Convert milliseconds to minutes
          double soilMoisture = _toDouble(value["soil_moisture"]);
          double humidity = _toDouble(value["humidity"]);
          double temperature = _toDouble(value["temperature"]);

          soilData.add(FlSpot(time, soilMoisture));
          humidityDataList.add(FlSpot(time, humidity));
          temperatureDataList.add(FlSpot(time, temperature));
        });

        setState(() {
          soilMoistureData = soilData;
          humidityData = humidityDataList;
          temperatureData = temperatureDataList;
        });
      }
    });
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historical Data Graphs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child: _buildGraph(
                    "Soil Moisture", soilMoistureData, Colors.blue, 0, 100)),
            const SizedBox(height: 20),
            Expanded(
                child:
                    _buildGraph("Humidity", humidityData, Colors.teal, 0, 100)),
            const SizedBox(height: 20),
            Expanded(
                child: _buildGraph(
                    "Temperature", temperatureData, Colors.red, 10, 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Monitoring Page"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph(
      String title, List<FlSpot> data, Color color, double minY, double maxY) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text("${value.toInt()}",
                                  style: TextStyle(fontSize: 12));
                            })),
                    rightTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false)), // Hide right axis
                    topTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false)), // Hide top axis
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            getTitlesWidget: (value, meta) {
                              return Text("${value.toInt()} min",
                                  style: TextStyle(fontSize: 12));
                            })),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.black, width: 1),
                        bottom: BorderSide(color: Colors.black, width: 1),
                      )),
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: color,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
