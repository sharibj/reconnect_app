import 'package:flutter/material.dart';

class OverdueStatus {
  final String status;
  final Color color;
  OverdueStatus(this.status, this.color);
}

class ReconnectModel {
  final String nickName;
  final String group;
  final int frequencyInDays;
  final int lastInteractionTimeStamp;

  ReconnectModel({
    required this.nickName,
    required this.group,
    required this.frequencyInDays,
    required this.lastInteractionTimeStamp,
  });

  factory ReconnectModel.fromJson(Map<String, dynamic> json) {
    return ReconnectModel(
      nickName: json['nickName'] ?? '',
      group: json['group'] ?? '',
      frequencyInDays: json['frequencyInDays'] ?? 0,
      lastInteractionTimeStamp: json['lastInteractionTimeStamp'] ?? 0,
    );
  }

  OverdueStatus get overdueStatus {
    if (lastInteractionTimeStamp == 0) {
      return OverdueStatus("Never contacted", Colors.red.shade700);
    }

    final lastInteractionDate = DateTime.fromMillisecondsSinceEpoch(lastInteractionTimeStamp);
    final dueDate = lastInteractionDate.add(Duration(days: frequencyInDays));
    final now = DateTime.now();
    final overdueDays = now.difference(dueDate).inDays;

    if (overdueDays < 0) {
      // Not overdue yet - shouldn't be in needs attention
      final daysUntilDue = -overdueDays;
      return OverdueStatus("Due in $daysUntilDue days", Colors.grey);
    } else if (overdueDays == 0) {
      // Due today - classify as minor attention needed
      return OverdueStatus("Due today", Colors.green);
    }

    // Calculate urgency based on how overdue relative to frequency
    final urgencyRatio = overdueDays / frequencyInDays;

    if (urgencyRatio >= 1.0) {
      // More than 100% overdue (e.g., 20+ days overdue for 10-day frequency)
      return OverdueStatus("Overdue by $overdueDays days", Colors.red);
    } else if (urgencyRatio >= 0.5) {
      // 50-100% overdue (e.g., 15-20 days overdue for 10-day frequency)
      return OverdueStatus("Overdue by $overdueDays days", Colors.orange);
    } else {
      // Less than 50% overdue (e.g., 11-14 days overdue for 10-day frequency)
      return OverdueStatus("Overdue by $overdueDays days", Colors.green);
    }
  }
}