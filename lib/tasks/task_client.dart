import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/tasks/task_client_exception.dart';
import 'dart:convert';
import 'task.dart';

class TaskClient {
  final String _endpoint;

  TaskClient() : _endpoint = dotenv.env['TASKS_API_ENDPOINT'] ?? '' {
    if (_endpoint.isEmpty) {
      throw TaskClientException('Missing tasks API endpoint in .env file');
    }
  }

  Future<List<Task>> getTasks(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/tasks'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final tasksJson = jsonDecode(response.body) as List;
        return tasksJson.map((task) => Task.fromJson(task)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw TaskClientException(
            'Failed to fetch tasks (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to fetch tasks: $e');
    }
  }
}
