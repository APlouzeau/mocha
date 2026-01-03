import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {
    'role': role,
    'content': content,
  };
}

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'meta-llama/llama-3.2-3b-instruct';

  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static const String _systemPrompt = '''Tu es l'Assistant Barista de MOCHA, le forum dédié aux boissons chaudes. Aide l'utilisateur à créer et enrichir son Topic.
    REGLE ABSOLUE : Tu ne parles QUE de boissons chaudes (café, thé, chocolat chaud, matcha, chai, tisanes, cappuccino, espresso, latte...). Si l'utilisateur sort du sujet, ramène-le vers les boissons chaudes avec humour.
    MISSIONS : Analyse le brouillon fourni. Crée des titres accrocheurs. Fournis infos, recettes ou conseils. Améliore les textes avec une touche "coffee culture".
    STYLE : Concis (mobile-friendly). Ton chaleureux et passionné. Reste TOUJOURS dans l'univers des boissons chaudes.
    FORMAT : Titre suggéré: [...] Description suggérée: [...]''';

  static Future<String> sendMessage({
    required String userMessage,
    required String currentTitle,
    required String currentContent,
    required List<ChatMessage> conversationHistory,
    required bool includeContext,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Clé API OpenRouter non configurée. Ajoutez OPENROUTER_API_KEY dans votre fichier .env');
    }

    // Construire le message utilisateur avec ou sans contexte
    String finalUserMessage = userMessage;
    if (includeContext) {
      final topicDraft = _buildTopicDraft(currentTitle, currentContent);
      if (topicDraft.isNotEmpty) {
        finalUserMessage = '$userMessage\n\nCONTEXTE ACTUEL DU BROUILLON :\n$topicDraft';
      }
    }
    
    // Construire les messages pour l'API
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ...conversationHistory.map((m) => m.toJson()),
      {'role': 'user', 'content': finalUserMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return content;
        }
        throw Exception('Réponse invalide de l\'API');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error']?['message'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: $e');
    }
  }

  static String _buildTopicDraft(String title, String content) {
    final parts = <String>[];
    if (title.isNotEmpty) {
      parts.add('Titre: $title');
    }
    if (content.isNotEmpty) {
      parts.add('Contenu: $content');
    }
    return parts.isEmpty ? '' : parts.join('\n');
  }
}

