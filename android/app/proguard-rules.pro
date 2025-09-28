# Stripe ProGuard rules
-keep class com.stripe.** { *; }
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.**

# Keep Stripe models
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.core.** { *; }

# Keep payment methods
-keep class com.stripe.android.payments.** { *; }
-keep class com.stripe.android.paymentmethods.** { *; }