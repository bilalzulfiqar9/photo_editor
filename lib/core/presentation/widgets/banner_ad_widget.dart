import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final BannerAd? bannerAd;

  const BannerAdWidget({super.key, required this.bannerAd});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: widget.bannerAd!.size.width.toDouble(),
      height: widget.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: widget.bannerAd!),
    );
  }
}
