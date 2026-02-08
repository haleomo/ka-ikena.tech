import 'package:dart_frog/dart_frog.dart';

import '../contact.dart' as root;

Future<Response> onRequest(RequestContext context) => root.onRequest(context);
