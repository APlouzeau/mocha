import 'package:flutter/material.dart';

class MochaFaqPage extends StatelessWidget {
  const MochaFaqPage({super.key});

  final List<Map<String, String>> questions = const [
    {
      "question": "Comment créer un post ?",
      "answer":
      "Pour créer un post, il te suffit d’être connecté au forum. Une fois sur la page principale, utilise le champ de texte situé en bas de l’écran pour écrire ton message, puis appuie sur le bouton “Envoyer”. "
          "Ton post apparaîtra immédiatement dans la section 'Posts' du forum.",
    },
    {
      "question": "Pourquoi je ne peux pas supprimer un post ?",
      "answer":
      "La suppression de posts n’est pas possible car chaque message publié reste visible afin de garantir la cohérence des échanges entre les utilisateurs. "
          "Si tu as publié un message par erreur, n’hésite pas à contacter l’administrateur du forum pour qu’il puisse intervenir.",
    },
    {
      "question": "Comment est-ce que je peux créer un topic sur le forum ?",
      "answer":
      "Les topics sont un outils puissant sur notre forum, qui permet de regrouper ensemble les posts de nombreux utilisateurs sur un même sujet. Seul les membres de l'équipe de modération est capable de les créer ! "
          "Nous restons toujours attentifs à la popularité des sujets pour créer de nouveaux topics !",
    },
    {
      "question": "Comment chercher une info spécifique à un sujet sur le forum ?",
      "answer":
      "Notre forum dispose d'un agent IA pour t'aider à trouver toutes les infos que tu cherches sur n'importe quel sujet sur notre forum ! ",
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
