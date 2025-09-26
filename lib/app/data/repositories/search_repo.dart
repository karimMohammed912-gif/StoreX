import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/networking/api.dart';
import 'package:store_x/app/utils/error.dart';

class SearchRepo {
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await Api.searchProducts(query);
      return Right(products);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}


