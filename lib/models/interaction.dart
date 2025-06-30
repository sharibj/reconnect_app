class Interaction {
  final String contact;
  final DateTime timeStamp;
  final String notes;
  final InteractionDetails interactionDetails;

  Interaction({
    required this.contact,
    required this.timeStamp,
    required this.notes,
    required this.interactionDetails,
  });

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