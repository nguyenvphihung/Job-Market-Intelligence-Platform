import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> getOverview() async {
    final response = await http.get(Uri.parse('$baseUrl/overview'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load overview data');
  }

  Future<List<dynamic>> getTrends() async {
    final response = await http.get(Uri.parse('$baseUrl/trends'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load trends data');
  }

  Future<List<dynamic>> getSkills() async {
    final response = await http.get(Uri.parse('$baseUrl/skills'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load skills data');
  }

  Future<List<dynamic>> getSalaries() async {
    final response = await http.get(Uri.parse('$baseUrl/salaries'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load salary data');
  }

  Future<List<dynamic>> getLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/locations'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load location data');
  }

  Future<Map<String, dynamic>> getJobs({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs?page=$page&limit=$limit')
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load jobs');
  }
}
