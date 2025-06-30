import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'ContactDetails.dart';

Future<List<Contact>> getContacts() async {
  String? contacts_api_url = dotenv.env['CONTACTS_API_URL'];
  var response = await http.get(Uri.parse(contacts_api_url!));
  List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Contact.fromJson(e)).toList();
}

void main() async {
  List<Contact> contacts = await getContacts();
  for (var contact in contacts) {
    print('NickName: ${contact.nickName}, Group: ${contact.group}');
    if (contact.details != null) {
      print(
        'Details: ${contact.details!.firstName} ${contact.details!.lastName}, Notes: ${contact.details!.notes}',
      );
      print('Contact Info: ${contact.details!.contactInfo}');
    }
  }
}
