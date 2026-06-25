import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math';
import '../game/puzzle_generator.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'about_game_screen.dart';
import 'privacy_rights_screen.dart';
import 'advertising_preferences_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/app_settings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final int initialLevel;
  final bool isDailyChallenge;

  const GameScreen({
    super.key, 
    required this.initialLevel,
    this.isDailyChallenge = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.isDailyChallenge ? 0 : widget.initialLevel - 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe when level completes to force screen interaction
        itemCount: widget.isDailyChallenge ? 1 : null,
        itemBuilder: (context, index) {
          final levelNum = widget.isDailyChallenge ? widget.initialLevel : index + 1;
          return LevelPlayWidget(
            levelNum: levelNum,
            isDailyChallenge: widget.isDailyChallenge,
            onBack: () {
              if (AppSettings.vibrationEnabled) HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            onNextLevel: () {
              if (AppSettings.vibrationEnabled) HapticFeedback.mediumImpact();
              
              void proceed() {
                if (mounted && _pageController.hasClients) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              }

              AdManager.showInterstitialAd(proceed);
            },
          );
        },
      ),
    );
  }
}

class LevelPlayWidget extends StatefulWidget {
  final int levelNum;
  final bool isDailyChallenge;
  final VoidCallback onBack;
  final VoidCallback onNextLevel;

  const LevelPlayWidget({
    super.key,
    required this.levelNum,
    required this.onBack,
    required this.onNextLevel,
    this.isDailyChallenge = false,
  });

  @override
  State<LevelPlayWidget> createState() => _LevelPlayWidgetState();
}

class _LevelPlayWidgetState extends State<LevelPlayWidget> with TickerProviderStateMixin {
  late PuzzleLevel levelData;
  List<PuzzleString> activeStrings = [];
  int maxHearts = 3;
  int currentHearts = 3;
  int freeHints = 1;
  bool showGridLines = false;
  
  // Game states
  bool isLevelComplete = false;
  bool showWellDone = false;
  bool showLevelCompleteScreen = false;

  Map<int, AnimationController> animControllers = {};
  Map<int, bool> isWiggling = {};
  Map<int, bool> isHinting = {};

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Confetti & Sunburst animation components
  late AnimationController _effectController;
  List<ConfettiParticle> _particles = [];
  double _sunburstRotation = 0.0;
  
  late AnimationController _damageController;
  late Animation<double> _damageAnimation;

  final List<AudioPlayer> _clickPlayers = List.generate(5, (_) => AudioPlayer());
  int _clickPlayerIndex = 0;
  final AudioPlayer _startPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  String _getLevelTitle() {
    if (widget.isDailyChallenge) {
      int month = (widget.levelNum % 10000) ~/ 100;
      int day = widget.levelNum % 100;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      if (month >= 1 && month <= 12) {
        return '${months[month - 1]} $day';
      }
      return 'Daily';
    }
    return 'Level ${widget.levelNum}';
  }

  String _getPositionText() {
    if (widget.isDailyChallenge) {
      int month = (widget.levelNum % 10000) ~/ 100;
      int day = widget.levelNum % 100;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      if (month >= 1 && month <= 12) {
        return '${months[month - 1]} $day';
      }
      return 'Daily';
    }
    return widget.levelNum.toString();
  }

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setAudioContext(AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build());

    _initAudio();
    AdManager.loadInterstitialAd();
    AdManager.loadRewardedAd();
    _loadBannerAd();

    _effectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          _updateEffects();
        });
      });

    _damageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _damageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _damageController, curve: Curves.easeInOut),
    );

    _loadLevel();
  }

  Future<void> _initAudio() async {
    for (var p in _clickPlayers) {
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setSourceAsset('click.wav');
    }
    await _errorPlayer.setReleaseMode(ReleaseMode.stop);
    await _errorPlayer.setSourceAsset('error.wav');
    await _startPlayer.setReleaseMode(ReleaseMode.stop);
    await _startPlayer.setSourceAsset('start.wav');
  }

  void _loadLevel() {
    for (var c in animControllers.values) {
      c.dispose();
    }
    animControllers.clear();
    isWiggling.clear();
    isHinting.clear();
    _effectController.stop();

    int level = widget.levelNum;
    int initialHearts = 3;
    int initialHints = 1;

    if (level <= 5) {
      initialHearts = 2;
      initialHints = 0;
    } else if (level <= 10) {
      initialHearts = 3;
      initialHints = 1;
    } else if (level < 50) {
      initialHearts = 3;
      initialHints = 2;
    } else {
      initialHearts = 5;
      initialHints = 2;
    }

    setState(() {
      levelData = PuzzleGenerator.getLevel(widget.levelNum);
      activeStrings = List.from(levelData.strings);
      maxHearts = initialHearts;
      currentHearts = initialHearts;
      freeHints = initialHints;
      showGridLines = false;
      isLevelComplete = false;
      showWellDone = false;
      showLevelCompleteScreen = false;
      _particles = [];
    });

    if (AppSettings.soundEnabled) {
      _startPlayer.play(AssetSource('start.wav'));
    }
  }

  void _loadBannerAd() {
    _bannerAd = AdManager.createBannerAd(() {
      if (mounted) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      }
    });
    _bannerAd?.load();
  }

  @override
  void dispose() {
    for (var c in animControllers.values) {
      c.dispose();
    }
    _effectController.dispose();
    _damageController.dispose();
    for (var p in _clickPlayers) {
      p.dispose();
    }
    _startPlayer.dispose();
    _errorPlayer.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _updateEffects() {
    // Rotate sunburst rays
    _sunburstRotation += 0.005;

    // Update confetti particles
    final size = MediaQuery.of(context).size;
    if (_particles.isEmpty && size.width > 0) {
      _particles = _generateParticles(size);
    }

    for (var p in _particles) {
      p.y += p.speed * 0.016; // Simulate delta time (60 FPS ~ 16ms)
      p.x += sin(p.y / 20) * 0.8;
      p.rotation += p.rotationSpeed * 0.016;

      // Reset when particle goes off screen
      if (p.y > size.height) {
        p.y = -20;
        p.x = Random().nextDouble() * size.width;
      }
    }
  }

  List<ConfettiParticle> _generateParticles(Size size) {
    final rand = Random();
    final colors = [
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
    ];
    return List.generate(80, (index) {
      return ConfettiParticle(
        x: rand.nextDouble() * size.width,
        y: -rand.nextDouble() * size.height - 20,
        speed: 120 + rand.nextDouble() * 180,
        color: colors[rand.nextInt(colors.length)],
        rotation: rand.nextDouble() * 2 * pi,
        rotationSpeed: (rand.nextDouble() - 0.5) * 5,
        width: 6 + rand.nextDouble() * 8,
        height: 10 + rand.nextDouble() * 10,
      );
    });
  }

  bool _isExitClear(PuzzleString string) {
    Direction dir = string.exitDirection;
    Point head = string.head;

    int dx = 0;
    int dy = 0;
    if (dir == Direction.right) dx = 1;
    if (dir == Direction.left) dx = -1;
    if (dir == Direction.down) dy = 1;
    if (dir == Direction.up) dy = -1;

    Point check = Point(head.x + dx, head.y + dy);

    while (check.x >= 0 && check.x < levelData.gridWidth && check.y >= 0 && check.y < levelData.gridHeight) {
      for (var other in activeStrings) {
        if (other.id == string.id) continue;
        // If the other string is currently clearing (animating out), it shouldn't block
        if (animControllers.containsKey(other.id) && !isWiggling.containsKey(other.id)) continue;
        for (var p in other.path) {
          if (p == check) return false;
        }
      }
      check = Point(check.x + dx, check.y + dy);
    }
    return true;
  }

  void _handleTap(PuzzleString string) {
    if (animControllers.containsKey(string.id) || showLevelCompleteScreen || showWellDone) return;

    bool isClear = _isExitClear(string);

    if (isClear) {
      if (AppSettings.vibrationEnabled) HapticFeedback.lightImpact();
      if (AppSettings.soundEnabled) {
        final p = _clickPlayers[_clickPlayerIndex];
        p.play(AssetSource('click.wav'));
        _clickPlayerIndex = (_clickPlayerIndex + 1) % _clickPlayers.length;
      }
      AnimationController controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      setState(() {
        animControllers[string.id] = controller;
      });

      controller.forward().then((_) {
        if (mounted) {
          setState(() {
            activeStrings.removeWhere((s) => s.id == string.id);
            animControllers[string.id]?.dispose();
            animControllers.remove(string.id);
          });
          _checkWinCondition();
        }
      });
    } else {
      if (AppSettings.vibrationEnabled) HapticFeedback.heavyImpact();
      if (AppSettings.soundEnabled) {
        _errorPlayer.play(AssetSource('error.wav'));
      }
      if (currentHearts > 0) {
        setState(() {
          currentHearts--;
        });
        if (currentHearts == 0) {
          _showGameOverDialog();
        } else {
          _damageController.forward().then((_) {
            if (mounted) _damageController.reverse();
          });
          AnimationController controller = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          );
          setState(() {
            isWiggling[string.id] = true;
            animControllers[string.id] = controller;
          });
          controller.forward().then((_) {
            if (mounted) {
              setState(() {
                isWiggling.remove(string.id);
                animControllers[string.id]?.dispose();
                animControllers.remove(string.id);
              });
            }
          });
        }
      }
    }
  }

  void _checkWinCondition() async {
    if (activeStrings.isEmpty) {
      if (!widget.isDailyChallenge) {
        final prefs = await SharedPreferences.getInstance();
        int currentSaved = prefs.getInt('current_level') ?? 1;
        if (widget.levelNum + 1 > currentSaved) {
          await prefs.setInt('current_level', widget.levelNum + 1);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('daily_completed_${widget.levelNum}', true);
      }

      if (mounted) {
        if (AppSettings.vibrationEnabled) HapticFeedback.vibrate();
        if (AppSettings.soundEnabled) AudioPlayer().play(AssetSource('win.wav'));
        Future.delayed(const Duration(milliseconds: 150), () {
          if (AppSettings.vibrationEnabled) HapticFeedback.vibrate();
        });
        setState(() {
          isLevelComplete = true;
          showWellDone = false;
          showLevelCompleteScreen = true;
          _effectController.repeat();
        });
      }
    }
  }

  void _useHint() {
    for (var string in activeStrings) {
      if (_isExitClear(string)) {
        if (animControllers.containsKey(string.id)) continue;
        AnimationController controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        setState(() {
          isHinting[string.id] = true;
          animControllers[string.id] = controller;
        });
        controller.forward().then((_) {
          if (mounted) {
            setState(() {
              isHinting.remove(string.id);
              animControllers[string.id]?.dispose();
              animControllers.remove(string.id);
            });
          }
        });
        break;
      }
    }
  }

  void _showAdForHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF212121),
        title: const Row(
          children: [
            Icon(Icons.ondemand_video, color: Colors.white),
            SizedBox(width: 10),
            Text('Watch Ad', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text('Watch a short video ad to get a hint?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              bool adShown = AdManager.showRewardedAd(
                (RewardItem reward) {
                  setState(() {
                    freeHints++;
                  });
                },
                () {}
              );
              Navigator.pop(context);
              if (!adShown) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No ad available right now. Please try again later.')),
                );
              }
            },
            child: const Text('Watch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF212121), // Dark theme background
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Out of Lives!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white12, // Darker circle background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 50),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('+1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // Green Theme
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    bool adShown = AdManager.showRewardedAd(
                      (RewardItem reward) {
                        setState(() {
                          currentHearts += 1;
                        });
                        if (mounted) Navigator.of(context).pop();
                      },
                      () {}
                    );
                    if (!adShown) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No ad available right now. Please try again later.')),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get More Lives ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(Icons.ondemand_video, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadLevel();
                },
                child: const Text('Restart Game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4CAF50)),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            const Divider(color: Colors.white12, height: 1, indent: 60),
            ListTile(
              leading: const Icon(Icons.help_center, color: Colors.green),
              title: const Text('Help', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
              },
            ),
            const Divider(color: Colors.white12, height: 1, indent: 60),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF4CAF50)),
              title: const Text('About Game', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutGameScreen()));
              },
            ),
            const Divider(color: Colors.white12, height: 1, indent: 60),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Colors.purpleAccent),
              title: const Text('Privacy Rights', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyRightsScreen()));
              },
            ),
            const Divider(color: Colors.white12, height: 1, indent: 60),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.tealAccent),
              title: const Text('Privacy Preferences', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvertisingPreferencesScreen()));
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _getDifficulty(int level) {
    if (level <= 5) return 'Easy';
    if (level <= 15) return 'Normal';
    if (level <= 30) return 'Hard';
    return 'Expert';
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (showLevelCompleteScreen) {
      content = _buildLevelCompletedScreen();
    } else {
      content = Stack(
        children: [
          // Main Gameplay Screen
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF161616), // Dark background matching the rest of the app
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                        onPressed: widget.onBack,
                      ),
                      Text(
                        _getLevelTitle(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50), // Set level text to green
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                        onPressed: () => _showSettingsMenu(context),
                      ),
                    ],
                  ),
                ),

                // Stats Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Position Stat
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white12, // Dark theme badge
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${activeStrings.length}', // Live Arrow Count
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hearts
                      Row(
                        children: List.generate(
                          maxHearts,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                index < currentHearts ? Icons.favorite : Icons.favorite_border,
                                key: ValueKey<bool>(index < currentHearts),
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Difficulty Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white12, // Dark theme badge
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getDifficulty(widget.levelNum),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Puzzle Grid Area with Bottom Fade
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double gridWidth = constraints.maxWidth;
                          double gridHeight = gridWidth * (levelData.gridHeight / levelData.gridWidth);
                          
                          if (gridHeight > constraints.maxHeight) {
                            gridHeight = constraints.maxHeight;
                            gridWidth = gridHeight * (levelData.gridWidth / levelData.gridHeight);
                          }

                          List<Listenable> listenables = animControllers.values.toList();

                          return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                if (isLevelComplete) return;

                                double cellWidth = gridWidth / levelData.gridWidth;
                                double cellHeight = gridHeight / levelData.gridHeight;

                                int tx = (details.localPosition.dx / cellWidth).floor();
                                int ty = (details.localPosition.dy / cellHeight).floor();

                                for (var string in activeStrings) {
                                  for (var p in string.path) {
                                    if (p.x == tx && p.y == ty) {
                                      _handleTap(string);
                                      return;
                                    }
                                  }
                                }
                              },
                              child: AnimatedBuilder(
                                animation: Listenable.merge(listenables),
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: Size(gridWidth, gridHeight),
                                    painter: TapAwayPainter(
                                      levelData: levelData,
                                      activeStrings: activeStrings,
                                      animControllers: animControllers,
                                      isWiggling: isWiggling,
                                      isHinting: isHinting,
                                      showGridLines: showGridLines,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (freeHints > 0) {
                            setState(() {
                              freeHints--;
                            });
                            _useHint();
                          } else {
                            _showAdForHint();
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.lightbulb, color: Colors.white, size: 32),
                            ),
                            if (freeHints == 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Ad',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$freeHints',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showGridLines = !showGridLines;
                          });
                        },
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: showGridLines ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '#',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Damage Flash Overlay
        AnimatedBuilder(
          animation: _damageAnimation,
          builder: (context, child) {
            if (_damageAnimation.value == 0) return const SizedBox.shrink();
            return IgnorePointer(
              child: Container(
                color: Colors.red.withOpacity(0.4 * _damageAnimation.value),
              ),
            );
          },
        ),

        // Pop-up: Well Done Banner Overlay
        if (showWellDone)
          Container(
            color: Colors.white.withOpacity(0.3),
            child: Center(
              child: AnimatedOpacity(
                opacity: showWellDone ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Party Hat emoji 🥳
                    const Text(
                      '🥳',
                      style: TextStyle(fontSize: 70),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Well Done!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
    }

    return Column(
      children: [
        Expanded(child: content),
        if (_isBannerAdLoaded && _bannerAd != null)
          SafeArea(
            top: false,
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
      ],
    );
  }

  // Full Screen Level Completed View
  Widget _buildLevelCompletedScreen() {
    if (widget.isDailyChallenge) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C9BFF), Color(0xFF0F75D4)], // Blue gradient based on screenshot
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: SunburstPainter(rotationAngle: _sunburstRotation),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: ConfettiPainter(particles: _particles),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You have completed the daily challenge\nfor ${_getLevelTitle()}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Golden Star Indicator
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCA28),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Color(0xFFFF8F00),
                        size: 140,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Position', style: TextStyle(color: Colors.white, fontSize: 16)),
                                  Text(_getPositionText(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: Colors.white24, height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Score', style: TextStyle(color: Colors.white, fontSize: 16)),
                                  Text(levelData.strings.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Collect Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: GestureDetector(
                      onTap: () async {
                         final prefs = await SharedPreferences.getInstance();
                         int coins = prefs.getInt('coins') ?? 0;
                         await prefs.setInt('coins', coins + 50); // Add 50 coins for daily
                         widget.onBack();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Collect',
                            style: TextStyle(
                              color: Color(0xFF0F75D4),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)], // Green gradient to match logo theme
        ),
      ),
      child: Stack(
        children: [
          // Sunburst background
          Positioned.fill(
            child: CustomPaint(
              painter: SunburstPainter(rotationAngle: _sunburstRotation),
            ),
          ),

          // Confetti particles raining down
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(particles: _particles),
            ),
          ),

          // Content Column
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Level Completed!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Level Preview Card
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121), // Dark preview card to show white dots
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(220, 220),
                          painter: TapAwayPainter(
                            levelData: levelData,
                            activeStrings: levelData.strings, // Draw the full puzzle arrows as shown in screenshot
                            animControllers: const {},
                            isWiggling: const {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Stats & Position Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Glassmorphic stats card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Position',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _getPositionText(), // Dynamic position or Date based on challenge
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Colors.white24, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Score',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.rocket_launch, color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      levelData.strings.length.toString(), // Dynamic score based on number of arrows
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Next Game Button
                      GestureDetector(
                        onTap: () {
                          if (widget.isDailyChallenge) {
                            widget.onBack();
                          } else {
                            widget.onNextLevel();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isDailyChallenge ? 'Done' : 'Next Game',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!widget.isDailyChallenge) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Level ${widget.levelNum + 1}',
                                  style: TextStyle(
                                    color: const Color(0xFF4CAF50).withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main button
                      GestureDetector(
                        onTap: widget.onBack,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          child: const Text(
                            'Main',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Confetti Particle model
class ConfettiParticle {
  double x;
  double y;
  double speed;
  Color color;
  double rotation;
  double rotationSpeed;
  double width;
  double height;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.width,
    required this.height,
  });
}

// Custom Painter for Confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      // Draw rectangular paper snippet
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.width, height: p.height),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

// Custom Painter for rotating Sunburst rays
class SunburstPainter extends CustomPainter {
  final double rotationAngle;

  SunburstPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final path = Path();
    const rayCount = 16;
    final angleStep = 2 * pi / rayCount;

    for (int i = 0; i < rayCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * angleStep;
        path.moveTo(0, 0);
        path.arcTo(
          Rect.fromCircle(center: Offset.zero, radius: size.longestSide),
          startAngle,
          angleStep / 2,
          false,
        );
        path.close();
      }
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SunburstPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle;
}

class TapAwayPainter extends CustomPainter {
  final PuzzleLevel levelData;
  final List<PuzzleString> activeStrings;
  final Map<int, AnimationController> animControllers;
  final Map<int, bool> isWiggling;
  final Map<int, bool> isHinting;
  final bool showGridLines;

  TapAwayPainter({
    required this.levelData,
    required this.activeStrings,
    required this.animControllers,
    required this.isWiggling,
    this.isHinting = const {},
    this.showGridLines = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cellWidth = size.width / levelData.gridWidth;
    double cellHeight = size.height / levelData.gridHeight;
    double cellPadX = cellWidth / 2;
    double cellPadY = cellHeight / 2;

    // Draw background dot grid
    final dotPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;

    for (int x = 0; x < levelData.gridWidth; x++) {
      for (int y = 0; y < levelData.gridHeight; y++) {
        canvas.drawCircle(
          Offset(x * cellWidth + cellPadX, y * cellHeight + cellPadY),
          2.5,
          dotPaint,
        );
      }
    }

    if (showGridLines) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      Set<int> occupiedX = {};
      Set<int> occupiedY = {};
      for (var string in activeStrings) {
        for (var p in string.path) {
          occupiedX.add(p.x);
          occupiedY.add(p.y);
        }
      }

      for (int x in occupiedX) {
        double dx = x * cellWidth + cellPadX;
        linePaint.shader = ui.Gradient.linear(
          Offset(dx, 0),
          Offset(dx, size.height),
          [Colors.transparent, Colors.white24, Colors.white24, Colors.transparent],
          [0.0, 0.2, 0.8, 1.0],
        );
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
      }
      for (int y in occupiedY) {
        double dy = y * cellHeight + cellPadY;
        linePaint.shader = ui.Gradient.linear(
          Offset(0, dy),
          Offset(size.width, dy),
          [Colors.transparent, Colors.white24, Colors.white24, Colors.transparent],
          [0.0, 0.2, 0.8, 1.0],
        );
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
      }
    }

    final paint = Paint()
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var string in activeStrings) {
      double animValue = animControllers[string.id]?.value ?? 0.0;
      bool wiggle = isWiggling[string.id] ?? false;
      bool hint = isHinting[string.id] ?? false;

      canvas.save();

      if (wiggle && animValue > 0) {
        paint.color = Colors.red; // Blocked -> Red
      } else if (hint && animValue > 0) {
        paint.color = Colors.white; // Hint -> White
      } else if (animValue > 0 && !wiggle && !hint) {
        paint.color = Colors.white; // Moving -> White
      } else {
        paint.color = const Color(0xFF4CAF50); // Stationary -> Green
      }

      if ((wiggle || hint) && animValue > 0) {
        double shake = sin(animValue * pi * 4) * 4.0;
        Direction dir = string.exitDirection;
        if (dir == Direction.up || dir == Direction.down) {
          canvas.translate(shake, 0);
        } else {
          canvas.translate(0, shake);
        }
      }

      Path basePath = Path();
      Point start = string.path.first;
      basePath.moveTo(start.x * cellWidth + cellPadX, start.y * cellHeight + cellPadY);

      for (int i = 1; i < string.path.length; i++) {
        Point p = string.path[i];
        basePath.lineTo(p.x * cellWidth + cellPadX, p.y * cellHeight + cellPadY);
      }

      Direction dir = string.exitDirection;

      if (!wiggle && !hint && animValue > 0) {
        double exitLength = max(size.width, size.height) + 100;
        double endX = string.head.x * cellWidth + cellPadX;
        double endY = string.head.y * cellHeight + cellPadY;

        if (dir == Direction.right) endX += exitLength;
        if (dir == Direction.left) endX -= exitLength;
        if (dir == Direction.down) endY += exitLength;
        if (dir == Direction.up) endY -= exitLength;

        basePath.lineTo(endX, endY);

        ui.PathMetrics metrics = basePath.computeMetrics();
        var iterator = metrics.iterator;
        if (iterator.moveNext()) {
          ui.PathMetric metric = iterator.current;
          double originalLength = 0;

          for (int i = 0; i < string.path.length - 1; i++) {
            Point p1 = string.path[i];
            Point p2 = string.path[i + 1];
            double dx = (p2.x - p1.x) * cellWidth;
            double dy = (p2.y - p1.y) * cellHeight;
            originalLength += sqrt(dx * dx + dy * dy);
          }

          double totalTravel = exitLength + originalLength;
          double startDist = animValue * totalTravel;
          double endDist = startDist + originalLength;

          basePath = metric.extractPath(startDist, endDist);

          ui.Tangent? tangent = metric.getTangentForOffset(min(endDist, metric.length));
          if (tangent != null) {
            _drawPathWithArrow(canvas, paint, basePath, tangent.position, atan2(tangent.vector.dy, tangent.vector.dx));
          }
        }
      } else {
        double arrowAngle = 0;
        if (dir == Direction.right) arrowAngle = 0;
        if (dir == Direction.left) arrowAngle = pi;
        if (dir == Direction.down) arrowAngle = pi / 2;
        if (dir == Direction.up) arrowAngle = -pi / 2;

        Offset headOffset = Offset(string.head.x * cellWidth + cellPadX, string.head.y * cellHeight + cellPadY);
        _drawPathWithArrow(canvas, paint, basePath, headOffset, arrowAngle);
      }

      canvas.restore();
    }
  }

  void _drawPathWithArrow(Canvas canvas, Paint paint, Path bodyPath, Offset headOffset, double angle) {
    canvas.drawPath(bodyPath, paint);

    double arrowLen = 12.0;
    Path arrow = Path();
    arrow.moveTo(headOffset.dx, headOffset.dy);
    arrow.lineTo(headOffset.dx - arrowLen * cos(angle - pi / 6), headOffset.dy - arrowLen * sin(angle - pi / 6));
    arrow.moveTo(headOffset.dx, headOffset.dy);
    arrow.lineTo(headOffset.dx - arrowLen * cos(angle + pi / 6), headOffset.dy - arrowLen * sin(angle + pi / 6));
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant TapAwayPainter oldDelegate) => true;
}

