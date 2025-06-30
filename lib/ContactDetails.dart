


class ContactDetails {
  final String? firstName;
  final String? lastName;
  final String? notes;
  final dynamic contactInfo;

  ContactDetails({this.firstName, this.lastName, this.notes, this.contactInfo});

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      firstName: json['firstName'],
      lastName: json['lastName'],
      notes: json['notes'],
      contactInfo: json['contactInfo'],
    );
  }
}

class Contact {
  final String nickName;
  final String group;
  final ContactDetails? details;

  Contact({required this.nickName, required this.group, this.details});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      nickName: json['nickName'],
      group: json['group'],
      details: json['details'] != null ? ContactDetails.fromJson(json['details']) : null,
    );
  }
}
