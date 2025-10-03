import 'package:flutter/material.dart';
import '../models/reconnect_model.dart';
import '../screens/view_interactions_screen.dart';

class OutOfTouchContactCard extends StatelessWidget {
  final ReconnectModel contact;
  final VoidCallback? onTap;

  const OutOfTouchContactCard({
    super.key,
    required this.contact,
    this.onTap,
  });

  Color _getUrgencyColor() {
    // Use the color directly from the overdueStatus
    return contact.overdueStatus.color;
  }

  String _getLastContactText() {
    if (contact.lastInteractionTimeStamp == 0) {
      return 'Never contacted';
    }

    final lastInteractionDate = DateTime.fromMillisecondsSinceEpoch(contact.lastInteractionTimeStamp);
    final now = DateTime.now();
    final daysSince = now.difference(lastInteractionDate).inDays;

    if (daysSince == 0) {
      return 'Contacted today';
    } else if (daysSince == 1) {
      return 'Contacted yesterday';
    } else {
      return 'Last contact: $daysSince days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: urgencyColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewInteractionsScreen(
                  preselectedContactNickName: contact.nickName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      contact.nickName.isNotEmpty ? contact.nickName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.nickName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact.group,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLastContactText(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          urgencyColor.withValues(alpha: 0.1),
                          urgencyColor.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: urgencyColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      contact.overdueStatus.status,
                      style: TextStyle(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}