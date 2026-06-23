import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundsEnabled = AppSettings.soundEnabled;
  bool _vibrationEnabled = AppSettings.vibrationEnabled;
  bool _autoLockEnabled = AppSettings.autoLockEnabled;

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSwitchItem('Sounds', _soundsEnabled, (val) {
                setState(() => _soundsEnabled = val);
                AppSettings.setSoundEnabled(val);
              }),
              const Divider(color: Colors.white12, height: 1),
              _buildSwitchItem('Vibration', _vibrationEnabled, (val) {
                setState(() => _vibrationEnabled = val);
                AppSettings.setVibrationEnabled(val);
              }),
              const Divider(color: Colors.white12, height: 1),
              _buildSwitchItem('Auto-Lock', _autoLockEnabled, (val) {
                setState(() => _autoLockEnabled = val);
                AppSettings.setAutoLockEnabled(val);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
