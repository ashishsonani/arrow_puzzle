// ignore_for_file: unused_import, unused_field, unused_element
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static DateTime? _appOpenLoadTime;
  static bool _isFirstAppOpenAdShown = false;

  static bool showBannerAds = false;
  static bool showInterstitialAds = false;
  static int levelAdFrequency = 2;
  static int adClickCounter = 0;

  static String bannerAdUnitIdAndroid = 'ca-app-pub-8708457885343434/3566001600';
  static String bannerAdUnitIdIOS = '';
  static String interstitialAdUnitIdAndroid = 'ca-app-pub-8708457885343434/1833549318';
  static String interstitialAdUnitIdIOS = '';
  static String rewardedAdUnitIdAndroid = 'ca-app-pub-8708457885343434/9728919427';
  static String rewardedAdUnitIdIOS = '';
  static String appOpenAdUnitIdAndroid = 'ca-app-pub-8708457885343434/6192164944';
  static String appOpenAdUnitIdIOS = '';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) return bannerAdUnitIdAndroid;
    if (Platform.isIOS) return bannerAdUnitIdIOS;
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return interstitialAdUnitIdAndroid;
    if (Platform.isIOS) return interstitialAdUnitIdIOS;
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return rewardedAdUnitIdAndroid;
    if (Platform.isIOS) return rewardedAdUnitIdIOS;
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) return appOpenAdUnitIdAndroid;
    if (Platform.isIOS) return appOpenAdUnitIdIOS;
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> fetchAdConfig() async {
    // Disabled for live launch
    return;
  }

  static void loadInterstitialAd() {
    return;
  }

  static void incrementLevelClick() {
    adClickCounter++;
  }

  static bool _isFirstAdShown = false;

  static bool shouldShowInterstitialAd() {
    return false;
  }

  static void showInterstitialAd(VoidCallback onAdDismissed) {
    onAdDismissed();
  }

  static void loadRewardedAd() {
    return;
  }

  static bool showRewardedAd(Function(RewardItem) onRewardEarned, VoidCallback onAdDismissed) {
    onAdDismissed();
    return false;
  }

  static BannerAd? createBannerAd(VoidCallback onAdLoaded) {
    return null;
  }

  static void loadAppOpenAd() {
    return;
  }

  static bool get isAdAvailable {
    return false;
  }

  static void showAppOpenAdIfAvailable() {
    return;
  }
}
