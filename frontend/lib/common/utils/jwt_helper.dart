import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class JwtHelper{
  static Future<String?> getToken() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  static Future<Map<String, dynamic>?> decodeToken() async {
    String? token= await getToken();
    return JwtDecoder.decode(token!);
  }
}