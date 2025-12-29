import 'package:flutter/material.dart';
import '../services/article_service.dart';
import 'login_page.dart';
import '../helpers/auth_helper.dart';

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
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  setState(() => _submitting = true);
  try {
    final res = await ArticleService.postArticle(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      user_id: 1,
    );

    print('Réponse: $res');

    if (!mounted) return;

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Erreur inconnue')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post créé !')),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    
    // ← Vérifie avant de pop
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  } on UnauthorizedException {
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

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}