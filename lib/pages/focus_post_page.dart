import 'package:flutter/material.dart';
import '../helpers/auth_helper.dart';
import '../models/user_model.dart';
import '../services/article_service.dart';
import '../services/comment_service.dart';
import 'login_page.dart';

class PostFocus extends StatefulWidget {
  final int postId;
  const PostFocus({super.key, required this.postId});

  @override
  State<PostFocus> createState() => _PostFocusState();
}

class _PostFocusState extends State<PostFocus> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _article;
  String? _authorName;
  List<Map<String, dynamic>> _comments = [];
  bool _loadingComments = true;

  final TextEditingController _commentController = TextEditingController();
  bool _sendingComment = false;
  UserModel? _currentUser;
  bool _showCommentComposer = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadArticle();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthHelper.getUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _submitComment() async {
    final user = _currentUser;
    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      await _loadCurrentUser();
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sendingComment = true);
    try {
      final res = await CommentService.postComment(
        comment: text,
        article_id: widget.postId,
        user_id: user.id,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        _commentController.clear();
        setState(() => _showCommentComposer = false);
        await _loadComments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? 'Erreur')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  void _cancelComment() {
    setState(() {
      _commentController.clear();
      _showCommentComposer = false;
    });
  }

  Widget _buildCommentComposer() {
    final isLoggedIn = _currentUser != null;

    if (!isLoggedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Connecte-toi pour commenter.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitComment,
            child: const Text('Se connecter'),
          ),
        ],
      );
    }

    if (!_showCommentComposer) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ElevatedButton(
          onPressed: () => setState(() => _showCommentComposer = true),
          child: const Text('Commenter'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          minLines: 4,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Écrire un commentaire',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _sendingComment ? null : _cancelComment,
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _sendingComment ? null : _submitComment,
              child:
                  _sendingComment
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Envoyer'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadArticle() async {
    setState(() {
      _loading = true;
      _error = null;
      _authorName = null;
      _comments = [];
      _loadingComments = true;
    });
    try {
      final res = await ArticleService.getArticle(id: widget.postId);
      if (res['success'] == true) {
        final Map<String, dynamic> articleMap = (res['article'] is Map)
            ? Map<String, dynamic>.from(res['article'])
            : {'title': null, 'content': null};
        final title = articleMap['title']?.toString();
        final content =
            articleMap['content']?.toString() ??
            articleMap['body']?.toString() ??
            '';
        // try extract author from common keys
        String? author;
        if (articleMap['author'] != null)
          author = articleMap['author'].toString();
        else if (articleMap['user'] is Map) {
          author =
              articleMap['user']['username']?.toString() ??
              articleMap['user']['name']?.toString();
        } else if (articleMap['user'] != null)
          author = articleMap['user'].toString();
        else if (articleMap['author_name'] != null)
          author = articleMap['author_name'].toString();

        setState(() {
          _article = {'title': title, 'content': content};
          _authorName = author ?? 'Auteur inconnu';
        });

        // load comments (don't block article display)
        _loadComments();
      } else {
        setState(() {
          _error = res['message']?.toString() ?? 'Erreur récupération article';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _loadingComments = true;
      _comments = [];
    });
    try {
      final res = await ArticleService.getComments(articleId: widget.postId);
      // assume backend returns comments in chronological order; if not, sort by timestamp if present
      final comments = res.map((c) => Map<String, dynamic>.from(c)).toList();

      // optional: sort by created_at if available (oldest first)
      comments.sort((a, b) {
        final ta = a['created_at'] ?? a['createdAt'] ?? a['date'];
        final tb = b['created_at'] ?? b['createdAt'] ?? b['date'];
        try {
          final da =
              DateTime.tryParse(ta?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final db =
              DateTime.tryParse(tb?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        } catch (_) {
          return 0;
        }
      });

      setState(() {
        _comments = comments;
      });
    } catch (e) {
      // keep comments empty but don't fail the page
      debugPrint('Erreur chargement commentaires: $e');
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Widget _buildCommentItem(Map<String, dynamic> c) {
    // compute author safely (avoid precedence issues)
    final String author;
    if (c['nick_name'] != null) {
      author = c['nick_name'].toString();
    } else if (c['user'] is Map) {
      author = (c['user']['username'] ?? c['user']['name'] ?? 'Anonyme')
          .toString();
    } else if (c['user'] != null) {
      author = c['user'].toString();
    } else {
      author = 'Anonyme';
    }

    final String text = (c['comment'] ?? c['text'] ?? c['message'] ?? '')
        .toString();
    final timeRaw = c['created_at'] ?? c['createdAt'] ?? c['date'];
    String timeStr = '';
    if (timeRaw != null) {
      final dt = DateTime.tryParse(timeRaw.toString());
      if (dt != null) {
        timeStr =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return ListTile(
      title: Text(author, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text.isNotEmpty) Text(text),
          if (timeStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                timeStr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: Center(child: Text(_error!)),
      );
    }
    final title = _article?['title']?.toString() ?? 'Sans titre';
    final content = _article?['content']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Par ${_authorName ?? 'Auteur inconnu'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Text(content, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commentaires',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_loadingComments)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_comments.isEmpty && !_loadingComments)
                const Text(
                  'Aucun commentaire',
                  style: TextStyle(color: Colors.grey),
                ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _buildCommentItem(_comments[i]),
              ),

              _buildCommentComposer(),
            ],
          ),
        ),
      ),
    );
  }
}
