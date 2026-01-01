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
  static const String _model = 'xiaomi/mimo-v2-flash';

  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static String _buildSystemPrompt(String topicDraft) {
    final draftText = topicDraft.isEmpty ? 'Aucun' : topicDraft;
    
    return '''Tu es l'Assistant Intelligent de l'application MOCA. Ton rôle est d'aider l'utilisateur à créer, affiner et enrichir son 'Topic' avant qu'il ne le publie.

CONTEXTE ACTUEL DU BROUILLON :
$draftText

TES MISSIONS :
Analyse du Contexte : Utilise toujours le texte ci-dessus (le brouillon) pour comprendre de quoi parle l'utilisateur. Si le brouillon est vide ou indique 'Aucun', considère que tu pars d'une page blanche.

Réponse aux Requêtes :

Si l'utilisateur demande de créer : Transforme ses idées en un titre accrocheur et une description structurée.

Si l'utilisateur demande des informations : Fournis des faits, des arguments ou des données basés sur le sujet du brouillon.

Si l'utilisateur demande une amélioration : Propose une version plus percutante ou mieux organisée du brouillon actuel.

DIRECTIVES DE STYLE :
Concision : Réponds avec des formats adaptés à un écran mobile (listes à puces, paragraphes courts).

Ton : Professionnel, inspirant et collaboratif.

Focus : Reste strictement concentré sur l'aide à la rédaction du topic. Ne divague pas.

Si l'utilisateur te demande quelque chose qui nécessite de modifier le brouillon, propose toujours une structure claire : Titre suggéré : [Ton titre] Description suggérée : [Ta description]''';
  }

  static Future<String> sendMessage({
    required String userMessage,
    required String currentTitle,
    required String currentContent,
    required List<ChatMessage> conversationHistory,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Clé API OpenRouter non configurée. Ajoutez OPENROUTER_API_KEY dans votre fichier .env');
    }

    // Construire le brouillon actuel
    final topicDraft = _buildTopicDraft(currentTitle, currentContent);
    
    // Construire les messages pour l'API
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt(topicDraft)},
      ...conversationHistory.map((m) => m.toJson()),
      {'role': 'user', 'content': userMessage},
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

