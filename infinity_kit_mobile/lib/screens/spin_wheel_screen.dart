import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> with SingleTickerProviderStateMixin {
  final _optionsController = TextEditingController(text: 'Option 1, Option 2, Option 3, Option 4');
  List<String> _options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0;
  String? _result;
  bool _isSpinning = false;

  final List<Color> _colors = [
    const Color(0xFF667EEA),
    const Color(0xFF764BA2),
    const Color(0xFFF093FB),
    const Color(0xFF4FACFE),
    const Color(0xFF43E97B),
    const Color(0xFFFA709A),
    const Color(0xFFFEE140),
    const Color(0xFF30B0FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateResult();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _updateOptions() {
    setState(() {
      _options = _optionsController.text
          .split(',')
          .map((e) => e.trim())
          .filter((e) => e.isNotEmpty)
          .toList();
      _result = null;
    });
    if (_options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least one option')));
    }
  }

  void _spin() {
    if (_options.length < 2 || _isSpinning) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSpinning = true;
      _result = null;
    });

    final randomRotation = Random().nextDouble() * 2 * pi;
    final extraSpins = 5 + Random().nextInt(5);
    final targetRotation = _currentRotation + (extraSpins * 2 * pi) + randomRotation;

    _animation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _currentRotation = targetRotation;
    _controller.reset();
    _controller.forward();
  }

  void _calculateResult() {
    final normalizedRotation = (_currentRotation % (2 * pi));
    // The arrow is at the top (3*pi/2 in our coordinate system if 0 is right)
    // Actually, in our CustomPainter, we start at 0 (right) and go clockwise.
    // So top is 3*pi/2.
    final sliceAngle = 2 * pi / _options.length;
    
    // We need to find which slice is at the top (270 degrees or 1.5*pi)
    // The rotation moves the wheel clockwise.
    // So the offset is (1.5*pi - rotation) % 2*pi
    double arrowPos = (1.5 * pi - normalizedRotation) % (2 * pi);
    if (arrowPos < 0) arrowPos += 2 * pi;
    
    int index = (arrowPos / sliceAngle).floor();
    
    setState(() {
      _result = _options[index % _options.length];
      _isSpinning = false;
    });
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎡 Spin Wheel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _optionsController,
              decoration: InputDecoration(
                labelText: 'Options (comma separated)',
                hintText: 'e.g. Yes, No, Maybe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: _updateOptions),
              ),
              onChanged: (_) => _updateOptions(),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: WheelPainter(_options, _colors),
                      ),
                    );
                  },
                ),
                // Arrow
                Positioned(
                  top: -10,
                  child: Container(
                    width: 30,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                  ),
                ),
                // Center Pin
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSpinning || _options.length < 2 ? null : _spin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSpinning
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SPIN!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Result:', style: TextStyle(color: AppTheme.subtitleColor)),
                    const SizedBox(height: 10),
                    Text(_result!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  WheelPainter(this.options, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = 2 * pi / options.length;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < options.length; i++) {
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sliceAngle,
        sliceAngle,
        true,
        paint,
      );

      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * sliceAngle + sliceAngle / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(maxWidth: radius - 20);
      textPainter.paint(canvas, Offset(radius - textPainter.width - 20, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension IterableFilter<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) => where(test);
}
