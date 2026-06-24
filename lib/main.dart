import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'screens/app_splash_screen.dart';
import 'models/app_settings.dart';
import 'services/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await AppSettings.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdManager.loadAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdManager.showAppOpenAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puzzle App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
        ),
      ),
      builder: (context, child) {
        return GlobalNetworkWrapper(child: child!);
      },
      home: const AppSplashScreen(),
    );
  }
}

class GlobalNetworkWrapper extends StatefulWidget {
  final Widget child;
  const GlobalNetworkWrapper({super.key, required this.child});

  @override
  State<GlobalNetworkWrapper> createState() => _GlobalNetworkWrapperState();
}

class _GlobalNetworkWrapperState extends State<GlobalNetworkWrapper> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isDisconnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      bool disconnected = results.isEmpty || results.contains(ConnectivityResult.none) || results.every((r) => r == ConnectivityResult.none);
      setState(() {
        _isDisconnected = disconnected;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _manualCheck() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    final results = await Connectivity().checkConnectivity();
    bool disconnected = results.isEmpty || results.contains(ConnectivityResult.none) || results.every((r) => r == ConnectivityResult.none);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isDisconnected = disconnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_isDisconnected)
          Positioned.fill(
            child: Container(
              color: const Color(0xD9000000), // Black with 85% opacity
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x80FF5252), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 20),
                        const Text(
                          'No Internet',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Please check your network settings. The game requires an active internet connection to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _isLoading ? null : _manualCheck,
                          child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
