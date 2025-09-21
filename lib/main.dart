import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW01 Grad App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: CounterImagePage(toggleTheme: _toggleTheme),
    );
  }
}

class CounterImagePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const CounterImagePage({super.key, required this.toggleTheme});

  @override
  State<CounterImagePage> createState() => _CounterImagePageState();
}

class _CounterImagePageState extends State<CounterImagePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _showFirstImage = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _showFirstImage = prefs.getBool('isFirstImage') ?? true;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    await prefs.setBool('isFirstImage', _showFirstImage);
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveState();
  }

  void _toggleImage() {
    _animationController.reverse().then((_) {
      setState(() {
        _showFirstImage = !_showFirstImage;
      });
      _animationController.forward();
      _saveState();
    });
  }

  void _resetApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('Are you sure you want to reset everything?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _clearState();
      setState(() {
        _counter = 0;
        _showFirstImage = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _showFirstImage
        ? 'assets/image1.png'
        : 'assets/image2.png';

    return Scaffold(
      appBar: AppBar(title: const Text("CW 01 – Grad App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter Value:', style: TextStyle(fontSize: 20)),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text("Increment"),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(imagePath, width: 200, height: 200),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleImage,
              child: const Text("Toggle Image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.toggleTheme,
              child: const Text("Toggle Theme"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
              onPressed: _resetApp,
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}
