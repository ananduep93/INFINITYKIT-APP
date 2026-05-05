import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA), // Indigo
              Color(0xFF764BA2), // Purple
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background particles simulation (static for now)
            ...List.generate(10, (index) => Positioned(
              top: (index * 100).toDouble() % MediaQuery.of(context).size.height,
              left: (index * 70).toDouble() % MediaQuery.of(context).size.width,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.circle, size: (index % 3 + 1) * 20, color: Colors.white),
              ),
            )),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.all_inclusive, size: 100, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'INFINITY KIT',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            
            const Positioned(
              bottom: 50,
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Initializing tools...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
