# Services

This directory contains service classes for the Store X application.

## Stripe Payment Service

The `StripePaymentService` handles payment processing using Stripe in test mode with flutter_stripe ^12.0.2.

### Features:
- Process payments using Stripe Payment Sheet (recommended)
- Create payment intents
- Create payment methods for saving cards
- Handle payment confirmations
- Support for customer management (optional)

### Usage:
```dart
// Initialize the service
final stripeService = Get.find<StripePaymentService>();

// Process a payment using Payment Sheet
final result = await stripeService.processPayment(
  amount: 29.99,
  currency: 'usd',
  metadata: {'product_id': '123'},
);

if (result.isSuccess) {
  print('Payment successful: ${result.paymentIntentId}');
} else {
  print('Payment failed: ${result.errorMessage}');
}

// Alternative: Use presentPaymentSheet directly
final result = await stripeService.presentPaymentSheet(
  amount: 29.99,
  currency: 'usd',
  customerId: 'customer_id', // Optional
  customerEphemeralKeySecret: 'ephemeral_key', // Optional
);

// Create a payment method for saving cards
final paymentMethod = await stripeService.createPaymentMethod(
  cardNumber: '4242424242424242',
  expiryMonth: 12,
  expiryYear: 2025,
  cvc: '123',
  cardholderName: 'John Doe',
);
```

### Configuration:
1. Replace the test keys in `stripe_payment_service.dart` with your actual Stripe test keys
2. Set up your backend to handle payment intent creation
3. Configure Stripe webhook endpoints for production
4. For customer management, implement customer creation and ephemeral key generation on your backend

## SQLite Favorites Service

The `SqliteFavoritesService` manages favorite products using SQLite local storage.

### Features:
- Add/remove products from favorites
- Search favorites by title, description, or brand
- Sort favorites by price or rating
- Filter favorites by category
- Observable list for reactive UI updates

### Usage:
```dart
// Initialize the service
final favoritesService = Get.find<SqliteFavoritesService>();

// Add a product to favorites
await favoritesService.addToFavorites(product);

// Remove a product from favorites
await favoritesService.removeFromFavorites(product.id!);

// Toggle favorite status
await favoritesService.toggleFavorite(product);

// Check if product is favorite
final isFavorite = await favoritesService.isFavorite(product.id!);

// Get all favorites
final favorites = favoritesService.getFavorites();

// Search favorites
final searchResults = favoritesService.searchFavorites('search query');

// Sort by price
final sortedByPrice = favoritesService.getFavoritesSortedByPrice();
```

### Database Schema:
- Table: `favorite_products`
- Columns: `id`, `product_id`, `product_data`, `added_at`
- Product data is stored as JSON for flexibility

## Setup

1. Add the services to your dependency injection in `lib/app/di/dependency.dart`:

```dart
void initDependencies() {
  // ... existing dependencies
  
  // Services
  Get.put<StripePaymentService>(StripePaymentService());
  Get.put<SqliteFavoritesService>(SqliteFavoritesService());
}
```

2. Initialize Stripe in your main app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = 'your_publishable_key_here';
  
  runApp(MyApp());
}
```

## Dependencies Added

- `flutter_stripe: ^11.1.0` - Stripe payment processing
- `path: ^1.9.0` - Path utilities for database
- `sqflite: ^2.4.2` - SQLite database (already existed)
