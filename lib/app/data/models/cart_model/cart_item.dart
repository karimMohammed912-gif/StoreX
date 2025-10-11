import 'package:freezed_annotation/freezed_annotation.dart';
import '../home_model/product.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime? addedAt;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
