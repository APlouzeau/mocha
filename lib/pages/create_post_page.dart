import 'package:flutter/material.dart';
import '../services/article_service.dart';
import '../services/openrouter_service.dart';
import 'login_page.dart';
import 'focus_post_page.dart';
import '../helpers/auth_helper.dart';
import '../widgets/ai_assistant_panel.dart';

class CreatePostPage extends StatefulWidget {
  final int? articleId; // ID de l'article à modifier (null pour création)
  const CreatePostPage({super.key, this.articleId});

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
  bool _loadingArticle = false;

  // État persistant du chat IA
  final List<ChatMessage> _aiMessages = [];
  bool _aiIncludeContext = true;

  @override
  void initState() {
    super.initState();
    // Si on est en mode édition, charger l'article
    if (widget.articleId != null) {
      _loadArticle();
    }
  }

  Future<void> _loadArticle() async {
    if (widget.articleId == null) return;

    setState(() => _loadingArticle = true);
    try {
      final res = await ArticleService.getArticle(id: widget.articleId!);
      if (res['success'] == true && mounted) {
        final article = res['article'] as Map<String, dynamic>?;
        if (article != null) {
          _titleCtrl.text = article['title']?.toString() ?? '';
          _contentCtrl.text = article['content']?.toString() ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingArticle = false);
    }
  }

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
      Map<String, dynamic> result;
      
      // Si on est en mode édition, utiliser updateArticle
      if (widget.articleId != null) {
        result = await ArticleService.updateArticle(
          id: widget.articleId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
      } else {
        // Sinon, créer un nouvel article
        result = await ArticleService.postArticle(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          user_id: user['id'] as int,
        );
      }

      if (!mounted) return;

      if (result['success'] == true) {
        // Extraire l'ID de l'article (créé ou modifié)
        final data = result['data'] as Map<String, dynamic>?;
        final article = data?['article'] as Map<String, dynamic>?;
        final articleId = article?['id'] as int? ?? widget.articleId;

        if (articleId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.articleId != null
                    ? 'Post modifié !'
                    : 'Post créé !',
              ),
            ),
          );
          // En mode édition, remplacer la page d'édition ET la page de détail originale
          // pour qu'elles ne soient pas dans l'historique de navigation
          if (widget.articleId != null) {
            // Fermer la page d'édition
            Navigator.pop(context);
            // Remplacer la page de détail originale par la nouvelle page de détail
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PostFocus(postId: articleId)),
            );
          } else {
            // En mode création, navigation normale
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostFocus(postId: articleId)),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  (widget.articleId != null
                      ? 'Erreur lors de la modification'
                      : 'Erreur lors de la création'),
            ),
          ),
        );
      }
    } on UnauthorizedException {
      // redirection vers la page de login si pas connecté
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur création post : $e')));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.articleId != null
              ? 'Modifier le post'
              : 'Créer un post',
        ),
      ),
      body: Stack(
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
                    if (_loadingArticle) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                    ],
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Contenu requis'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.articleId != null
                                ? 'Modifier'
                                : 'Publier'),
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
      ),
    );
  }
}
