import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home_page.dart';
import 'pages/faq_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/posts_page.dart';
import 'pages/profile_page.dart';
import 'pages/create_post_page.dart';
import 'helpers/auth_helper.dart';

// import 'assets/mocha_logo_beige.png';

class MochaRoot extends StatefulWidget {
  const MochaRoot({super.key});

  @override
  State<MochaRoot> createState() => _MochaRootState();
}

Future<void> main() async {
  await dotenv.load();
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
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilPage(),
      },
      home: const MochaRoot(),
    );
  }
}

class _MochaRootState extends State<MochaRoot> with WidgetsBindingObserver {
  Future<void> _logout() async {
    await AuthHelper.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _isModerator = false;
        _currentIndex = 0;
      });
    }
  }

  Future<void> _handleLoginResult() async {
    await _checkLoginStatus();
    await _checkModeratorStatus();
    setState(() {});
  }

  bool _isLoggedIn = false;
  bool _isModerator = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
    _checkModeratorStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Revérifier le statut quand l'app redevient active
      _checkLoginStatus();
      _checkModeratorStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    final isLogged = await AuthHelper.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLogged;
      });
    }
  }

  Future<void> _checkModeratorStatus() async {
    final isModerator = await AuthHelper.isModerator();
    if (mounted) {
      setState(() {
        _isModerator = isModerator;
      });
    }
  }

  void _validateCurrentIndex() {
    // S'assurer que _currentIndex est toujours dans la plage valide
    final itemsCount = _getBottomNavItemsCount();
    if (_currentIndex >= itemsCount) {
      _currentIndex = 0;
    }
  }

  int _getBottomNavItemsCount() {
    // Compter les items réels du BottomNavigationBar
    // Accueil, FAQ, Posts (toujours présents) = 3
    // + Poster si modérateur ET connecté = 1
    int count = 3;
    if (_isLoggedIn && _isModerator) {
      count++;
    }
    return count;
  }

  List<Widget> get _pages {
    if (_isLoggedIn && _isModerator) {
      return [
        const MochaHomePage(),
        const MochaFaqPage(),
        const CreatePostPage(),
        const PostsPage(),
      ];
    } else {
      return [const MochaHomePage(), const MochaFaqPage(), const PostsPage()];
    }
  }

  List<String> get _pageLabels {
    if (_isLoggedIn && _isModerator) {
      return ["Accueil", "FAQ", "Nouveau Post", "Posts"];
    } else {
      return ["Accueil", "FAQ", "Posts"];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Valider l'index avant chaque build
    _validateCurrentIndex();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(width: 10), const Text('Mocha')],
        ),
        actions: [
          if (!_isLoggedIn)
            TextButton(
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Color(0xFFD2B48C)),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                await _handleLoginResult();
              },
            )
          else ...[
            TextButton(
              child: const Text(
                'Profil',
                style: TextStyle(color: Color(0xFFD2B48C)),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilPage()),
                );
                await _handleLoginResult();
              },
            ),
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Color(0xFFD2B48C)),
              ),
            ),
          ],
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
                ),
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
        unselectedItemColor: const Color(0xFFF8F0DD),
        backgroundColor: const Color(0xFF6D4C41),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'FAQ',
          ),
          if (_isLoggedIn && _isModerator)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Poster',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Posts',
          ),
        ],
      ),
    );
  }
}
