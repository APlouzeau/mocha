import 'package:flutter/material.dart';

class MochaFaqPage extends StatelessWidget {
  const MochaFaqPage({super.key});

  final List<Map<String, String>> questions = const [
    {
      "question": "Qu'est-ce qu'un espresso ?",
      "answer":
      "Un espresso est un café très concentré obtenu en faisant passer de l'eau chaude sous pression à travers du café finement moulu. "
          "Il sert souvent de base à d’autres boissons (latte, cappuccino, etc.).",
    },
    {
      "question": "Quelle est la différence entre un latte et un cappuccino ?",
      "answer":
      "Les deux utilisent du lait, mais le latte contient plus de lait chaud et moins de mousse, alors que le cappuccino a une couche de mousse plus épaisse "
          "et un goût de café plus marqué.",
    },
    {
      "question": "Qu'est-ce que la mouture du café ?",
      "answer":
      "La mouture correspond à la taille des particules de café une fois les grains moulus. "
          "Une mouture fine est utilisée pour l’espresso, une mouture plus grosse pour les cafetières filtres ou à piston.",
    },
    {
      "question": "À quoi sert un moulin à café ?",
      "answer":
      "Un moulin à café permet de moudre les grains juste avant la préparation. "
          "Cela permet de préserver les arômes, qui se perdent rapidement une fois le café moulu.",
    },
    {
      "question": "Pourquoi le café peut-il être amer ?",
      "answer":
      "Un café trop amer est souvent lié à une sur-extraction (temps d’infusion trop long), une mouture trop fine ou des grains trop torréfiés. "
          "Adapter la mouture et le temps d’infusion permet souvent de corriger ça.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q["question"]!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q["answer"]!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Petite meta en bas du post
                Text(
                  "FAQ #${index + 1}",
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
    );
  }
}
