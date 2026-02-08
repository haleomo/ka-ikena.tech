import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return _withCors(Response(statusCode: HttpStatus.noContent));
    }

    final response = await handler(context);
    return _withCors(response);
  };
}

Response _withCors(Response response) {
  return response.copyWith(
    headers: {
      ...response.headers,
      HttpHeaders.accessControlAllowOriginHeader: '*',
      HttpHeaders.accessControlAllowHeadersHeader: 'Content-Type',
      HttpHeaders.accessControlAllowMethodsHeader: 'POST, OPTIONS',
    },
  );
}
