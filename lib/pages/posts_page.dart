import 'package:flutter/material.dart';
import '../services/article_service.dart';
import 'focus_post_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<dynamic> _articles = []; // laisser comme avant
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res =
          await ArticleService.getAllArticles(); // now returns List<dynamic>
      setState(() {
        _articles = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _extractId(dynamic item) {
    if (item == null) return null;
    if (item is int) return item;
    try {
      if (item is Map)
        return item['id'] is int ? item['id'] : int.tryParse('${item['id']}');
      if (item is String) return int.tryParse(item);
      // If it's a model with an id getter
      final v = (item as dynamic).id;
      if (v is int) return v;
      return int.tryParse('$v');
    } catch (_) {
      return null;
    }
  }

  String _extractTitle(dynamic item) {
    if (item == null) return 'Sans titre';
    if (item is Map) return item['title']?.toString() ?? 'Sans titre';
    try {
      final t = (item as dynamic).title;
      return t?.toString() ?? 'Sans titre';
    } catch (_) {
      return item.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erreur: $_error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadArticles,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final article = _articles[index];
            final id = _extractId(article);
            final title = _extractTitle(article);
            return ListTile(
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impossible d\'ouvrir le post'),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostFocus(postId: id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}