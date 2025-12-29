import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widgets/post_list_item.dart';

const bool kEnableMockPostsPage = true;

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  List<Map<String, dynamic>> _mockPosts() {
    final now = DateTime.now();
    return [
      {
        'title': 'Quel café pour bien débuter ?',
        'meta':
            'Post • ${now.subtract(const Duration(hours: 6)).toIso8601String()}',
        'excerpt': 'Je cherche un café pas trop amer, des idées ?',
      },
      {
        'title': 'Mouture et cafetière filtre',
        'meta':
            'Post • ${now.subtract(const Duration(days: 2)).toIso8601String()}',
        'excerpt': 'Vous conseillez quelle mouture pour une V60 ?',
      },
      {
        'title': 'Chocolat chaud maison',
        'meta':
            'Post • ${now.subtract(const Duration(days: 7)).toIso8601String()}',
        'excerpt': 'Recettes et astuces pour un chocolat épais et gourmand.',
      },
    ];
  }

  String _formatMeta(BuildContext context, String rawMeta) {
    final parts = rawMeta.split('•');
    if (parts.length != 2) return rawMeta;
    final label = parts[0].trim();
    final iso = parts[1].trim();

    try {
      final dt = DateTime.parse(iso).toLocal();
      final date = MaterialLocalizations.of(context).formatFullDate(dt);
      final time = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(dt),
        alwaysUse24HourFormat: true,
      );
      return '$label • $date à $time';
    } catch (_) {
      return rawMeta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMock = kEnableMockPostsPage && kDebugMode;

    return Scaffold(
      body: showMock
          ? Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mockPosts().length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = _mockPosts()[index];
                    return Card(
                      child: PostListItem(
                        icon: Icons.article_outlined,
                        title: (post['title'] as String?) ?? '-',
                        meta: _formatMeta(
                          context,
                          (post['meta'] as String?) ?? '-',
                        ),
                        excerpt: (post['excerpt'] as String?) ?? '-',
                      ),
                    );
                  },
                ),
              ),
            )
          : const Center(child: Text('Bienvenue sur la page des posts !')),
    );
  }
}
