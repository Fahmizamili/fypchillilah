import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskSchedulePage extends StatelessWidget {
  final String plantName;
  final String plantingStage;
  final String startDate;

  TaskSchedulePage({
    required this.plantName,
    required this.plantingStage,
    required this.startDate,
  });

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

  final Map<String, List<String>> phaseTasks = {
    'Phase 1: Seeds': [
      'Select chili variety',
      'Prepare the nursery site',
      'Soak seeds in warm water',
      'Sow seeds in soil medium',
      'water every couple of days, or when the soil feels dry. ',
      'Ensure seeds germinate within 5-10 days'
    ],
    'Phase 2: Transplanting Chili Sapling': [
      'Transfer seedlings to larger pots',
      'Fertilize seedlings with NPK 15:15:15',
      'Monitor for early pests & diseases'
    ],
    'Phase 3: Vegetative Growth': [
      'Use growth fertilizer ',
      'Perform early pruning',
      'Monitor for diseases',
      'Install support if necessary'
    ],
    'Phase 4: Mature Chili Plant': [
      'Use flowering fertilizer ',
      'Ensure pollination occurs',
      'Monitor for fruit borers & thrips infestation',
      'Water consistently'
    ],
    'Phase 5: Ripening & Harvesting': [
      'Chili fruits start ripening after 3 months',
      'Harvest gradually',
      'Continue replanting'
    ]
  };

  @override
  Widget build(BuildContext context) {
    DateTime parsedStartDate = DateTime.parse(startDate);
    String formattedStartDate =
        DateFormat('dd/MM/yyyy').format(parsedStartDate);

    List<String> phases = stagePhases[plantingStage] ?? [];

    String firstPhase = phases.first;
    DateTime firstPhaseDate = parsedStartDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Schedule'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cultivation Stage: $plantingStage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start Date: $formattedStartDate',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: phases.length,
                itemBuilder: (context, index) {
                  String phase = phases[index];
                  DateTime phaseDate;

                  if (index == 0) {
                    phaseDate = firstPhaseDate;
                  } else {
                    phaseDate = firstPhaseDate.add(Duration(
                        days: phaseDurations[phase]! -
                            phaseDurations[firstPhase]!));
                  }

                  String formattedPhaseDate =
                      DateFormat('dd/MM/yyyy').format(phaseDate);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phase Title
                          Text(
                            '$phase - $formattedPhaseDate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Divider(thickness: 1, color: Colors.green.shade200),

                          // Tasks List
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: phaseTasks[phase]!
                                .map((task) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 18,
                                              color: Colors.green.shade600),
                                          SizedBox(width: 8),
                                          Expanded(child: Text(task)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
