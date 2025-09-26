import 'package:dio/dio.dart';
import 'package:store_x/app/data/models/home_model/home_model.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/modules/auth/user_model/user_model.dart';
import 'package:store_x/app/utils/constant.dart';

class Api {
  static Dio dio = Dio();

  static void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Future<HomeModel> getHomeData({String? category}) async {
    try {
      if (category == null || category == "all") {
        final response = await dio.get('$baseUrl/products');
        print(response.data);
        return HomeModel.fromJson(response.data);
      } else {
        final response = await dio.get('$baseUrl$categoryEndpoint$category');
        print(response.data);
        return HomeModel.fromJson(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<UserModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/login",
        data: {"username": username, "password": password, "expiresInMins": 30},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (de) {
      final status = de.response?.statusCode;
      final data = de.response?.data;
      if (status == 400) {
        final message = (data is Map && data['message'] is String)
            ? data['message'] as String
            : 'Invalid username or password';
        throw Exception(message);
      }
      throw Exception('Network error (${status ?? 'unknown'}). Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

static Future<List<Product>> searchProducts(String query) async {
  try {
    final response = await dio.get('$baseUrl/products/search?q=$query');
    final data = response.data as Map<String, dynamic>;
    final List productsJson = data['products'] as List;
    final List<Product> products = productsJson
        .map<Product>((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return products;
  } catch (e) {
    throw Exception(e.toString());
  }
}
}