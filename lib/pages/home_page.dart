import 'package:flutter/material.dart';

class MochaHomePage extends StatelessWidget {
  const MochaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bienvenue sur Mocha Forum !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Le lieu où chaque boisson chaude a une histoire.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 24),
              Text(
                'Plongez dans un univers dédié aux passionnés de cafés, thés, chocolats chauds et infusions de toutes sortes. Que vous soyez barista amateur, aventurier du goût, collectionneur de thés rares ou simplement amateur de moments chaleureux, Mocha Forum est votre espace pour partager, découvrir et échanger.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Retrouvez :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Des discussions autour des recettes, techniques et rituels du monde entier\n'
                '• Des recommandations de matériels et d’adresses incontournables\n'
                '• Des avis, astuces et retours d’expérience de la communauté\n'
                '• Des espaces thématiques pour explorer chaque boisson sous toutes ses formes',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Installez-vous confortablement, préparez votre boisson préférée, et rejoignez la conversation.\n'
                'Mocha Forum, là où la chaleur d’une tasse rencontre celle de la communauté.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
