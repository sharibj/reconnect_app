class Contact {
  final String nickName;
  final String group;
  final ContactDetails details;

  Contact({
    required this.nickName,
    required this.group,
    required this.details,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      nickName: json['nickName'] ?? '',
      group: json['group'] ?? '',
      details: ContactDetails.fromJson(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickName': nickName,
      'group': group,
      'details': details.toJson(),
    };
  }
}

class ContactDetails {
  final String firstName;
  final String lastName;
  final String notes;
  final ContactInfo contactInfo;

  ContactDetails({
    required this.firstName,
    required this.lastName,
    required this.notes,
    required this.contactInfo,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      notes: json['notes'] ?? '',
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'notes': notes,
      'contactInfo': contactInfo.toJson(),
    };
  }
}

class ContactInfo {
  final String email;
  final String phone;
  final String address;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.address,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}