import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../widgets/post_list_item.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? userId;
  String? nickName;
  String? email;
  String? roleId;
  String? createdAt;
  bool isLoading = true;
  String? errorMessage;

  static const bool _enableMockUserPosts = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          userId = map['id']?.toString();
          nickName = map['nickName']?.toString();
          email = map['email']?.toString();
          roleId = map['roleId']?.toString();
          createdAt = map['createdAt']?.toString();
          isLoading = false;
          errorMessage = null;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Impossible de lire les données du profil.';
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    }
  }

  List<Map<String, dynamic>> _mockUserPosts() {
    final now = DateTime.now();
    return [
      {
        'title': 'Mon setup café du moment',
        'meta':
            'Post • ${now.subtract(const Duration(hours: 3)).toIso8601String()}',
        'excerpt': 'Je vous partage mon combo moulin + V60 et mes réglages.',
      },
      {
        'title': 'Retour sur un café éthiopien',
        'meta':
            'Post • ${now.subtract(const Duration(days: 1, hours: 2)).toIso8601String()}',
        'excerpt':
            'Notes florales, acidité propre… vous avez des recommandations similaires ?',
      },
      {
        'title': 'Question mousse de lait',
        'meta':
            'Post • ${now.subtract(const Duration(days: 5)).toIso8601String()}',
        'excerpt': 'Je galère à obtenir une micro-mousse stable. Des tips ?',
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

  String _initialsFromNickName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  String _formatCreatedAt(BuildContext context, String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final date = MaterialLocalizations.of(context).formatFullDate(dt);
      final time = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(dt),
        alwaysUse24HourFormat: true,
      );
      return '$date • $time';
    } catch (_) {
      return isoString;
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (nickName == null &&
                email == null &&
                roleId == null &&
                createdAt == null)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vous n\'êtes pas connecté',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage ??
                          'Connectez-vous pour afficher votre profil.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                child: Text(
                                  _initialsFromNickName(nickName),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: colorScheme.onPrimary),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (nickName ?? '-').trim().isEmpty
                                          ? '-'
                                          : nickName!.trim(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (email ?? '-').trim().isEmpty
                                          ? '-'
                                          : email!.trim(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            _infoTile(
                              icon: Icons.alternate_email,
                              label: 'Email',
                              value: (email ?? '').trim(),
                            ),
                            const Divider(height: 1),
                            _infoTile(
                              icon: Icons.verified_user_outlined,
                              label: 'Rôle',
                              value: (roleId ?? '').trim(),
                            ),
                            const Divider(height: 1),
                            _infoTile(
                              icon: Icons.calendar_month_outlined,
                              label: 'Créé le',
                              value: _formatCreatedAt(context, createdAt),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Derniers posts',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_enableMockUserPosts)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _mockUserPosts().length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final post = _mockUserPosts()[index];
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
                        )
                      else
                        Text(
                          userId == null
                              ? 'Connectez-vous pour voir vos posts.'
                              : 'Aucun post à afficher.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
