import 'dart:async';

class AdService {
  const AdService();

  // Stubbed rewarded flow so real ad SDK can be dropped in later.
  // Returns true when reward should be granted.
  Future<bool> showRewardedReviveAd() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return true;
  }
}
