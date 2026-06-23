import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class DailyChallengesScreen extends StatefulWidget {
  final DateTime? initialMonth;
  const DailyChallengesScreen({super.key, this.initialMonth});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();
  int _completedCount = 0;
  Set<int> _completedDays = {};

  @override
  void initState() {
    super.initState();
    DateTime initDate = widget.initialMonth ?? DateTime.now();
    _currentMonth = DateTime(initDate.year, initDate.month, 1);
    
    // If viewing the current month, select today, otherwise select the 1st of the month
    if (_currentMonth.year == _today.year && _currentMonth.month == _today.month) {
      _selectedDate = DateTime(_today.year, _today.month, _today.day);
    } else {
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    }
    
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    Set<int> completedDays = {};
    int days = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    for (int i = 1; i <= days; i++) {
      int levelNum = _currentMonth.year * 10000 + _currentMonth.month * 100 + i;
      if (prefs.getBool('daily_completed_$levelNum') == true) {
        count++;
        completedDays.add(i);
      }
    }
    setState(() {
      _completedCount = count;
      _completedDays = completedDays;
    });
  }

  bool get _canGoPrevious {
    final oldestMonth = DateTime(_today.year, _today.month - 2, 1);
    return _currentMonth.isAfter(oldestMonth);
  }

  bool get _canGoNext {
    final currentMonthLimit = DateTime(_today.year, _today.month, 1);
    return _currentMonth.isBefore(currentMonthLimit);
  }

  bool _isFutureDate(int day) {
    if (_currentMonth.year > _today.year) return true;
    if (_currentMonth.year == _today.year && _currentMonth.month > _today.month) return true;
    if (_currentMonth.year == _today.year && _currentMonth.month == _today.month && day > _today.day) return true;
    return false;
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  int get _startDayOffset {
    return _currentMonth.weekday % 7; // 0 = Sunday, 1 = Monday
  }

  String get _monthString {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  bool _isSelected(int day) {
    return _currentMonth.year == _selectedDate.year && 
           _currentMonth.month == _selectedDate.month && 
           day == _selectedDate.day;
  }

  int get _trophyIndex {
    return (_currentMonth.month % 3) + 1;
  }

  void _previousMonth() {
    if (!_canGoPrevious) return;
    if (AppSettings.vibrationEnabled) HapticFeedback.selectionClick();
    if (AppSettings.soundEnabled) SystemSound.play(SystemSoundType.click);
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _loadProgress();
    });
  }

  void _nextMonth() {
    if (!_canGoNext) return;
    if (AppSettings.vibrationEnabled) HapticFeedback.selectionClick();
    if (AppSettings.soundEnabled) SystemSound.play(SystemSoundType.click);
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top Trophy Section
          Expanded(
            flex: 45,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (Navigator.canPop(context))
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Daily Challenges',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Left Arrow
                            Positioned(
                              left: 10,
                              child: Visibility(
                                visible: _canGoPrevious,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                                  onPressed: _previousMonth,
                                ),
                              ),
                            ),
                            // Right Arrow
                            Positioned(
                              right: 10,
                              child: Visibility(
                                visible: _canGoNext,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                                  onPressed: _nextMonth,
                                ),
                              ),
                            ),
                            // Trophy Image
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 60), // Keep image away from arrows
                              child: Image.asset(
                                'assets/trophy$_trophyIndex.png',
                                height: 220, // Increased size for the half page
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Calendar Section
          Expanded(
            flex: 55,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Month & Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _monthString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 5),
                          Text(
                            '$_completedCount/$_daysInMonth',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Days of week header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                      return SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  
                  // Calendar Grid
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.5, // Flattened cells to fit in half page
                      ),
                      itemCount: 42, // 6 weeks
                      itemBuilder: (context, index) {
                        int offset = _startDayOffset;
                        int day = index - offset + 1;
                        
                        if (index < offset || day > _daysInMonth) {
                          return const SizedBox.shrink(); // Empty grid cell
                        }
                        
                        bool isFuture = _isFutureDate(day);
                        bool isCompleted = _completedDays.contains(day);
                        bool isSelected = _isSelected(day);
                        
                        return GestureDetector(
                          onTap: isFuture ? null : () {
                            if (AppSettings.vibrationEnabled) HapticFeedback.selectionClick();
                            if (AppSettings.soundEnabled) SystemSound.play(SystemSoundType.click);
                            setState(() {
                              _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
                            });
                          },
                          child: Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: (isSelected || isCompleted) ? const Color(0xFF4CAF50) : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                              ),
                              alignment: Alignment.center,
                              child: isCompleted 
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : Text(
                                    day.toString(),
                                    style: TextStyle(
                                      color: isFuture 
                                          ? Colors.white24 
                                          : (isSelected ? Colors.black : Colors.white70),
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Play Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (AppSettings.vibrationEnabled) HapticFeedback.selectionClick();
                          if (AppSettings.soundEnabled) SystemSound.play(SystemSoundType.click);
                          int levelSeed = _selectedDate.year * 10000 + _selectedDate.month * 100 + _selectedDate.day;
                          
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                initialLevel: levelSeed,
                                isDailyChallenge: true,
                              ),
                            ),
                          );
                          // Reload progress after returning from game
                          _loadProgress();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Play',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
