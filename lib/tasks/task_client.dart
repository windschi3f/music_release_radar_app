import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/tasks/added_item.dart';
import 'package:music_release_radar_app/tasks/task_client_exception.dart';
import 'package:music_release_radar_app/tasks/task_item.dart';
import 'package:music_release_radar_app/tasks/task_item_request_dto.dart';
import 'package:music_release_radar_app/tasks/task_request_dto.dart';
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

  Future<Task> createTask(String accessToken, TaskRequestDto task) async {
    try {
      final response = await http.post(Uri.parse('$_endpoint/tasks'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(task.toJson()));
      if (response.statusCode == 201) {
        return Task.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw TaskClientException(
            'Failed to create task (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to create task: $e');
    }
  }

  Future<void> deleteTask(String accessToken, int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_endpoint/tasks/$taskId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 204) {
        throw TaskClientException('(${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to delete task: $e');
    }
  }

  Future<void> addTaskItems(String accessToken, int taskId,
      List<TaskItemRequestDto> taskItemDtos) async {
    try {
      final response = await http.post(
          Uri.parse('$_endpoint/tasks/$taskId/items'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(taskItemDtos.map((item) => item.toJson()).toList()));
      if (response.statusCode != 201) {
        throw TaskClientException(
            'Failed to create task items (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to create task items: $e');
    }
  }

  Future<List<TaskItem>> getTaskItems(String accessToken, int taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/tasks/$taskId/items'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final taskItemsJson = jsonDecode(response.body) as List;
        return taskItemsJson.map((item) => TaskItem.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw TaskClientException(
            'Failed to fetch task items (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to fetch task items: $e');
    }
  }

  Future<List<AddedItem>> getAddedItems(String accessToken, int taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/tasks/$taskId/added-items'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final addedItemsJson = jsonDecode(response.body) as List;
        return addedItemsJson.map((item) => AddedItem.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw TaskClientException(
            'Failed to fetch added items (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw TaskClientException('Failed to fetch added items: $e');
    }
  }
}
