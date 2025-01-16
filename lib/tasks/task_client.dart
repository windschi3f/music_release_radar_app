import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/base_http_client.dart';
import 'dart:convert';
import 'task.dart';
import 'package:music_release_radar_app/tasks/added_items/added_item.dart';
import 'package:music_release_radar_app/tasks/task_client_exception.dart';
import 'package:music_release_radar_app/tasks/task_item.dart';
import 'package:music_release_radar_app/tasks/task_item_request_dto.dart';
import 'package:music_release_radar_app/tasks/task_request_dto.dart';

class TaskClient extends BaseHttpClient {
  final String _endpoint;

  TaskClient()
      : _endpoint = dotenv.env['MUSIC_RELEASE_RADAR_SERVICE_ENDPOINT'] ?? '' {
    if (_endpoint.isEmpty) {
      throw TaskClientException('Missing service endpoint in .env file');
    }
  }

  Future<List<Task>> getTasks(String accessToken) => handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/tasks'),
          headers: getHeaders(accessToken),
        ),
        (json) => (json as List).map((task) => Task.fromJson(task)).toList(),
      );

  Future<Task> createTask(String accessToken, TaskRequestDto task) =>
      handleRequest(
        () => http.post(
          Uri.parse('$_endpoint/tasks'),
          headers: getHeaders(accessToken, contentType: 'application/json'),
          body: jsonEncode(task.toJson()),
        ),
        (json) => Task.fromJson(json),
      );

  Future<void> deleteTask(String accessToken, int taskId) => handleRequest(
        () => http.delete(
          Uri.parse('$_endpoint/tasks/$taskId'),
          headers: getHeaders(accessToken),
        ),
        (_) => {},
      );

  Future<void> executeTask(String accessToken, int taskId) => handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/tasks/$taskId/execute'),
          headers: getHeaders(accessToken),
        ),
        (_) => {},
      );

  Future<void> addTaskItems(
    String accessToken,
    int taskId,
    List<TaskItemRequestDto> taskItemDtos,
  ) =>
      handleRequest(
        () => http.post(
          Uri.parse('$_endpoint/tasks/$taskId/items'),
          headers: getHeaders(accessToken, contentType: 'application/json'),
          body: jsonEncode(taskItemDtos.map((item) => item.toJson()).toList()),
        ),
        (_) => {},
      );

  Future<List<TaskItem>> getTaskItems(String accessToken, int taskId) =>
      handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/tasks/$taskId/items'),
          headers: getHeaders(accessToken),
        ),
        (json) =>
            (json as List).map((item) => TaskItem.fromJson(item)).toList(),
      );

  Future<List<AddedItem>> getAddedItems(String accessToken, int taskId) =>
      handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/tasks/$taskId/added-items'),
          headers: getHeaders(accessToken),
        ),
        (json) =>
            (json as List).map((item) => AddedItem.fromJson(item)).toList(),
      );
}
