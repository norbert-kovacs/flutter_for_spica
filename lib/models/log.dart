import 'dart:collection';
import 'package:flutter/material.dart';

class Tag {
  final String name;
  final String hexColor;

  Tag({
    required this.name,
    required this.hexColor,
  });
}

class Log {
  final String logName;
  final String logDescription;
  final DateTime logStartDate;
  final DateTime logEndDate;
  final List<Tag> logTags;

  Log({
    required this.logName,
    required this.logDescription,
    required this.logStartDate,
    required this.logEndDate,
    required this.logTags,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      logName: json['projectName'].toString(),
      logDescription: json['note'] ?? '',
      logStartDate: DateTime.parse(json['date']),
      logEndDate:
          DateTime.parse(json['date']).add(Duration(minutes: json['duration'])),
      logTags: json['tags'] != null
          ? (json['tags'] as List)
              .map((tag) => Tag(
                    name: tag['name'],
                    hexColor: tag['hexColor'],
                  ))
              .toList()
          : [],
    );
  }
}

class LogModel extends ChangeNotifier {
  final List<Log> _logs = [];
  bool _isLoading = true;

  UnmodifiableListView<Log> get logs => UnmodifiableListView(_logs);

  void addLog(Log log) {
    _logs.add(log);
    notifyListeners();
  }

  void removeLog(Log log) {
    _logs.remove(log);
    notifyListeners();
  }

  getLogsForDateIndex(int index) {
    // Get logs for the current week
    DateTime startDate = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1))
        .add(Duration(days: index));

    // Set time to 00:00:00
    startDate = DateTime(startDate.year, startDate.month, startDate.day);

    // Get logs that were started before or on, and ended after or on the current day
    return _logs.where((log) {
      return log.logStartDate
              .isBefore(startDate.add(const Duration(days: 1))) &&
          log.logEndDate.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
