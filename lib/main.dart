import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/faq_page.dart';

void main() {
  runApp(const MochaApp());
}

class MochaApp extends StatelessWidget {
  const MochaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mocha',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF3E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6D4C41),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
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
    MochaHomePage(),
    MochaFaqPage(),
  ];

  final List<String> _pageLabels = const [
    "Accueil",
    "FAQ",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mocha'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF6D4C41),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                _pageLabels[_currentIndex],
                style: const TextStyle(
                  color: Colors.white,
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
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6D4C41),
        unselectedItemColor: Colors.brown.shade300,
        backgroundColor: const Color(0xFFF2E5D5),
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
        ],
      ),
    );
  }
}
