import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// 🎯 TON PREMIER SERVEUR DART !
// Ce fichier est le point d'entrée de ton backend

void main() async {
  // Configuration du port (où le serveur écoute)
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  
  // Création du routeur (va gérer toutes les routes)
  final router = Router();
  
  // 👋 Route de test simple pour vérifier que ça marche
  router.get('/hello', (Request request) {
    return Response.ok('Hello from Mocha Backend! 🎉');
  });
  
  // 📌 Route GET /status - Pour vérifier que le serveur tourne
  router.get('/status', (Request request) {
    return Response.ok(
      '{"status": "running", "message": "Mocha API is alive"}',
      headers: {'Content-Type': 'application/json'},
    );
  });
  
  // Middleware pour logger les requêtes (voir ce qui arrive au serveur)
  final handler = Pipeline()
      .addMiddleware(logRequests()) // Affiche chaque requête dans la console
      .addMiddleware(_corsHeaders()) // Permet à Flutter de se connecter
      .addHandler(router.call);
  
  // Démarrage du serveur
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  
  print('🚀 Serveur Mocha Backend lancé !');
  print('📡 Écoute sur: http://${server.address.host}:${server.port}');
  print('🧪 Test: http://localhost:$port/hello');
}

// 🌐 Middleware CORS - Permet à Flutter (frontend) de communiquer avec le backend
// Sans ça, le navigateur bloque les requêtes (sécurité)
Middleware _corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      // Si c'est une requête OPTIONS (pre-flight), on répond OK
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeadersMap);
      }
      
      // Sinon, on traite la requête normalement et on ajoute les headers CORS
      final response = await handler(request);
      return response.change(headers: _corsHeadersMap);
    };
  };
}

// Headers CORS qui autorisent tout (en dev, à restreindre en prod)
final _corsHeadersMap = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
