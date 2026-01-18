import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  Future<void> makePayment(int amount, String currency) async {
    // TODO: Implement one-time payment using extension if needed.
    // For now, we focus on subscription as requested.
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> subscribeToPlan(String priceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('StripeService: User not logged in');
      throw Exception('User not logged in');
    }

    try {
      print('StripeService: Calling createStripeCheckoutSession...');
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'createStripeCheckoutSession',
      );

      final result = await callable.call(<String, dynamic>{
        'priceId': priceId,
        'successUrl': 'https://success.com', // Update with deep link if needed
        'cancelUrl': 'https://cancel.com',
      });

      final data = result.data as Map<dynamic, dynamic>;
      final url = data['url'] as String;

      print('StripeService: URL received: $url');
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        print('StripeService: Could not launch URL: $url');
        throw Exception('Could not launch payment URL');
      }
    } catch (e) {
      print('StripeService: Error: $e');
      throw Exception('Payment init failed: ${e.toString()}');
    }
  }
}
