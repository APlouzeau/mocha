import 'package:flutter/material.dart';
import '../services/article_service.dart';
import '../services/openrouter_service.dart';
import 'login_page.dart';
import 'focus_post_page.dart';
import '../helpers/auth_helper.dart';
import '../widgets/ai_assistant_panel.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();
  bool _submitting = false;
  bool _showAIPanel = false;
  
  // État persistant du chat IA
  final List<ChatMessage> _aiMessages = [];
  bool _aiIncludeContext = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await AuthHelper.getUser();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ArticleService.postArticle(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        user_id: 1/* int.parse(_userIdCtrl.text.trim()) */,
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Extraire l'ID de l'article créé
        final data = result['data'] as Map<String, dynamic>?;
        final article = data?['article'] as Map<String, dynamic>?;
        final articleId = article?['id'] as int?;
        
        if (articleId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post créé !')),
          );
          // Fermer la page de création et rediriger vers la page de détail du nouvel article
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostFocus(postId: articleId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']?.toString() ?? 'Erreur lors de la création')),
        );
      }
    } on UnauthorizedException {
      // redirection vers la page de login si pas connecté
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur création post : $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toggleAIPanel() {
    setState(() {
      _showAIPanel = !_showAIPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Formulaire principal
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Créer un post',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Titre requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contenu',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Contenu requis' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Publier'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bouton flottant IA
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _toggleAIPanel,
            backgroundColor: const Color(0xFF6D4C41),
            foregroundColor: const Color(0xFFD2B48C),
            icon: Icon(_showAIPanel ? Icons.close : Icons.auto_awesome),
            label: Text(_showAIPanel ? 'Fermer' : 'Assistant IA'),
            tooltip: 'Ouvrir l\'assistant IA',
          ),
        ),
        // Panneau de chat IA
        if (_showAIPanel)
          AIAssistantPanel(
            titleController: _titleCtrl,
            contentController: _contentCtrl,
            onClose: _toggleAIPanel,
            messages: _aiMessages,
            includeContext: _aiIncludeContext,
            onIncludeContextChanged: (value) {
              setState(() => _aiIncludeContext = value);
            },
          ),
      ],
    );
  }
}
