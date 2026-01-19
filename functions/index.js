const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_key);

admin.initializeApp();

// Create a Stripe Checkout Session
exports.createStripeCheckoutSession = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated.",
        );
    }

    const uid = context.auth.uid;
    const priceId = data.priceId;
    const successUrl = data.successUrl || "https://success.com";
    const cancelUrl = data.cancelUrl || "https://cancel.com";

    if (!priceId) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a priceId.",
        );
    }

    try {
        // 1. Get or Create Customer
        const customer = await getOrCreateCustomer(uid);

        // 2. Create Checkout Session
        const session = await stripe.checkout.sessions.create({
            customer: customer.id,
            payment_method_types: ["card"],
            line_items: [
                {
                    price: priceId,
                    quantity: 1,
                },
            ],
            mode: "subscription",
            success_url: successUrl,
            cancel_url: cancelUrl,
        });

        return {
            sessionId: session.id,
            url: session.url,
        };
    } catch (error) {
        console.error("Error creating checkout session:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

// Helper: Get or Create Stripe Customer
async function getOrCreateCustomer(uid) {
    const userSnapshot = await admin.firestore().collection("users").doc(uid).get();
    const userData = userSnapshot.data();

    // Check if customer ID exists in Firestore
    if (userData && userData.stripeId) {
        return { id: userData.stripeId };
    }

    const userRecord = await admin.auth().getUser(uid);
    const email = userRecord.email;

    // Create new customer in Stripe
    const customer = await stripe.customers.create({
        email: email,
        metadata: {
            firebaseUID: uid,
        },
    });

    // Save Stripe Customer ID to Firestore
    await admin.firestore().collection("users").doc(uid).set(
        { stripeId: customer.id },
        { merge: true },
    );

    return customer;
}
