import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../lib/database/db.dart';
import '../lib/routes/auth_routes.dart';


void main() async {
  final db = Database();
  await db.connect();
  print('✅ Base de données connectée');
  
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  
  final router = Router();
  
  router.get('/hello', (Request request) {
    return Response.ok('Hello from Mocha Backend! 🎉');
  });
  
  router.get('/status', (Request request) {
    return Response.ok(
      '{"status": "running", "message": "Mocha API is alive"}',
      headers: {'Content-Type': 'application/json'},
    );
  });
  
  router.mount('/auth', authRoutes(db).call);
  
  final handler = Pipeline()
      .addMiddleware(logRequests()) 
      .addMiddleware(_corsHeaders())
      .addHandler(router.call);
  
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  
  print('🚀 Serveur Mocha Backend lancé !');
  print('📡 Écoute sur: http://${server.address.host}:${server.port}');
  print('🧪 Test: http://localhost:$port/hello');
  print('🔐 Auth: http://localhost:$port/auth/register');
}

Middleware _corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeadersMap);
      }
      
      final response = await handler(request);
      return response.change(headers: _corsHeadersMap);
    };
  };
}

final _corsHeadersMap = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
