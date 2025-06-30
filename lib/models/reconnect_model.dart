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
      return OverdueStatus("Never contacted", Colors.grey);
    }

    final lastInteractionDate = DateTime.fromMillisecondsSinceEpoch(lastInteractionTimeStamp);
    final dueDate = lastInteractionDate.add(Duration(days: frequencyInDays));
    final now = DateTime.now();
    final differenceInDays = now.difference(dueDate).inDays;

    if (differenceInDays > 0) {
      return OverdueStatus("Overdue by $differenceInDays days", Colors.red);
    } else if (differenceInDays == 0) {
      return OverdueStatus("Due today", Colors.orange);
    } else {
      final daysUntilDue = -differenceInDays;
      return OverdueStatus("Due in $daysUntilDue days", Colors.green);
    }
  }
}