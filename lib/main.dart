import 'package:flutter/material.dart';

void main() {
  runApp(const MochaApp());
}

class MochaApp extends StatelessWidget {
  const MochaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mocha - Blog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF3E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3E2723),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const MochaHomePage(),
    );
  }
}

/// Page d’accueil "pré-blog" :
/// pour l’instant on affiche 5 questions / réponses
/// comme si c’était des brouillons d’articles.
class MochaHomePage extends StatelessWidget {
  const MochaHomePage({super.key});

  final List<Map<String, String>> questions = const [
    {
      'question': "Qu'est-ce qu'un espresso ?",
      'answer':
      "Un café très concentré obtenu avec de l'eau chaude sous pression."
    },
    {
      'question': 'Un latte et un cappuccino, différence ?',
      'answer':
      'Le latte contient plus de lait, le cappuccino contient plus de mousse.'
    },
    {
      'question': 'C’est quoi la mouture du café ?',
      'answer':
      'C’est la taille du grain moulu. Elle doit s’adapter au type de machine.'
    },
    {
      'question': 'À quoi sert un moulin à café ?',
      'answer':
      'À moudre les grains juste avant la préparation pour conserver les arômes.'
    },
    {
      'question': 'Pourquoi un café peut être amer ?',
      'answer':
      'Souvent à cause d’une sur-extraction ou d’une mouture trop fine.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mocha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mocha',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Mocha le blog des seigneurs",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Brouillons de billets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              itemCount: questions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final q = questions[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q['answer']!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Note #${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
