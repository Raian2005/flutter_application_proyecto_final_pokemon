import 'dart:convert';

import 'package:flutter_application_proyecto_final_pokemon/core/errors/failures.dart';
import 'package:http/http.dart' as http;

class GraphqlClient {
  GraphqlClient({
    http.Client? client,
    this.endpoint = 'https://beta.pokeapi.co/graphql/v1beta2',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String endpoint;

  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const {},
  }) async {
    final response = await _client.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': document, 'variables': variables}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteFailure('GraphQL respondió con HTTP ${response.statusCode}.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map) {
      throw const RemoteFailure(
        'La respuesta GraphQL no tiene un formato válido.',
      );
    }
    final result = Map<String, dynamic>.from(body);
    if (result['errors'] != null) {
      throw RemoteFailure('GraphQL devolvió errores: ${result['errors']}');
    }
    final data = result['data'];
    if (data is! Map) {
      throw const RemoteFailure('GraphQL no devolvió datos.');
    }
    return Map<String, dynamic>.from(data);
  }
}
