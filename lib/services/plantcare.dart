import 'dart:convert';
import 'package:http/http.dart' as http;

class CropHealthService {
  final String apiKey = 'It2998Yi42mDDG7w7SiWoTM37u0DNaJqkcpiHcG3EYLf2nbpJX';
  final String endpoint = 'https://crop.kindwise.com/api/v1/identification';

  Future<dynamic> identifyCropHealth(List<String> base64Images,
      {double? latitude, double? longitude}) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': apiKey,
        },
        body: jsonEncode({
          'images': base64Images,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to identify crop health: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
