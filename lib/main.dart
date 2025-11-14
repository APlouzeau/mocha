import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/faq_page.dart';
import 'pages/login_page.dart';
import 'pages/posts_page.dart';
import 'pages/topics_page.dart';
// import 'assets/mocha_logo_beige.png';

void main() {
  runApp(const MochaApp());
}

class MochaApp extends StatelessWidget {
  const MochaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mocha Forum',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6D4C41),
          onPrimary: Color(0xFF6D4C41),
          secondary: Color(0xFFD2B48C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F0DD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6D4C41),
          foregroundColor: Colors.white,
          centerTitle: true, // à voir placement logo
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFD2B48C),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      home: const MochaRoot(),
    );
  }
}

class MochaRoot extends StatefulWidget {
  const MochaRoot({super.key});

  @override
  State<MochaRoot> createState() => _MochaRootState();
}

class _MochaRootState extends State<MochaRoot> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MochaHomePage(),    // Accueil
    MochaFaqPage(),     // FAQ
    Placeholder(),      // Ajouter
    PostsPage(),        // Posts
    TopicsPage(),       // Topics
  ];

  final List<String> _pageLabels = const [
    "Accueil",
    "FAQ",
    "Ajouter", // Creation de post à implémenter
    "Posts",
    "Topics",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset(
            //   'assets/mocha_logo_beige.png',
            //   height: 32,
            // ),
            const SizedBox(width: 10),
            const Text('Mocha'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              'Se connecter',
              style: TextStyle(color: Color(0xFFD2B48C)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 141, 99, 85),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD2B48C),
                  blurRadius: 2,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                _pageLabels[_currentIndex],
                style: const TextStyle(
                    color: Color(0xFFF8F0DD),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFD2B48C),
        unselectedItemColor: Color(0xFFF8F0DD),
        backgroundColor: const Color(0xFF6D4C41),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'FAQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // Nouveau bouton Add
            label: 'Poster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.topic),
            label: 'Topics',
          ),
        ],
      ),
    );
  }
}
