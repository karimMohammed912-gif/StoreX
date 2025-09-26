import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
sealed class HomeModel with _$HomeModel {
  factory HomeModel({
    List<Product>? products,
    int? total,
    int? skip,
    int? limit,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);
}
