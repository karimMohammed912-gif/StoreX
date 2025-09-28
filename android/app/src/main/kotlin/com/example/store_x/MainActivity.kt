package com.example.store_x

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import com.stripe.android.PaymentConfiguration

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize Stripe with publishable key
        PaymentConfiguration.init(
            applicationContext,
            "Your Own publishable Key"
        )
    }
}
