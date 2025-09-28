import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_x/app/modules/auth/user_model/user_model.dart';

class SessionService extends GetxService {
  
  static const _userKey = 'auth_user_v1';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
    print('SessionService: User saved successfully: ${user.email}');
  }

  Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    print('SessionService: Loading user from storage...');
    if (jsonString == null) {
      print('SessionService: No user data found in storage');
      return null;
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final user = UserModel.fromJson(map);
      print('SessionService: User loaded successfully: ${user.email}');
      return user;
    } catch (e) {
      print('SessionService: Error parsing user data: $e');
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

