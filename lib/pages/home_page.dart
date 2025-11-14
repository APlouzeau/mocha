import 'package:flutter/material.dart';

/// Page d'accueil "vide" pour Mocha.
/// Tes collègues pourront venir coder ici plus tard.
/// Pour l'instant, c'est juste un template de base.
class MochaHomePage extends StatelessWidget {
  const MochaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Accueil Mocha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "AAA",
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
