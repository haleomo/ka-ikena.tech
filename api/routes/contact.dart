import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

const _resendEndpoint = 'https://api.resend.com/emails';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method == HttpMethod.options) {
    return _cors(Response(statusCode: HttpStatus.noContent));
  }

  if (request.method != HttpMethod.post) {
    return _cors(Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'error': 'Method not allowed'},
    ));
  }

  print('Received contact request: ${request.url}');

  final payload = await _readPayload(request);
  if (payload == null) {
    return _cors(Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid JSON payload'},
    ));
  }

  print('Extracting Payload: ${payload.toString()}');

  final name = (payload['name'] as String?)?.trim() ?? '';
  final email = (payload['email'] as String?)?.trim() ?? '';
  final message = (payload['message'] as String?)?.trim() ?? '';

  if (name.isEmpty || email.isEmpty || message.isEmpty) {
    return _cors(Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Name, email, and message are required.'},
    ));
  }


  final apiKey = Platform.environment['RESEND_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    return _cors(Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'RESEND_API_KEY is not configured.'},
    ));
  }

  final from = Platform.environment['RESEND_FROM'] ??
      "Ka 'Ikena <noreply@ask-my-geek.net>";

  print("Preparing to send email from $from with API key ${apiKey.substring(0, 4)}...");

  final subject = 'New contact request from $name';
  final text = _buildTextEmail(name: name, email: email, message: message);

  print("Sending email via Resend API to $from with subject '$subject'");
  final response = await http.post(    
    Uri.parse(_resendEndpoint),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $apiKey',
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    },
    body: jsonEncode({
      'from': from,
      'to': ['admin@ask-my-geek.net'],
      'subject': subject,
      'text': text,
      'reply_to': email,
    }),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return _cors(Response.json(body: {'status': 'sent'}));
  }

  return _cors(Response.json(
    statusCode: response.statusCode,
    body: {
      'error': 'Failed to send email.',
      'details': response.body,
    },
  ));
}

Future<Map<String, dynamic>?> _readPayload(Request request) async {
  try {
    final body = await request.body();
    if (body.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return decoded;
  } catch (e) {
    print("Error reading payload: $e");
    return null;
  }
}

String _buildTextEmail({
  required String name,
  required String email,
  required String message,
}) {
  return [
    'You received a new contact request.',
    '',
    'Name: $name',
    'Email: $email',
    '',
    'Message:',
    message,
  ].join('\n');
}

Response _cors(Response response) {
  return response.copyWith(
    headers: {
      ...response.headers,
      HttpHeaders.accessControlAllowOriginHeader: '*',
      HttpHeaders.accessControlAllowHeadersHeader: 'Content-Type',
      HttpHeaders.accessControlAllowMethodsHeader: 'POST, OPTIONS',
    },
  );
}
