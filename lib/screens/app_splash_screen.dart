import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ad_manager.dart';
import 'home_screen.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  bool _hasError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInternetAndProceed();
  }

  Future<void> _checkInternetAndProceed() async {
    if (_hasError) {
      setState(() {
        _isLoading = true;
      });
    }

    final startTime = DateTime.now();
    bool hasInternet = false;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasInternet = true;
      }
    } on SocketException catch (_) {
      hasInternet = false;
    }

    if (!mounted) return;

    if (hasInternet) {
      // Fetch the remote Ad config when internet is confirmed
      await AdManager.fetchAdConfig();

      final elapsedTime = DateTime.now().difference(startTime);
      if (!_hasError && elapsedTime.inMilliseconds < 1500) {
        await Future.delayed(Duration(milliseconds: 1500 - elapsedTime.inMilliseconds));
      } else if (_hasError && elapsedTime.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsedTime.inMilliseconds));
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (_hasError) {
        final elapsedTime = DateTime.now().difference(startTime);
        if (elapsedTime.inMilliseconds < 1000) {
          await Future.delayed(Duration(milliseconds: 1000 - elapsedTime.inMilliseconds));
        }
      }
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _hasError ? _buildErrorView() : _buildLogo(),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.asset(
        'assets/puzzle logo.png',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          size: 80,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 20),
        const Text(
          'No Internet Connection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please check your network and try again.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _checkInternetAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Retry',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ],
    );
  }
}
