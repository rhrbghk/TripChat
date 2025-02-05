import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AdService {
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isAdLoading = false;

  static void loadInterstitialAd() {
    if (_rewardedInterstitialAd != null || _isAdLoading) return;

    _isAdLoading = true;
    print('광고 로딩 시작');
    RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-1410643931843748/8639964424' // Android 광고 단위 ID
          : 'ca-app-pub-1410643931843748/7810098488', // iOS 광고 단위 ID
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('광고 로드 성공');
          _rewardedInterstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          print('광고 로드 실패: $error');
          _isAdLoading = false;
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_rewardedInterstitialAd == null) {
      print('광고가 없어서 새로 로드');
      loadInterstitialAd();
      return;
    }

    try {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('광고 닫힘');
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('광고 표시 실패: $error');
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadInterstitialAd();
        },
        onAdShowedFullScreenContent: (ad) {
          print('광고 표시됨');
        },
      );

      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          // 보상 지급 로직 (필요한 경우)
          print('보상 지급: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedInterstitialAd = null;
    } catch (e) {
      print('광고 표시 중 에러: $e');
      _rewardedInterstitialAd = null;
      loadInterstitialAd();
    }
  }
}
