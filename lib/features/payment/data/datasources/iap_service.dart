import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Function(PurchaseDetails) onPurchaseSuccess;
  final Function(String) onPurchaseError;

  IAPService({required this.onPurchaseSuccess, required this.onPurchaseError}) {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        onPurchaseError(error.toString());
      },
    );
  }

  Future<List<ProductDetails>> getProducts(Set<String> ids) async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return [];
    }
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      print('Items not found: ${response.notFoundIDs}');
    }
    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          onPurchaseError(purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          onPurchaseSuccess(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
