import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto_calculator_challenge/core/error/exceptions.dart';

class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Future<dynamic> get(String url, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    final response = await client.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ServerException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}
