import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoading = false;

  void loadRewardedAd() {
    if (_isAdLoading || _rewardedInterstitialAd != null) return;
    _isAdLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: 'ca-app-pub-4241608895500197/3441692149',
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitialAd = null;
          _isAdLoading = false;
          debugPrint('Erro ao carregar anúncio recompensado: $error');
        },
      ),
    );
  }

  void showRewardedAd({required VoidCallback onRewardEarned}) {
    if (_rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedInterstitialAd = null;
              loadRewardedAd(); // Recarrega para o próximo uso
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedInterstitialAd = null;
              loadRewardedAd();
              onRewardEarned(); // Executa mesmo se o anúncio falhar para não travar o usuário
            },
          );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned(); // Executa a ação liberada após assistir o anúncio
        },
      );
    } else {
      // Se o anúncio ainda não tiver carregado, libera a função diretamente
      onRewardEarned();
      loadRewardedAd();
    }
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
  }
}
