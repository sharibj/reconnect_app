import 'package:flutter/material.dart';
import '../models/reconnect_model.dart';
import '../services/api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ReconnectModel> _outOfTouchContacts = [];
  bool _isLoading = false;
  Map<String, dynamic> _analytics = {};

  List<ReconnectModel> get outOfTouchContacts => _outOfTouchContacts;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get analytics => _analytics;

  Future<void> loadOutOfTouchContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _outOfTouchContacts = await _apiService.getOutOfTouchContacts();
      _calculateAnalytics();
    } catch (e) {
      debugPrint('Error loading out-of-touch contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateAnalytics() {
    if (_outOfTouchContacts.isEmpty) {
      _analytics = {
        'totalOutOfTouch': 0,
        'urgentCount': 0,
        'moderateCount': 0,
        'lowCount': 0,
        'overallHealthScore': 100.0,
        'groupBreakdown': <String, int>{},
        'urgencyDistribution': <String, int>{
          'Urgent': 0,
          'Moderate': 0,
          'Low': 0,
        },
      };
      return;
    }

    Map<String, int> urgencyCount = {
      'Urgent': 0,
      'Moderate': 0,
      'Low': 0,
    };

    Map<String, int> groupBreakdown = {};

    for (var contact in _outOfTouchContacts) {
      String status = contact.overdueStatus.status;

      if (status.contains('Very Overdue') || status.contains('Extremely Overdue')) {
        urgencyCount['Urgent'] = (urgencyCount['Urgent'] ?? 0) + 1;
      } else if (status.contains('Overdue')) {
        urgencyCount['Moderate'] = (urgencyCount['Moderate'] ?? 0) + 1;
      } else {
        urgencyCount['Low'] = (urgencyCount['Low'] ?? 0) + 1;
      }

      groupBreakdown[contact.group] = (groupBreakdown[contact.group] ?? 0) + 1;
    }

    double healthScore = _calculateHealthScore(urgencyCount);

    _analytics = {
      'totalOutOfTouch': _outOfTouchContacts.length,
      'urgentCount': urgencyCount['Urgent'] ?? 0,
      'moderateCount': urgencyCount['Moderate'] ?? 0,
      'lowCount': urgencyCount['Low'] ?? 0,
      'overallHealthScore': healthScore,
      'groupBreakdown': groupBreakdown,
      'urgencyDistribution': urgencyCount,
    };
  }

  double _calculateHealthScore(Map<String, int> urgencyCount) {
    int total = _outOfTouchContacts.length;
    if (total == 0) return 100.0;

    int urgent = urgencyCount['Urgent'] ?? 0;
    int moderate = urgencyCount['Moderate'] ?? 0;
    int low = urgencyCount['Low'] ?? 0;

    double score = 100.0 -
        (urgent * 30.0 + moderate * 15.0 + low * 5.0) / total;

    return score.clamp(0.0, 100.0);
  }

  Color getHealthScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  String getHealthScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  List<ReconnectModel> getContactsByUrgency(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return _outOfTouchContacts.where((contact) =>
          contact.overdueStatus.status.contains('Very Overdue') ||
          contact.overdueStatus.status.contains('Extremely Overdue')
        ).toList();
      case 'moderate':
        return _outOfTouchContacts.where((contact) =>
          contact.overdueStatus.status.contains('Overdue') &&
          !contact.overdueStatus.status.contains('Very Overdue') &&
          !contact.overdueStatus.status.contains('Extremely Overdue')
        ).toList();
      case 'low':
        return _outOfTouchContacts.where((contact) =>
          !contact.overdueStatus.status.contains('Overdue')
        ).toList();
      default:
        return _outOfTouchContacts;
    }
  }

  List<ReconnectModel> getContactsByGroup(String group) {
    return _outOfTouchContacts.where((contact) =>
      contact.group == group).toList();
  }

  int getTotalContacts() {
    return _outOfTouchContacts.length;
  }

  double getUrgencyPercentage(String urgency) {
    if (_outOfTouchContacts.isEmpty) return 0.0;

    Map<String, int> urgencyCount = _analytics['urgencyDistribution'] ?? {};
    int count = urgencyCount[urgency] ?? 0;

    return (count / _outOfTouchContacts.length) * 100;
  }

  List<MapEntry<String, int>> getTopGroups({int limit = 5}) {
    Map<String, int> groupBreakdown = _analytics['groupBreakdown'] ?? {};

    var sortedGroups = groupBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedGroups.take(limit).toList();
  }

  void refreshAnalytics() {
    _calculateAnalytics();
    notifyListeners();
  }
}