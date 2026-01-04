import 'package:flutter/material.dart';
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

    // Si pas d'utilisateur, l'onglet ne devrait pas être visible
    // mais on affiche quand même un message au cas où
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
            // Format simple sans locale
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
                  _buildInfoCard('Pseudo', nickName ?? '-'),
                  const SizedBox(height: 16),
                  _buildInfoCard('Email', email ?? '-'),
                  const SizedBox(height: 16),
                  _buildInfoCard('Rôle', role ?? '-'),
                  if (createdAt != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard('Membre depuis', createdAt!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
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
    );
  }
}
