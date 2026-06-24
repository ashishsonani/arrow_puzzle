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

  static bool showBannerAds = true;
  static bool showInterstitialAds = true;
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
    try {
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/ashishsonani/arrow_puzzle/main/ads_config.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        showBannerAds = data['show_banner_ads'] ?? true;
        showInterstitialAds = data['show_interstitial_ads'] ?? true;
        levelAdFrequency = data['level_ad_frequency'] ?? 2;

        if (data['android'] != null) {
          bannerAdUnitIdAndroid = data['android']['banner'] ?? bannerAdUnitIdAndroid;
          interstitialAdUnitIdAndroid = data['android']['interstitial'] ?? interstitialAdUnitIdAndroid;
          rewardedAdUnitIdAndroid = data['android']['rewarded'] ?? rewardedAdUnitIdAndroid;
          appOpenAdUnitIdAndroid = data['android']['app_open'] ?? appOpenAdUnitIdAndroid;
        }
        if (data['ios'] != null) {
          bannerAdUnitIdIOS = data['ios']['banner'] ?? bannerAdUnitIdIOS;
          interstitialAdUnitIdIOS = data['ios']['interstitial'] ?? interstitialAdUnitIdIOS;
          rewardedAdUnitIdIOS = data['ios']['rewarded'] ?? rewardedAdUnitIdIOS;
          appOpenAdUnitIdIOS = data['ios']['app_open'] ?? appOpenAdUnitIdIOS;
        }
        debugPrint('Ad config fetched successfully');
        
        // Start loading ads immediately after fetching config
        loadInterstitialAd();
        loadRewardedAd();
        loadAppOpenAd();
      } else {
        debugPrint('Failed to load ad config: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching ad config: $e');
    }
  }


  static void loadInterstitialAd() {
    if (interstitialAdUnitId.isEmpty) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void incrementLevelClick() {
    adClickCounter++;
  }

  static bool _isFirstAdShown = false;

  static bool shouldShowInterstitialAd() {
    if (!showInterstitialAds) return false;

    if (!_isFirstAdShown) {
      _isFirstAdShown = true;
      adClickCounter = 0; // Reset counter so next ad is exactly levelAdFrequency clicks away
      return true;
    }

    return (adClickCounter % levelAdFrequency == 0);
  }

  static void showInterstitialAd(VoidCallback onAdDismissed) {
    incrementLevelClick();
    if (!shouldShowInterstitialAd()) {
      onAdDismissed();
      return;
    }
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      onAdDismissed();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Load next ad
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Load next ad
        onAdDismissed();
      },
    );
    _interstitialAd!.show();
  }

  static void loadRewardedAd() {
    if (rewardedAdUnitId.isEmpty) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd(Function(RewardItem) onRewardEarned, VoidCallback onAdDismissed) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      onAdDismissed();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Load next ad
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Load next ad
        onAdDismissed();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      onRewardEarned(rewardItem);
    });
  }

  static BannerAd? createBannerAd(VoidCallback onAdLoaded) {
    if (!showBannerAds || bannerAdUnitId.isEmpty) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );
  }

  static void loadAppOpenAd() {
    if (appOpenAdUnitId.isEmpty) return;
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          if (!_isFirstAppOpenAdShown) {
            _isFirstAppOpenAdShown = true;
            showAppOpenAdIfAvailable();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  static bool get isAdAvailable {
    return _appOpenAd != null && _appOpenLoadTime != null && 
           DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);
  }

  static void showAppOpenAdIfAvailable() {
    if (!isAdAvailable) {
      loadAppOpenAd();
      return;
    }
    if (_isShowingAd) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }
}
