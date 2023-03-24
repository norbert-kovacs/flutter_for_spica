import 'dart:async';
import 'dart:convert';
import 'package:flutter_spica/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> login() async {
  final response = await http.post(
    Uri.parse(LOGIN_URL),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'grantType': 'password',
      'email': dotenv.env['MH_EMAIL']!,
      'password': dotenv.env['MH_PASSWORD']!,
      'clientId': dotenv.env['MH_CLIENTID']!,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['accessToken'];
  } else {
    throw Exception(
        'Failed to login. Check your credentials in the .env file.');
  }
}
