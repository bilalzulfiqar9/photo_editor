import 'package:cloud_firestore/cloud_firestore.dart';
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
    print(
      'StripeService: Creating checkout session for user ${user.uid} with price $priceId',
    );

    final docRef = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('checkout_sessions')
        .add({
          'price': priceId,
          'mode': 'subscription',
          'success_url':
              'https://success.com', // Replace with app link scheme if needed
          'cancel_url': 'https://cancel.com',
        });

    print(
      'StripeService: Document added with ID: ${docRef.id}. Waiting for URL...',
    );

    docRef.snapshots().listen((ds) async {
      if (ds.exists) {
        // Wait for usage of 'sessionId' or 'url'
        final data = ds.data();
        if (data != null) {
          if (data.containsKey('url')) {
            final url = data['url'] as String;
            print('StripeService: URL received: $url');
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              print('StripeService: Could not launch URL: $url');
            }
          } else if (data.containsKey('error')) {
            print(
              'StripeService: Error from extension: ${data['error']['message']}',
            );
            throw Exception(data['error']['message']);
          }
        }
      }
    });
  }
}
