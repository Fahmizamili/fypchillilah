import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'saved.dart'; // Ensure this page exists

class ChiliSelectionPage extends StatefulWidget {
  @override
  _ChiliSelectionPageState createState() => _ChiliSelectionPageState();
}

class _ChiliSelectionPageState extends State<ChiliSelectionPage> {
  String? selectedStage;
  DateTime? selectedDate;
  TextEditingController nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSaving = false; // Loading indicator

  final Map<String, List<String>> stagePhases = {
    'Seeds': [
      'Phase 1: Seeds',
      'Phase 2: Transplanting Chili Sapling',
      'Phase 3: Vegetative Growth',
      'Phase 4: Mature Chili Plant',
      'Phase 5: Ripening & Harvesting'
    ],
    'Chili Sapling': [
      'Phase 2: Transplanting Chili Sapling',
      'Phase 3: Vegetative Growth',
      'Phase 4: Mature Chili Plant',
      'Phase 5: Ripening & Harvesting'
    ],
    'Mature Chili Plant': [
      'Phase 4: Mature Chili Plant',
      'Phase 5: Ripening & Harvesting'
    ]
  };

  final Map<String, int> phaseDurations = {
    'Phase 1: Seeds': 0,
    'Phase 2: Transplanting Chili Sapling': 14,
    'Phase 3: Vegetative Growth': 35,
    'Phase 4: Mature Chili Plant': 63,
    'Phase 5: Ripening & Harvesting': 98
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    if (selectedStage == null ||
        selectedDate == null ||
        nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields including name!')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore.collection('chili_plants').add({
        'name': nameController.text.trim(),
        'planting_stage': selectedStage,
        'start_date': selectedDate!.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data successfully saved!')),
      );

      setState(() {
        nameController.clear();
        selectedStage = null;
        selectedDate = null;
        isSaving = false;
      });
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Your Chili Plant',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter Plant Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon:
                    Icon(Icons.local_florist, color: Colors.green.shade700),
              ),
            ),
            SizedBox(height: 20),

            // Dropdown for Stage Selection
            DropdownButtonFormField<String>(
              value: selectedStage,
              decoration: InputDecoration(
                labelText: 'Select Stage',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.grass, color: Colors.green.shade700),
              ),
              items: stagePhases.keys.map((String stage) {
                return DropdownMenuItem<String>(
                  value: stage,
                  child: Text(stage),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStage = newValue;
                  selectedDate = null;
                });
              },
            ),
            SizedBox(height: 20),

            // Date Picker Input
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon:
                      Icon(Icons.calendar_today, color: Colors.green.shade700),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Select Start Date'
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Growth Phases Display
            if (selectedStage != null && selectedDate != null)
              Column(
                children: stagePhases[selectedStage]!.map((phase) {
                  DateTime phaseDate = selectedDate!.add(
                    Duration(
                      days: phaseDurations[phase]! -
                          phaseDurations[stagePhases[selectedStage]!.first]!,
                    ),
                  );
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.eco, color: Colors.green.shade700),
                      title: Text(
                        '$phase',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Estimated Date: ${DateFormat('dd/MM/yyyy').format(phaseDate)}',
                      ),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),

            // Save & View Records Buttons
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveToFirestore,
                    icon: isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(Icons.save, color: Colors.white),
                    label: Text('Save Plant Details',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChiliRecordsPage()),
                      );
                    },
                    icon: Icon(Icons.list, color: Colors.white),
                    label: Text('View Records',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 12),
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
}
