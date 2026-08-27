import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/player_profile_model.dart';
import '../../../core/constants.dart';

/// 📦 نتيجة محاولة تسجيل الدخول: إما نجاح (توكن + بيانات اللاعب)،
/// أو فشل مع رسالة خطأ عربية جاهزة للعرض مباشرة للمستخدم.
class LoginResult {
  final bool success;
  final String? token;
  final UserModel? player;
  final String? errorMessage;

  LoginResult.success({required this.token, required this.player})
      : success = true,
        errorMessage = null;

  LoginResult.failure(this.errorMessage)
      : success = false,
        token = null,
        player = null;
}

/// 📦 نتيجة جلب حالة الاشتراك.
class SubscriptionResult {
  final bool success;
  final SubscriptionModel? subscription;
  final String? errorMessage;
  final bool isUnauthorized;

  SubscriptionResult.success(this.subscription)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  SubscriptionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        subscription = null;
}

/// 📦 نتيجة جلب خطة تمارين اللاعب.
class WorkoutsResult {
  final bool success;
  final List<ExerciseModel>? exercises;
  final String? errorMessage;
  final bool isUnauthorized;

  WorkoutsResult.success(this.exercises)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  WorkoutsResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        exercises = null;
}

/// 📦 نتيجة جلب خطة اللاعب الغذائية.
class DietResult {
  final bool success;
  final List<MealModel>? meals;
  final String? errorMessage;
  final bool isUnauthorized;

  DietResult.success(this.meals)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  DietResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        meals = null;
}

/// 📦 نتيجة محاولة تسجيل الحضور اليومي.
class AttendanceResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  AttendanceResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  AttendanceResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

/// 📦 نتيجة جلب الملف الشخصي الكامل للاعب.
class ProfileResult {
  final bool success;
  final PlayerProfileModel? profile;
  final String? errorMessage;
  final bool isUnauthorized;

  ProfileResult.success(this.profile)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  ProfileResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        profile = null;
}

/// 📦 نتيجة محاولة تغيير كلمة المرور.
class PasswordChangeResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  PasswordChangeResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  PasswordChangeResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

class ApiService {
  /// 🔐 يبني ترويسات الطلب المصادَق عليه (Bearer Token).
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 🔐 تسجيل الدخول عبر API الموقع (Laravel + Sanctum المتوقع).
  ///
  ///   POST {apiBaseUrl}/login
  ///   Body:     { "email": "...", "password": "..." }
  ///   نجاح 200: { "token": "...", "player": { "id", "name", "email", "phone", "level" } }
  Future<LoginResult> login(String email, String password) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/login');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['token'] != null && data['player'] != null) {
        return LoginResult.success(
          token: data['token'] as String,
          player: UserModel.fromJson(data['player'] as Map<String, dynamic>),
        );
      }

      final message = data['message'] as String? ?? 'بيانات الدخول غير صحيحة، راجع الكوتش.';
      return LoginResult.failure(message);
    } on TimeoutException {
      return LoginResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return LoginResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return LoginResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return LoginResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 📊 جلب حالة اشتراك اللاعب الحالي.
  ///   GET {apiBaseUrl}/subscription
  Future<SubscriptionResult> getSubscription() async {
    final url = Uri.parse('${Constants.apiBaseUrl}/subscription');

    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return SubscriptionResult.failure('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', isUnauthorized: true);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return SubscriptionResult.success(SubscriptionModel.fromJson(data));
      }

      final message = data['message'] as String? ?? 'تعذّر جلب بيانات الاشتراك.';
      return SubscriptionResult.failure(message);
    } on TimeoutException {
      return SubscriptionResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return SubscriptionResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return SubscriptionResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return SubscriptionResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 🏋️ جلب كل تمارين خطة اللاعب التدريبية.
  ///   GET {apiBaseUrl}/workouts
  Future<WorkoutsResult> getWorkouts() async {
    final url = Uri.parse('${Constants.apiBaseUrl}/workouts');

    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return WorkoutsResult.failure('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', isUnauthorized: true);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final list = (data['exercises'] as List<dynamic>? ?? [])
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return WorkoutsResult.success(list);
      }

      final message = data['message'] as String? ?? 'تعذّر جلب خطتك التدريبية.';
      return WorkoutsResult.failure(message);
    } on TimeoutException {
      return WorkoutsResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return WorkoutsResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return WorkoutsResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return WorkoutsResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 🍽️ جلب خطة اللاعب الغذائية (كل الوجبات المسندة له من مدربه).
  ///
  ///   GET {apiBaseUrl}/diet   (يتطلب Authorization: Bearer التوكن)
  ///   نجاح 200: { "meals": [{ "id","meal_name","calories","protein",
  ///                            "carbs","fats","plan_details","image_url" }] }
  Future<DietResult> getDiet() async {
    final url = Uri.parse('${Constants.apiBaseUrl}/diet');

    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return DietResult.failure('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', isUnauthorized: true);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final list = (data['meals'] as List<dynamic>? ?? [])
            .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DietResult.success(list);
      }

      final message = data['message'] as String? ?? 'تعذّر جلب خطتك الغذائية.';
      return DietResult.failure(message);
    } on TimeoutException {
      return DietResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return DietResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return DietResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return DietResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 🖐️ تسجيل حضور اللاعب لهذا اليوم (مرة واحدة يومياً فقط).
  ///
  ///   POST {apiBaseUrl}/attendance/check-in   (يتطلب Authorization: Bearer التوكن)
  ///   نجاح 200: { "message": "...", "attended_at": "..." }
  ///   (الاستدعاء آمن للتكرار: لو كان مسجَّلاً أصلاً اليوم، يرجع رسالة توضيحية بدل خطأ)
  Future<AttendanceResult> checkInAttendance() async {
    final url = Uri.parse('${Constants.apiBaseUrl}/attendance/check-in');

    try {
      final headers = await _authHeaders();
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return AttendanceResult.failure('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', isUnauthorized: true);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return AttendanceResult.success(data['message'] as String? ?? 'تم تسجيل حضورك بنجاح');
      }

      final message = data['message'] as String? ?? 'تعذّر تسجيل حضورك.';
      return AttendanceResult.failure(message);
    } on TimeoutException {
      return AttendanceResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return AttendanceResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return AttendanceResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return AttendanceResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 👤 جلب الملف الشخصي الكامل للاعب.
  ///   GET {apiBaseUrl}/profile
  Future<ProfileResult> getProfile() async {
    final url = Uri.parse('${Constants.apiBaseUrl}/profile');

    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return ProfileResult.failure('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', isUnauthorized: true);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ProfileResult.success(PlayerProfileModel.fromJson(data));
      }

      final message = data['message'] as String? ?? 'تعذّر جلب بيانات ملفك الشخصي.';
      return ProfileResult.failure(message);
    } on TimeoutException {
      return ProfileResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return ProfileResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return ProfileResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return ProfileResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }

  /// 🔒 تغيير كلمة المرور — يتطلب تأكيد كلمة المرور الحالية.
  ///   PUT {apiBaseUrl}/profile/password
  ///   Body: { "current_password", "password", "password_confirmation" }
  Future<PasswordChangeResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/profile/password');

    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({
              'current_password': currentPassword,
              'password': newPassword,
              'password_confirmation': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // 401 هنا قد تعني "التوكن منتهي" أو "كلمة المرور الحالية غلط" —
        // الباك إند لا يفرّق بينهما برمز مختلف، لذا نعرض رسالته مباشرة
        // دون افتراض انتهاء الجلسة تلقائياً (لتفادي تسجيل خروج غير مبرَّر).
        return PasswordChangeResult.failure(data['message'] as String? ?? 'كلمة المرور الحالية غير صحيحة.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PasswordChangeResult.success(data['message'] as String? ?? 'تم تغيير كلمة المرور بنجاح.');
      }

      final message = data['message'] as String? ?? 'تعذّر تغيير كلمة المرور.';
      return PasswordChangeResult.failure(message);
    } on TimeoutException {
      return PasswordChangeResult.failure('انتهت مهلة الاتصال بالخادم، حاول مجدداً.');
    } on SocketException {
      return PasswordChangeResult.failure('تعذّر الاتصال بالخادم، تحقّق من اتصالك بالإنترنت.');
    } on FormatException {
      return PasswordChangeResult.failure('حدث خطأ غير متوقع من الخادم.');
    } catch (e) {
      return PasswordChangeResult.failure('حدث خطأ غير متوقع، حاول مجدداً.');
    }
  }
}