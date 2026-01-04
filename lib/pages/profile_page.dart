import 'package:flutter/material.dart';
import 'package:mocha/services/auth_service.dart';
import '../helpers/auth_helper.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? nickName;
  String? email;
  String? role;
  String? createdAt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthHelper.getUser();

    if (!mounted) return;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        nickName = user['nickName'] as String?;
        email = user['email'] as String?;
        role = user['role'] as String?;

        final createdAtStr = user['createdAt'];
        if (createdAtStr != null) {
          try {
            DateTime date;
            if (createdAtStr is String) {
              date = DateTime.parse(createdAtStr);
            } else if (createdAtStr is DateTime) {
              date = createdAtStr;
            } else {
              date = DateTime.now();
            }
            final months = [
              '',
              'janvier',
              'février',
              'mars',
              'avril',
              'mai',
              'juin',
              'juillet',
              'août',
              'septembre',
              'octobre',
              'novembre',
              'décembre',
            ];
            createdAt = '${date.day} ${months[date.month]} ${date.year}';
          } catch (e) {
            createdAt = null;
          }
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (nickName == null && email == null)
          ? const Center(
              child: Text(
                'Impossible de charger les données du profil',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6D4C41),
                      child: Text(
                        nickName != null && nickName!.isNotEmpty
                            ? nickName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Color(0xFFD2B48C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoCard(
                    'Pseudo',
                    nickName ?? '-',
                    onEdit: () => _showEditNickname(),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Email',
                    email ?? '-',
                    onEdit: () => _showEditEmail(),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard('Rôle', role ?? '-'),
                  if (createdAt != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard('Membre depuis', createdAt!),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showChangePassword,
                      icon: const Icon(Icons.lock),
                      label: const Text('Changer le mot de passe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4C41),
                        foregroundColor: const Color(0xFFD2B48C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value, {VoidCallback? onEdit}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF6D4C41), size: 20),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  // Modifier le pseudo
  Future<void> _showEditNickname() async {
    final controller = TextEditingController(text: nickName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le pseudo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouveau pseudo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != nickName) {
      await _updateProfile(nickName: result);
    }
  }

  // Modifier l'email
  Future<void> _showEditEmail() async {
    final controller = TextEditingController(text: email);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouvel email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != email) {
      await _updateProfile(email: result);
    }
  }

  // Changer le mot de passe
  Future<void> _showChangePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Ancien mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context, {
                  'oldPassword': oldPasswordController.text,
                  'newPassword': newPasswordController.text,
                  'newPasswordConfirm': confirmPasswordController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _updatePassword(
        result['oldPassword']!,
        result['newPassword']!,
        result['newPasswordConfirm']!,
      );
    }
  }

  Future<void> _updateProfile({String? nickName, String? email}) async {
    final token = await AuthHelper.getToken();
    if (token == null) return;

    try {
      final body = <String, dynamic>{};
      if (nickName != null) body['nickName'] = nickName;
      if (email != null) body['email'] = email;

      final response = await AuthService.updateProfile(
        token: token,
        nickName: nickName,
        email: email,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final user = await AuthHelper.getUser();
        if (user != null) {
          if (nickName != null) user['nickName'] = nickName;
          if (email != null) user['email'] = email;
          await AuthHelper.saveAuth(token: token, user: user);
        }

        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response['message']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // Appeler l'API pour changer le mot de passe
  Future<void> _updatePassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirm,
  ) async {
    final token = await AuthHelper.getToken();
    if (token == null) return;

    try {
      final response = await AuthService.updatePassword(
        token: token,
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe changé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response['message']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
