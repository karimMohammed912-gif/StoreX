import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:store_x/app/data/models/home_model/home_model.dart';
import 'package:store_x/app/networking/api.dart';
import 'package:store_x/app/utils/error.dart';

class HomeRepo {
  Future<Either<Failure, HomeModel>> getHomeData({
    String? category,
  }) async {
    try {
      final response = await Api.getHomeData(category: category);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
