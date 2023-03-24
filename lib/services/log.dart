import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_spica/models/log.dart';
import 'package:flutter_spica/constants/constants.dart';

Future<List<Log>> fetchLogs(model, token) async {
  final response = await http.get(
      Uri.parse(
          '$LOGS_URL?startIndex=0&step=30&maxDate=${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)))}'),
      headers: {'Authorization': 'Bearer $token'});

  model.isLoading = false;
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    for (var log in jsonResponse) {
      model.addLog(Log.fromJson(log));
    }

    return jsonResponse.map((log) => Log.fromJson(log)).toList();
  } else {
    throw Exception('Failed to load logs from API');
  }
}
