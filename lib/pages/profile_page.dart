import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? nickName;
  String? email;
  String? roleId;
  String? createdAt;
  bool isLoading = true;

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
          nickName = map['nickName']?.toString();
          email = map['email']?.toString();
          roleId = map['roleId']?.toString();
          createdAt = map['createdAt']?.toString();
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pseudo : ${nickName ?? "-"}') ,
                  Text('Email : ${email ?? "-"}') ,
                  Text('Role ID : ${roleId ?? "-"}') ,
                  Text('Créé le : ${createdAt ?? "-"}') ,
                ],
              ),
            ),
    );
  }
}