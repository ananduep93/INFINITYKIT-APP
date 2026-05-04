import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Stopwatch state
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  final List<String> _laps = [];

  // Timer state
  int _seconds = 60;
  Timer? _countdownTimer;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- Stopwatch Methods ---
  void _startStopwatch() {
    _stopwatch.start();
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _laps.clear();
    setState(() {});
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}";
  }

  // --- Timer Methods ---
  void _startTimer() {
    if (_seconds > 0) {
      setState(() => _isTimerRunning = true);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds > 0) {
          setState(() => _seconds--);
        } else {
          _stopTimer();
        }
      });
    }
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏱️ Timer & Stopwatch'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Stopwatch'), Tab(text: 'Timer')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStopwatchTab(),
          _buildTimerTab(),
        ],
      ),
    );
  }

  Widget _buildStopwatchTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          _formatTime(_stopwatch.elapsedMilliseconds),
          style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w200, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
              color: _stopwatch.isRunning ? Colors.red : Colors.green,
              icon: _stopwatch.isRunning ? Icons.stop : Icons.play_arrow,
            ),
            const SizedBox(width: 20),
            _buildCircleButton(
              onPressed: _resetStopwatch,
              color: Colors.grey,
              icon: Icons.refresh,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: ListView.builder(
            itemCount: _laps.length,
            itemBuilder: (context, index) => ListTile(
              title: Text('Lap ${_laps.length - index}'),
              trailing: Text(_laps[_laps.length - 1 - index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${(_seconds / 60).truncate().toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200),
        ),
        const SizedBox(height: 40),
        if (!_isTimerRunning)
          Slider(
            value: _seconds.toDouble(),
            min: 0,
            max: 3600,
            onChanged: (val) => setState(() => _seconds = val.toInt()),
          ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              onPressed: _isTimerRunning ? _stopTimer : _startTimer,
              color: _isTimerRunning ? Colors.orange : AppTheme.primaryColor,
              icon: _isTimerRunning ? Icons.pause : Icons.play_arrow,
            ),
            const SizedBox(width: 20),
            _buildCircleButton(
              onPressed: () => setState(() => _seconds = 60),
              color: Colors.grey,
              icon: Icons.refresh,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton({required VoidCallback onPressed, required Color color, required IconData icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Icon(icon, size: 32),
    );
  }
}
