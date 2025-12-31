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
  int? roleId;
  DateTime? createdAt;
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
        nickName = user.nickName;
        email = user.email;
        roleId = user.roleId;
        createdAt = user.createdAt;
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
                  Text('Role ID : ${roleId ?? "-"}'),
                  Text('Créé le : ${createdAt ?? "-"}'),
                ],
              ),
            ),
    );
  }
}
