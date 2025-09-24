class Interaction {
  final String? id;
  final String contact;
  final DateTime timeStamp;
  final String notes;
  final InteractionDetails interactionDetails;
  final String? readableString;

  Interaction({
    this.id,
    required this.contact,
    required this.timeStamp,
    required this.notes,
    required this.interactionDetails,
    this.readableString,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    // Handle EPOCH timestamp from API
    DateTime timestamp;
    if (json['timeStamp'] is String) {
      // If it's a string, parse it as milliseconds since epoch
      timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(json['timeStamp']));
    } else if (json['timeStamp'] is int) {
      // If it's already an int, use it directly
      timestamp = DateTime.fromMillisecondsSinceEpoch(json['timeStamp']);
    } else {
      // Fallback to current time if parsing fails
      timestamp = DateTime.now();
    }

    return Interaction(
      id: json['id'],
      contact: json['contact'] ?? '',
      timeStamp: timestamp,
      notes: json['notes'] ?? '',
      interactionDetails: InteractionDetails.fromJson(json['interactionDetails'] ?? {}),
      readableString: json['readableString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'timeStamp': timeStamp.millisecondsSinceEpoch.toString(),
      'notes': notes,
      'interactionDetails': interactionDetails.toJson(),
    };
  }
}

class InteractionDetails {
  final bool selfInitiated;
  final String type;

  InteractionDetails({
    required this.selfInitiated,
    required this.type,
  });

  factory InteractionDetails.fromJson(Map<String, dynamic> json) {
    String displayType;
    switch (json['type']) {
      case 'AUDIO_CALL':
        displayType = 'Audio Call';
        break;
      case 'VIDEO_CALL':
        displayType = 'Video Call';
        break;
      case 'TEXT':
        displayType = 'Text';
        break;
      case 'SOCIAL_MEDIA':
        displayType = 'Social Media';
        break;
      case 'IN_PERSON':
        displayType = 'In Person';
        break;
      default:
        displayType = json['type']?.toString().replaceAll('_', ' ') ?? '';
    }
    return InteractionDetails(
      selfInitiated: json['selfInitiated'] ?? false,
      type: displayType,
    );
  }

  Map<String, dynamic> toJson() {
    String apiType;
    switch (type) {
      case 'Audio Call':
        apiType = 'AUDIO_CALL';
        break;
      case 'Video Call':
        apiType = 'VIDEO_CALL';
        break;
      case 'Text':
        apiType = 'TEXT';
        break;
      case 'Social Media':
        apiType = 'SOCIAL_MEDIA';
        break;
      case 'In Person':
        apiType = 'IN_PERSON';
        break;
      default:
        apiType = type.replaceAll(' ', '_').toUpperCase();
    }
    return {
      'selfInitiated': selfInitiated,
      'type': apiType,
    };
  }
}