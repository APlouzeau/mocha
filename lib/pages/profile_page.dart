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

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
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
      appBar: AppBar(title: const Text('Profil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pseudo : ${nickName ?? "-"}'),
                  Text('Email : ${email ?? "-"}'),
                  Text('Role : ${role ?? "-"}'),
                  if (createdAt != null) Text('Créé le : $createdAt'),
                ],
              ),
            ),
    );
  }
}
